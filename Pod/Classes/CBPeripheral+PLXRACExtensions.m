#import <objc/runtime.h>
#import "CBPeripheral+PLXRACExtensions.h"
#import "_RACCBPeripheralInternal.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <ReactiveCocoa/RACDelegateProxy.h>
#import "RACSignal+PLXBluetoothRACUtilities.h"
#import "NSError+PLXRACExtensions.h"

@interface CBPeripheral ()
@property(nonatomic, strong, readonly) _RACCBPeripheralInternal *_rac_internal;
@end

@implementation CBPeripheral (PLXRACExtensions)

static void RACUseDelegateProxy(CBPeripheral *self) {
    if (self.delegate == self.rac_delegateProxy) return;

    self.rac_delegateProxy.rac_proxiedDelegate = self.delegate;
    self.delegate = (id) self.rac_delegateProxy;
}

- (RACDelegateProxy *)rac_delegateProxy {
    RACDelegateProxy *proxy = objc_getAssociatedObject(self, _cmd);
    if (proxy == nil) {
        proxy = [[RACDelegateProxy alloc] initWithProtocol:@protocol(CBPeripheralDelegate)];
        objc_setAssociatedObject(self, _cmd, proxy, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return proxy;
}

- (_RACCBPeripheralInternal *)_rac_internal {
    _RACCBPeripheralInternal *internal = objc_getAssociatedObject(self, _cmd);
    if (internal == nil) {
        internal = [[_RACCBPeripheralInternal alloc] initWithDelegateProxy:self.rac_delegateProxy];
    }
    return internal;
}

- (BOOL)plx_shouldWaitUntilConnected {
    NSNumber *object = objc_getAssociatedObject(self, @selector(plx_shouldWaitUntilConnected));
    if (!object) {
        self.plx_shouldWaitUntilConnected = NO;
    }
    return [object boolValue];
}

- (void)setPlx_shouldWaitUntilConnected:(BOOL)plx_shouldWaitUntilConnected {
    objc_setAssociatedObject(self, @selector(plx_shouldWaitUntilConnected), @(plx_shouldWaitUntilConnected), OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (RACSignal *)_plx_performSignalIfConnected:(RACSignal *)signal {
    RACSignal *defaultBehaviorSignal = [RACSignal if:[RACSignal return:@(self.state == CBPeripheralStateConnected)]
                                                then:signal
                                                else:[RACSignal error:[NSError plx_peripheraNotConnectedError]]];

    RACSignal *waitUntinConnectedSignal = [[[[[RACObserve(self, state)
            map:^NSNumber *(NSNumber *state) {
                return @(self.state == CBPeripheralStateConnected);
            }]
            distinctUntilChanged]
            ignore:@NO]
            plx_singleValue]
            flattenMap:^RACSignal *(id _) {
                return defaultBehaviorSignal;
            }];

    return [RACSignal if:[RACSignal return:@(self.plx_shouldWaitUntilConnected)]
                    then:waitUntinConnectedSignal
                    else:defaultBehaviorSignal];
}

- (RACSignal *)rac_name {
    return RACObserve(self, name);
}

- (RACSignal *)rac_peripheralDidUpdateName {
    RACUseDelegateProxy(self);
    return [[[self.rac_delegateProxy
            signalForSelector:@selector(peripheralDidUpdateName:)]
            takeUntil:self.rac_willDeallocSignal]
            map:^id(CBPeripheral *peripheral) {
                return peripheral.name;
            }];
}

- (RACSignal *)rac_peripheralDidModifyServices {
    RACUseDelegateProxy(self);
    return [[[self.rac_delegateProxy
            signalForSelector:@selector(peripheral:didModifyServices:)]
            takeUntil:self.rac_willDeallocSignal]
            reduceEach:^id(CBPeripheral *peripheral, NSArray<CBService *> *invalidatedServices) {
                return invalidatedServices;
            }];
}

- (RACSignal *)rac_discoverServices:(nullable NSArray<CBUUID *> *)services {
    RACSignal *delegateSignal = [[[self.rac_delegateProxy
            signalForSelector:@selector(peripheral:didDiscoverServices:)]
            takeUntil:self.rac_willDeallocSignal]
            reduceEach:^id(CBPeripheral *peripheral, NSError *error) {
                return error ?: peripheral.services;
            }];

    RACUseDelegateProxy(self);
    @weakify(self)
    RACSignal *discoverSignal = [[RACSignal
            plx_createSignalSubscribedTo:delegateSignal withAction:^{
                @strongify(self)
                [self discoverServices:services];
            }]
            plx_flattenMapNextToErrorIfNeeded];
    return [self _plx_performSignalIfConnected:discoverSignal];
}

- (RACSignal *)rac_readRSSI {
    RACSignal *delegateSignal = [[self._rac_internal.rac_peripheralDidReadRSSI
            plx_singleValue]
            reduceEach:^id(CBPeripheral *peripheral, NSNumber *RSSI, NSError *error) {
                return error ?: RSSI;
            }];

    RACUseDelegateProxy(self);
    @weakify(self)
    RACSignal *readSignal = [[RACSignal
            plx_createSignalSubscribedTo:delegateSignal withAction:^{
                @strongify(self)
                [self readRSSI];
            }]
            plx_flattenMapNextToErrorIfNeeded];
    return [self _plx_performSignalIfConnected:readSignal];
}

- (RACSignal *)rac_discoverIncludedServices:(NSArray<CBUUID *> *)includedServiceUUIDs forService:(CBService *)service {
    RACSignal *delegateSignal = [[[self.rac_delegateProxy
            signalForSelector:@selector(peripheral:didDiscoverIncludedServicesForService:error:)]
            takeUntil:self.rac_willDeallocSignal]
            reduceEach:^id(CBPeripheral *peripheral, CBService *_service, NSError *error) {
                return error ?: _service.includedServices;
            }];

    RACUseDelegateProxy(self);
    @weakify(self)
    RACSignal *discoverSignal = [[RACSignal
            plx_createSignalSubscribedTo:delegateSignal withAction:^{
                @strongify(self)
                [self discoverIncludedServices:includedServiceUUIDs forService:service];
            }]
            plx_flattenMapNextToErrorIfNeeded];
    return [self _plx_performSignalIfConnected:discoverSignal];
}

- (RACSignal *)rac_discoverCharacteristics:(NSArray<CBUUID *> *)characteristicUUIDs forService:(CBService *)service {
    RACSignal *delegateSignal = [[[self.rac_delegateProxy
            signalForSelector:@selector(peripheral:didDiscoverCharacteristicsForService:error:)]
            takeUntil:self.rac_willDeallocSignal]
            reduceEach:^id(CBPeripheral *peripheral, CBService *_service, NSError *error) {
                return error ?: _service.characteristics;
            }];

    RACUseDelegateProxy(self);
    @weakify(self)
    RACSignal *discoverSignal = [[RACSignal
            plx_createSignalSubscribedTo:delegateSignal withAction:^{
                @strongify(self)
                [self discoverCharacteristics:characteristicUUIDs forService:service];
            }]
            plx_flattenMapNextToErrorIfNeeded];
    return [self _plx_performSignalIfConnected:discoverSignal];
}

- (RACSignal *)rac_readValueForCharacteristic:(CBCharacteristic *)characteristic {
    RACSignal *delegateSignal = [[[self.rac_delegateProxy
            signalForSelector:@selector(peripheral:didUpdateValueForCharacteristic:error:)]
            takeUntil:self.rac_willDeallocSignal]
            reduceEach:^id(CBPeripheral *peripheral, CBCharacteristic *_characteristic, NSError *error) {
                return error ?: _characteristic.value;
            }];

    RACUseDelegateProxy(self);
    @weakify(self)
    RACSignal *readSignal = [[RACSignal
            plx_createSignalSubscribedTo:delegateSignal withAction:^{
                @strongify(self)
                [self readValueForCharacteristic:characteristic];
            }]
            plx_flattenMapNextToErrorIfNeeded];
    return [self _plx_performSignalIfConnected:readSignal];
}

- (RACSignal *)rac_writeValue:(NSData *)data forCharacteristic:(CBCharacteristic *)characteristic writeType:(CBCharacteristicWriteType)writeType {
    if (writeType == CBCharacteristicWriteWithoutResponse) {
        [self writeValue:data forCharacteristic:characteristic type:writeType];
        return [RACSignal return:@YES];
    }

    RACSignal *delegateSignal = [[[self.rac_delegateProxy
            signalForSelector:@selector(peripheral:didWriteValueForCharacteristic:error:)]
            takeUntil:self.rac_willDeallocSignal]
            reduceEach:^id(CBPeripheral *peripheral, CBCharacteristic *_characteristic, NSError *error) {
                return error ?: @YES;
            }];

    RACUseDelegateProxy(self);
    @weakify(self)
    RACSignal *writeSignal = [[RACSignal
            plx_createSignalSubscribedTo:delegateSignal withAction:^{
                @strongify(self)
                [self writeValue:data forCharacteristic:characteristic type:writeType];
            }]
            plx_flattenMapNextToErrorIfNeeded];
    return [self _plx_performSignalIfConnected:writeSignal];
}

- (RACSignal *)rac_discoverDescriptorsForCharacteristic:(CBCharacteristic *)characteristic {
    RACSignal *delegateSignal = [[[self.rac_delegateProxy
            signalForSelector:@selector(peripheral:didDiscoverDescriptorsForCharacteristic:error:)]
            takeUntil:self.rac_willDeallocSignal]
            reduceEach:^id(CBPeripheral *peripheral, CBCharacteristic *_characteristic, NSError *error) {
                return error ?: _characteristic.descriptors;
            }];

    RACUseDelegateProxy(self);
    @weakify(self)
    RACSignal *discoverSignal = [[RACSignal
            plx_createSignalSubscribedTo:delegateSignal withAction:^{
                @strongify(self)
                [self discoverDescriptorsForCharacteristic:characteristic];
            }]
            plx_flattenMapNextToErrorIfNeeded];
    return [self _plx_performSignalIfConnected:discoverSignal];
}

- (RACSignal *)rac_readValueForDescriptor:(CBDescriptor *)descriptor {
    RACSignal *delegateSignal = [[[self.rac_delegateProxy
            signalForSelector:@selector(peripheral:didUpdateValueForDescriptor:error:)]
            takeUntil:self.rac_willDeallocSignal]
            reduceEach:^id(CBPeripheral *peripheral, CBDescriptor *_descriptor, NSError *error) {
                return error ?: _descriptor.value;
            }];

    RACUseDelegateProxy(self);
    @weakify(self)
    RACSignal *readSignal = [[RACSignal
            plx_createSignalSubscribedTo:delegateSignal withAction:^{
                @strongify(self)
                [self readValueForDescriptor:descriptor];
            }]
            plx_flattenMapNextToErrorIfNeeded];
    return [self _plx_performSignalIfConnected:readSignal];
}

- (RACSignal *)rac_writeValue:(NSData *)data forDescriptor:(CBDescriptor *)descriptor {
    RACSignal *delegateSignal = [[[self.rac_delegateProxy
            signalForSelector:@selector(peripheral:didWriteValueForDescriptor:error:)]
            takeUntil:self.rac_willDeallocSignal]
            reduceEach:^id(CBPeripheral *peripheral, CBDescriptor *_descriptor, NSError *error) {
                return error ?: @YES;
            }];

    RACUseDelegateProxy(self);
    @weakify(self)
    RACSignal *writeSignal = [[RACSignal
            plx_createSignalSubscribedTo:delegateSignal withAction:^{
                @strongify(self)
                [self writeValue:data forDescriptor:descriptor];
            }]
            plx_flattenMapNextToErrorIfNeeded];
    return [self _plx_performSignalIfConnected:writeSignal];
}

- (RACSignal *)rac_setNotifyValue:(BOOL)enabled forChangesInCharacteristic:(CBCharacteristic *)characteristic {
    RACSignal *delegateSignal = [[[self.rac_delegateProxy
            signalForSelector:@selector(peripheral:didUpdateNotificationStateForCharacteristic:error:)]
            takeUntil:self.rac_willDeallocSignal]
            reduceEach:^id(CBPeripheral *peripheral, CBCharacteristic *_characteristic, NSError *error) {
                return error ?: @YES;
            }];

    RACUseDelegateProxy(self);
    @weakify(self)
    RACSignal *notifySignal = [[RACSignal
            plx_createSignalSubscribedTo:delegateSignal withAction:^{
                @strongify(self)
                [self setNotifyValue:enabled forCharacteristic:characteristic];
            }]
            plx_flattenMapNextToErrorIfNeeded];
    return [self _plx_performSignalIfConnected:notifySignal];
}

- (RACSignal *)rac_setNotifyValue:(BOOL)enabled andGetUpdatesForChangesInCharacteristic:(CBCharacteristic *)characteristic {
    RACSignal *updateNotificationStateSignal = [[[self.rac_delegateProxy
            signalForSelector:@selector(peripheral:didUpdateNotificationStateForCharacteristic:error:)]
            takeUntil:self.rac_willDeallocSignal]
            reduceEach:^id(CBPeripheral *peripheral, CBCharacteristic *_characteristic, NSError *error) {
                return error ?: @YES;
            }];

    RACSignal *updateValueSignal = [[[self.rac_delegateProxy
            signalForSelector:@selector(peripheral:didUpdateValueForCharacteristic:error:)]
            takeUntil:self.rac_willDeallocSignal]
            reduceEach:^id(CBPeripheral *peripheral, CBCharacteristic *_characteristic, NSError *error) {
                return error ?: _characteristic.value;
            }];

    RACSignal *combinedSignal = [RACSignal combineLatest:@[updateNotificationStateSignal, updateValueSignal]
                                                  reduce:^id(id notificationValue, id characteristicValue) {
                                                      if ([notificationValue isKindOfClass:[NSError class]]) {
                                                          return notificationValue;
                                                      }
                                                      return updateValueSignal;
                                                  }];

    RACUseDelegateProxy(self);
    @weakify(self)
    RACSignal *notifySignal = [[RACSignal
            plx_createSignalSubscribedTo:combinedSignal withAction:^{
                @strongify(self)
                [self setNotifyValue:enabled forCharacteristic:characteristic];
            }]
            plx_flattenMapNextToErrorIfNeeded];
    return [self _plx_performSignalIfConnected:notifySignal];
}

- (RACSignal *)rac_listenForUpdatesForCharacteristic:(CBCharacteristic *)characteristic {
    RACUseDelegateProxy(self);
    RACSignal *listenSignal = [[[[self.rac_delegateProxy
            signalForSelector:@selector(peripheral:didUpdateValueForCharacteristic:error:)]
            takeUntil:self.rac_willDeallocSignal]
            reduceEach:^id(CBPeripheral *peripheral, CBCharacteristic *_characteristic, NSError *error) {
                return error ?: _characteristic.value;
            }]
            map:^id(id value) {
                return [value isKindOfClass:[NSError class]] ? [RACSignal error:value] : [RACSignal return:value];
            }];
    return [self _plx_performSignalIfConnected:listenSignal];
}

@end
