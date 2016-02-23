#import <objc/runtime.h>
#import "CBCentralManager+PLXRACExtensions.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <ReactiveCocoa/RACDelegateProxy.h>

NSInteger PLXCBCentralManagerScanInfiniteCount = -1;

@implementation CBCentralManager (PLXRACExtensions)

static void RACUseDelegateProxy(CBCentralManager *self) {
    if (self.delegate == self.rac_delegateProxy) return;

    self.rac_delegateProxy.rac_proxiedDelegate = self.delegate;
    self.delegate = (id) self.rac_delegateProxy;
}

- (RACDelegateProxy *)rac_delegateProxy {
    RACDelegateProxy *proxy = objc_getAssociatedObject(self, _cmd);
    if (proxy == nil) {
        proxy = [[RACDelegateProxy alloc] initWithProtocol:@protocol(CBCentralManagerDelegate)];
        objc_setAssociatedObject(self, _cmd, proxy, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return proxy;
}

- (RACSignal *)rac_isPoweredOn {
    return [[RACObserve(self, state)
            map:^NSNumber *(NSNumber *state) {
                return @((CBCentralManagerState) state.integerValue == CBCentralManagerStatePoweredOn);
            }]
            distinctUntilChanged];
}

- (RACSignal *)rac_scanForPeripheralsWithServices:(NSArray<CBUUID *> *)serviceUUIDs count:(NSInteger)count options:(NSDictionary<NSString *, id> *)options {
    RACSignal *signal = [[[self.rac_delegateProxy
            signalForSelector:@selector(centralManager:didDiscoverPeripheral:advertisementData:RSSI:)]
            reduceEach:^id(CBCentralManager *central, CBPeripheral *peripheral, NSDictionary<NSString *, id> *advertisementData, NSNumber *RSSI) {
                return RACTuplePack(peripheral, advertisementData, RSSI);
            }]
            takeUntil:self.rac_willDeallocSignal];

    RACUseDelegateProxy(self);

    @weakify(self)
    return [[RACSignal createSignal:^RACDisposable *(id <RACSubscriber> subscriber) {
        @strongify(self)
        __block NSInteger valuesCount = 0;
        RACDisposable *proxyDisposable = [signal subscribeNext:^(CBPeripheral *peripheral) {
            @strongify(self)
            if (valuesCount++ < count || count == PLXCBCentralManagerScanInfiniteCount) {
                [subscriber sendNext:peripheral];
            }
            if (valuesCount >= count && count != PLXCBCentralManagerScanInfiniteCount) {
                [self stopScan];
                [proxyDisposable dispose];
                [subscriber sendCompleted];
            }
        }                                                error:^(NSError *error) {
            [subscriber sendError:error];
        }                                            completed:^{
            @strongify(self)
            [self stopScan];
        }];

        [self scanForPeripheralsWithServices:serviceUUIDs options:options];

        return [RACDisposable disposableWithBlock:^{
            if (count != PLXCBCentralManagerScanInfiniteCount) {
                @strongify(self)
                [self stopScan];
            }
        }];
    }] setNameWithFormat:@"-rac_scanForPeripheralsWithServices: = %@ count: = %@ options: = %@", serviceUUIDs, @(count), options];
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
                RACTupleUnpack(CBCentralManager *_, CBPeripheral *connectedPeripheral, NSError *__) = tuple;
                return [connectedPeripheral.identifier isEqual:peripheral.identifier];
            }]
            reduceEach:^id(CBCentralManager *central, CBPeripheral *connectedPeripheral, NSError *error) {
                return error;
            }]
            takeUntil:self.rac_willDeallocSignal];

    RACUseDelegateProxy(self);

    @weakify(self)
    return [[RACSignal createSignal:^RACDisposable *(id <RACSubscriber> subscriber) {
        @strongify(self)
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
}

- (RACSignal *)rac_disconnectPeripheralConnection:(CBPeripheral *)peripheral {
    RACSignal *signal = [[[[self.rac_delegateProxy
            signalForSelector:@selector(centralManager:didDisconnectPeripheral:error:)]
            filter:^BOOL(RACTuple *tuple) {
                RACTupleUnpack(CBCentralManager *_, CBPeripheral *disconnectedPeripheral, NSError *__) = tuple;
                return [disconnectedPeripheral.identifier isEqual:peripheral.identifier];
            }]
            reduceEach:^id(CBCentralManager *central, CBPeripheral *disconnectedPeripheral, NSError *error) {
                return error ?: disconnectedPeripheral;
            }]
            takeUntil:self.rac_willDeallocSignal];

    @weakify(self)
    return [[RACSignal createSignal:^RACDisposable *(id <RACSubscriber> subscriber) {
        @strongify(self)
        RACDisposable *disposable = [signal subscribeNext:^(id value) {
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
}

@end
