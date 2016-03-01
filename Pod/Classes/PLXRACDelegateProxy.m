#import <objc/runtime.h>
#import "PLXRACDelegateProxy.h"

@implementation PLXRACDelegateProxy

- (BOOL)respondsToSelector:(SEL)aSelector {
    Ivar ivar = class_getInstanceVariable([self class], "_protocol");
    Protocol *protocol = object_getIvar(self, ivar);

    BOOL containOptionalSelector = [self doesProtocol:protocol containOptionalSelector:aSelector];
    BOOL containRequiredSelector = [self doesProtocol:protocol containRequiredSelector:aSelector];
    return containOptionalSelector || containRequiredSelector;
}

- (BOOL)doesProtocol:(Protocol *)protocol containRequiredSelector:(SEL)aSelector {
    struct objc_method_description optionalMethodDescription = protocol_getMethodDescription(protocol, aSelector, YES, YES);
    return optionalMethodDescription.types != NULL;
}

- (BOOL)doesProtocol:(Protocol *)protocol containOptionalSelector:(SEL)aSelector {
    struct objc_method_description optionalMethodDescription = protocol_getMethodDescription(protocol, aSelector, NO, YES);
    return optionalMethodDescription.types != NULL;
}

@end