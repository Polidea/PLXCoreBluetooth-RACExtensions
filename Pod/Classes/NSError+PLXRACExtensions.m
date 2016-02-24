#import "NSError+PLXRACExtensions.h"


@implementation NSError (PLXRACExtensions)

+ (instancetype)plx_bluetoothOffError {
    return [NSError errorWithDomain:@"com.polidea.PLXRACExtensions" code:-1610 userInfo:@{
            NSLocalizedDescriptionKey : @"Bluetooth is turned off",
            NSLocalizedFailureReasonErrorKey : @"CBCentralManager state is not CBCentralManagerStatePoweredOn"
    }];
}

@end
