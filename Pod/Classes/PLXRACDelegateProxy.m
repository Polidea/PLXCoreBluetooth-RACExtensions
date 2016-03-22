#import <objc/runtime.h>
#import "PLXRACDelegateProxy.h"

@implementation PLXRACDelegateProxy

- (BOOL)respondsToSelector:(SEL)aSelector {
    Ivar ivar = class_getInstanceVariable([self class], "_protocol");
    Protocol *aProtocol = object_getIvar(self, ivar);

    BOOL containOptionalSelector = [self doesProtocol:aProtocol containsOptionalSelector:aSelector];
    BOOL containRequiredSelector = [self doesProtocol:aProtocol containsRequiredSelector:aSelector];
    return containOptionalSelector || containRequiredSelector;
}

- (BOOL)doesProtocol:(Protocol *)aProtocol containsRequiredSelector:(SEL)aSelector {
    struct objc_method_description optionalMethodDescription = protocol_getMethodDescription(aProtocol, aSelector, YES, YES);
    return optionalMethodDescription.types != NULL;
}

- (BOOL)doesProtocol:(Protocol *)aProtocol containsOptionalSelector:(SEL)aSelector {
    struct objc_method_description optionalMethodDescription = protocol_getMethodDescription(aProtocol, aSelector, NO, YES);
    return optionalMethodDescription.types != NULL;
}

@end