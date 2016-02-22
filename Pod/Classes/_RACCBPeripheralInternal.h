#import <Foundation/Foundation.h>
#import "ReactiveCocoa.h"

@class RACDelegateProxy;

@interface _RACCBPeripheralInternal : NSObject
@property(nonatomic, strong, readonly) RACSignal *rac_peripheralDidReadRSSI;

- (instancetype)initWithDelegateProxy:(RACDelegateProxy *)proxy;

@end
