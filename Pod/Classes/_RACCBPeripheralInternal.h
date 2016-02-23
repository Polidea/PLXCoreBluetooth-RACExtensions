#import <Foundation/Foundation.h>

@class RACDelegateProxy;
@class RACSignal;

@interface _RACCBPeripheralInternal : NSObject
@property(nonatomic, strong, readonly) RACSignal *rac_peripheralDidReadRSSI;

- (instancetype)initWithDelegateProxy:(RACDelegateProxy *)proxy;

@end
