#import "CBCentralManager+PLXRACExtensions.h"

@implementation CBCentralManager (PLXRACExtensions)

- (RACSignal *)rac_isPoweredOn {
    return nil;
}

- (RACSignal *)rac_scanForPeripheralsWithServices:(NSArray<CBUUID *> *)serviceUUIDs count:(NSInteger)count options:(NSDictionary<NSString *, id> *)options {
    return nil;
}

- (RACSignal *)rac_connectPeripheral:(CBPeripheral *)peripheral options:(NSDictionary<NSString *, id> *)options {
    return nil;
}

- (RACSignal *)rac_disconnectPeripheralConnection:(CBPeripheral *)peripheral {
    return nil;
}

@end
