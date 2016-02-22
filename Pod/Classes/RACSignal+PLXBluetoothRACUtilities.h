#import <Foundation/Foundation.h>
#import "RACSignal.h"

@interface RACSignal (PLXBluetoothRACUtilities)

/// Return signal that subscribes to the given signal before performing an action.
+ (RACSignal *)plx_createSignalSubscribedTo:(RACSignal *)signal withAction:(void (^)())action;

/// Gets very first `next` from the receiver, forwards it and completes.
/// Error is passed as usual.
- (RACSignal *)plx_singleValue;

/// If `next` in the receiver is an NSError it returns signal with error.
- (RACSignal *)plx_flattenMapNextToErrorIfNeeded;
@end
