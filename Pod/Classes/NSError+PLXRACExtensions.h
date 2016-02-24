#import <Foundation/Foundation.h>

@interface NSError (PLXRACExtensions)

+ (instancetype)plx_bluetoothOffError;
+ (instancetype)plx_peripheraNotConnectedError;

@end
