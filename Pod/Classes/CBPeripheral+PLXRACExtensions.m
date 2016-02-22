#import "CBPeripheral+PLXRACExtensions.h"

@implementation CBPeripheral (PLXRACExtensions)

- (RACSignal *)rac_name {
    return nil;
}

- (RACSignal *)rac_RSSI {
    return nil;
}

- (RACSignal *)rac_peripheralDidUpdateName {
    return nil;
}

- (RACSignal *)rac_peripheralDidModifyServices {
    return nil;
}

- (RACSignal *)rac_discoverServices:(nullable NSArray<CBUUID *> *)services {
    return nil;
}

- (RACSignal *)rac_readRSSI {
    return nil;
}

- (RACSignal *)rac_discoverIncludedServices:(NSArray<CBUUID *> *)includedServiceUUIDs forService:(CBService *)service {
    return nil;
}

- (RACSignal *)rac_discoverCharacteristics:(NSArray<CBUUID *> *)characteristicUUIDs forService:(CBService *)service {
    return nil;
}

- (RACSignal *)rac_readValueForCharacteristic:(CBCharacteristic *)characteristic {
    return nil;
}

- (RACSignal *)rac_writeValue:(NSData *)data forCharacteristic:(CBCharacteristic *)characteristic writeType:(CBCharacteristicWriteType)writeType {
    return nil;
}

- (RACSignal *)rac_maximumWriteValueLengthForType:(CBCharacteristicWriteType)type {
    return nil;
}

- (RACSignal *)rac_discoverDescriptorsForCharacteristic:(CBCharacteristic *)characteristic {
    return nil;
}

- (RACSignal *)rac_readValueForDescriptor:(CBDescriptor *)descriptor {
    return nil;
}

- (RACSignal *)rac_writeValue:(NSData *)data forDescriptor:(CBDescriptor *)descriptor {
    return nil;
}

- (RACSignal *)rac_setNotifyValue:(BOOL)enabled forChangesInCharacteristic:(CBCharacteristic *)characteristic {
    return nil;
}

- (RACSignal *)rac_setNotifyValue:(BOOL)enabled andGetUpdatesForChangesInCharacteristic:(CBCharacteristic *)characteristic {
    return nil;
}

- (RACSignal *)rac_listenForUpdatesForCharacteristic:(CBCharacteristic *)characteristic {
    return nil;
}

@end
