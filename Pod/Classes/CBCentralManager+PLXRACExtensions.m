#import <objc/runtime.h>
#import "CBCentralManager+PLXRACExtensions.h"
#import "NSError+PLXRACExtensions.h"
#import "RACSignal+PLXBluetoothRACUtilities.h"
#import <ReactiveCocoa/RACDelegateProxy.h>

NSInteger PLXCBCentralManagerScanInfiniteCount = -1;

@implementation CBCentralManager (PLXRACExtensions)

static void RACUseDelegateProxy(CBCentralManager *self) {
    if (self.delegate == self.rac_delegateProxy) return;

    self.rac_delegateProxy.rac_proxiedDelegate = self.delegate;
    self.delegate = (id) self.rac_delegateProxy;
}

- (BOOL)shouldWaitUntilPoweredOn {
    NSNumber *object = objc_getAssociatedObject(self, _cmd);
    if (!object) {
        self.shouldWaitUntilPoweredOn = NO;
    }
    return [object boolValue];
}

- (void)setShouldWaitUntilPoweredOn:(BOOL)shouldWaitUntilPoweredOn {
    objc_setAssociatedObject(self, _cmd, @(shouldWaitUntilPoweredOn), OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (RACDelegateProxy *)rac_delegateProxy {
    RACDelegateProxy *proxy = objc_getAssociatedObject(self, _cmd);
    if (proxy == nil) {
        proxy = [[RACDelegateProxy alloc] initWithProtocol:@protocol(CBCentralManagerDelegate)];
        objc_setAssociatedObject(self, _cmd, proxy, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return proxy;
}

- (BOOL)_isPoweredOn {
    return (CBCentralManagerState) self.state == CBCentralManagerStatePoweredOn;
}

- (RACSignal *)_plx_performSignalIfReady:(RACSignal *)signal {
    RACSignal *waitUntilReadySignal = [[[[self
            rac_isPoweredOn]
            ignore:@NO]
            plx_singleValue]
            flattenMap:^RACSignal *(id _) {
                return signal;
            }];
    return [RACSignal if:[RACSignal return:@(self.shouldWaitUntilPoweredOn)]
                    then:waitUntilReadySignal
                    else:signal];
}

- (RACSignal *)rac_isPoweredOn {
    @weakify(self)
    return [[RACObserve(self, state)
            map:^NSNumber *(NSNumber *state) {
                @strongify(self)
                return @([self _isPoweredOn]);
            }]
            distinctUntilChanged];
}

- (RACSignal *)rac_scanForPeripheralsWithServices:(NSArray<CBUUID *> *)serviceUUIDs count:(NSInteger)count options:(NSDictionary<NSString *, id> *)options {
    RACSignal *delegateSignal = [[[self.rac_delegateProxy
            signalForSelector:@selector(centralManager:didDiscoverPeripheral:advertisementData:RSSI:)]
            reduceEach:^id(CBCentralManager *central, CBPeripheral *peripheral, NSDictionary<NSString *, id> *advertisementData, NSNumber *RSSI) {
                return RACTuplePack(peripheral, advertisementData, RSSI);
            }]
            takeUntil:self.rac_willDeallocSignal];

    RACUseDelegateProxy(self);

    @weakify(self)
    RACSignal *scanSignal = [[RACSignal createSignal:^RACDisposable *(id <RACSubscriber> subscriber) {
        @strongify(self)
        if (!self._isPoweredOn && !self.shouldWaitUntilPoweredOn) {
            [subscriber sendError:[NSError plx_bluetoothOffError]];
            return nil;
        }

        __block NSInteger valuesCount = 0;
        __block RACDisposable *proxyDisposable;
        proxyDisposable = [delegateSignal subscribeNext:^(CBPeripheral *peripheral) {
            @strongify(self)
            if (valuesCount++ < count || count == PLXCBCentralManagerScanInfiniteCount) {
                [subscriber sendNext:peripheral];
            }
            if (valuesCount >= count && count != PLXCBCentralManagerScanInfiniteCount) {
                [self stopScan];
                [proxyDisposable dispose];
                [subscriber sendCompleted];
            }
        }                                         error:^(NSError *error) {
            [subscriber sendError:error];
        }                                     completed:^{
            @strongify(self)
            [self stopScan];
        }];

        [self scanForPeripheralsWithServices:serviceUUIDs options:options];

        return [RACDisposable disposableWithBlock:^{
            @strongify(self)
            [self stopScan];
        }];
    }] setNameWithFormat:@"-rac_scanForPeripheralsWithServices: = %@ count: = %@ options: = %@", serviceUUIDs, @(count), options];

    return [self _plx_performSignalIfReady:scanSignal];
}

- (RACSignal *)rac_stopScan {
    @weakify(self)
    return [RACSignal createSignal:^RACDisposable *(id <RACSubscriber> subscriber) {
        @strongify(self)
        [self stopScan];
        [subscriber sendNext:@YES];
        [subscriber sendCompleted];
        return nil;
    }];
}

- (RACSignal *)rac_connectPeripheral:(CBPeripheral *)peripheral options:(NSDictionary<NSString *, id> *)options {
    RACSignal *successSignal = [[[[self.rac_delegateProxy
            signalForSelector:@selector(centralManager:didConnectPeripheral:)]
            reduceEach:^id(CBCentralManager *central, CBPeripheral *connectedPeripheral) {
                return connectedPeripheral;
            }]
            filter:^BOOL(CBPeripheral *connectedPeripheral) {
                return [connectedPeripheral.identifier isEqual:peripheral.identifier];
            }]
            takeUntil:self.rac_willDeallocSignal];

    RACSignal *failSignal = [[[[self.rac_delegateProxy
            signalForSelector:@selector(centralManager:didFailToConnectPeripheral:error:)]
            filter:^BOOL(RACTuple *tuple) {
                RACTupleUnpack(__unused CBCentralManager *_, CBPeripheral *connectedPeripheral, __unused NSError *__) = tuple;
                return [connectedPeripheral.identifier isEqual:peripheral.identifier];
            }]
            reduceEach:^id(CBCentralManager *central, CBPeripheral *connectedPeripheral, NSError *error) {
                return error;
            }]
            takeUntil:self.rac_willDeallocSignal];

    RACUseDelegateProxy(self);

    @weakify(self)
    RACSignal *connectSignal = [[RACSignal createSignal:^RACDisposable *(id <RACSubscriber> subscriber) {
        @strongify(self)
        if (!self._isPoweredOn && !self.shouldWaitUntilPoweredOn) {
            [subscriber sendError:[NSError plx_bluetoothOffError]];
            return nil;
        }

        RACDisposable *successDisposable = [successSignal subscribeNext:^(CBPeripheral *connectedPeripheral) {
            [subscriber sendNext:connectedPeripheral];
            [subscriber sendCompleted];
        }];
        RACDisposable *failDisposable = [failSignal subscribeNext:^(NSError *error) {
            [subscriber sendError:error];
        }];
        [self connectPeripheral:peripheral options:options];
        return [RACCompoundDisposable compoundDisposableWithDisposables:@[successDisposable, failDisposable]];
    }] setNameWithFormat:@"-rac_connectPeripheral: = %@ options: = %@", peripheral, options];

    return [self _plx_performSignalIfReady:connectSignal];
}

- (RACSignal *)rac_disconnectPeripheralConnection:(CBPeripheral *)peripheral {
    RACSignal *delegateSignal = [[[[self.rac_delegateProxy
            signalForSelector:@selector(centralManager:didDisconnectPeripheral:error:)]
            filter:^BOOL(RACTuple *tuple) {
                RACTupleUnpack(__unused CBCentralManager *_, CBPeripheral *disconnectedPeripheral, __unused NSError *__) = tuple;
                return [disconnectedPeripheral.identifier isEqual:peripheral.identifier];
            }]
            reduceEach:^id(CBCentralManager *central, CBPeripheral *disconnectedPeripheral, NSError *error) {
                return error ?: disconnectedPeripheral;
            }]
            takeUntil:self.rac_willDeallocSignal];

    @weakify(self)
    RACSignal *disconnectSignal = [[RACSignal createSignal:^RACDisposable *(id <RACSubscriber> subscriber) {
        @strongify(self)
        if (!self._isPoweredOn && !self.shouldWaitUntilPoweredOn) {
            [subscriber sendError:[NSError plx_bluetoothOffError]];
            return nil;
        }
        RACDisposable *disposable = [delegateSignal subscribeNext:^(id value) {
            if ([value isKindOfClass:[NSError class]]) {
                [subscriber sendError:value];
            } else {
                [subscriber sendNext:value];
                [subscriber sendCompleted];
            }
        }];
        [self cancelPeripheralConnection:peripheral];
        return disposable;
    }] setNameWithFormat:@"-rac_disconnectPeripheralConnection: = %@", peripheral];

    return [self _plx_performSignalIfReady:disconnectSignal];
}

@end
