#import "_RACCBPeripheralInternal.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <ReactiveCocoa/RACDelegateProxy.h>

@interface _RACCBPeripheralInternal ()
@property(nonatomic, weak, readonly) RACDelegateProxy *proxy;
@end

@implementation _RACCBPeripheralInternal

- (instancetype)initWithDelegateProxy:(RACDelegateProxy *)proxy {
    self = [super init];
    if (self) {
        _proxy = proxy;
        _rac_peripheralDidReadRSSI = [self createPeripheralDidReadRSSISignal];
    }
    return self;
}

- (RACSignal *)createPeripheralDidReadRSSISignal {
    return [[self.proxy
            signalForSelector:@selector(peripheral:didReadRSSI:error:)]
            takeUntil:self.rac_willDeallocSignal];
}

@end
