#import "RACSignal+PLXBluetoothRACUtilities.h"
#import "RACSubscriber.h"

@implementation RACSignal (PLXBluetoothRACUtilities)

+ (RACSignal *)plx_createSignalSubscribedTo:(RACSignal *)signal withAction:(void (^)())action {
    NSParameterAssert(action);
    return [RACSignal createSignal:^RACDisposable *(id <RACSubscriber> subscriber) {
        RACDisposable *disposable = [signal subscribe:subscriber];
        action();
        return disposable;
    }];
}

- (RACSignal *)plx_flattenMapNextToErrorIfNeeded {
    return [self flattenMap:^RACSignal *(id value) {
        return [value isKindOfClass:[NSError class]] ? [RACSignal error:value] : [RACSignal return:value];
    }];
}

- (RACSignal *)plx_singleValue {
    return [RACSignal createSignal:^RACDisposable *(id <RACSubscriber> subscriber) {
        return [self subscribeNext:^(id next) {
            [subscriber sendNext:next];
            [subscriber sendCompleted];
        }             error:^(NSError *error) {
            [subscriber sendError:error];
        }];
    }];
}

@end
