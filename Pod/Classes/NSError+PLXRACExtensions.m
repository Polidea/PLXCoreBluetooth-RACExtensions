#import "NSError+PLXRACExtensions.h"


@implementation NSError (PLXRACExtensions)

+ (instancetype)plx_bluetoothOffError {
    return [NSError errorWithDomain:@"com.polidea.PLXRACExtensions" code:-1610 userInfo:@{
            NSLocalizedDescriptionKey : @"Bluetooth is turned off",
            NSLocalizedFailureReasonErrorKey : @"CBCentralManager state is not CBCentralManagerStatePoweredOn"
    }];
}

+ (instancetype)plx_peripheraNotConnectedError {
    return [NSError errorWithDomain:@"com.polidea.PLXRACExtensions" code:-1610 userInfo:@{
            NSLocalizedDescriptionKey : @"Peripheral is not connected",
            NSLocalizedFailureReasonErrorKey : @"CBPeripheral state is not CBPeripheralStateConnected"
    }];
}

@end
