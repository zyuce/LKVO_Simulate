//
//  NSObject+LKVO.m
//  KVO_Simulate
//
//  Created by liangce on 16/10/11.
//  Copyright © 2016年 liangce. All rights reserved.
//

#import "NSObject+LKVO.h"
#import <objc/runtime.h>
#import <objc/message.h>

@implementation NSObject (LKVO)

static const char *LKVO_suffix = "LKVO";
static const void *key_associated = &key_associated;

void methodSetter(id self, SEL _cmd, NSObject *newValue) {

    // invoke setter method from superClass
    struct objc_super *super = (struct objc_super *)malloc(sizeof(struct objc_super));
    super->receiver = self;
    super->super_class = class_getSuperclass(object_getClass(self));
    typedef void (*MsgSendType)(struct objc_super*, SEL, NSObject*);
    MsgSendType msgSend = (MsgSendType)objc_msgSendSuper;
    msgSend(super, _cmd, newValue);
    free(super);
    
    // get key path
    NSString *methodName = NSStringFromSelector(_cmd);
    methodName = [methodName substringWithRange:NSMakeRange(3, methodName.length-4)];
    NSString *keyPath = nil;
    if (methodName.length == 1) {
        keyPath = [methodName lowercaseString];
    } else {
        keyPath = [NSString stringWithFormat:@"%@%@", [[methodName substringWithRange:NSMakeRange(0, 1)] lowercaseString], [methodName substringWithRange:NSMakeRange(1, methodName.length-1)]];
    }
    
    // invoke observing method
    NSDictionary *dict = objc_getAssociatedObject(self, key_associated);
    NSArray *array = [dict valueForKey:keyPath];
    if (array && [array isKindOfClass:[NSArray class]]) {
        for (NSObject *obj in array) {
            [obj l_observingWithKeyPath:keyPath object:self change:@{@"newValue":newValue}];
        }
    }
    
}

Class fakeClassMethod(id self, SEL _cmd) {

    Class super_class = class_getSuperclass(object_getClass(self));
    struct objc_super *super = (struct objc_super *)malloc(sizeof(struct objc_super));
    super->receiver = self;
    super->super_class = super_class;
    
    typedef void (*MsgSendType)(struct objc_super*, SEL);
    MsgSendType msgSendType = (MsgSendType)objc_msgSendSuper;
    free(super);
    
    msgSendType(super, _cmd);
    return super_class;
    
}

- (void)l_addObserver:(NSObject *)observer withKeyPath:(NSString *)keyPath {
    
    // 1.create KVO class
    Class obj_class = object_getClass(self);
    char const *class_name = class_getName(obj_class);

    char kvo_class_name[strlen(class_name)+strlen(LKVO_suffix)+1];
    strcpy(kvo_class_name, class_name);
    strcat(kvo_class_name, LKVO_suffix);
    
    Class kvo_class = objc_getClass(kvo_class_name);
    if (!kvo_class) {
        kvo_class = objc_allocateClassPair(obj_class, kvo_class_name, 0);
        objc_registerClassPair(kvo_class);
        
        // 2.override getClass method
        class_replaceMethod(kvo_class, NSSelectorFromString(@"class"), (IMP)fakeClassMethod, "@@:");
        
    }
    
    // 3.replace setter method
    NSString *methodName = [NSString stringWithFormat:@"%@%@", [[keyPath substringWithRange:NSMakeRange(0, 1)] uppercaseString], [keyPath substringWithRange:NSMakeRange(1, keyPath.length-1)]];
    NSString *selName = [NSString stringWithFormat:@"set%@:", methodName];
    SEL selector = NSSelectorFromString(selName);
    class_replaceMethod(kvo_class, selector, (IMP)methodSetter, "v@:@");
    
    // 4.change isa to KVO class
    object_setClass(self, kvo_class);
    
    
    // 5.associate observer with observed
    NSString *keyName = [NSString stringWithFormat:@"%@%@", [[keyPath substringWithRange:NSMakeRange(0, 1)] lowercaseString], [keyPath substringWithRange:NSMakeRange(1, keyPath.length-1)]];
    id dict = objc_getAssociatedObject(self, key_associated);
    NSMutableDictionary *mDict = nil;
    if (dict && [dict isKindOfClass:[NSDictionary class]]) {
        mDict = [[NSMutableDictionary alloc] initWithDictionary:dict];
    } else {
        mDict = [[NSMutableDictionary alloc] init];
    }
    NSMutableArray *array = [mDict valueForKey:keyPath];
    if (!array || ![array isKindOfClass:[NSMutableArray class]]) {
        array = [[NSMutableArray alloc] init];
    }
    if (![array containsObject:observer]) {
        [array addObject:observer];
    }
    [mDict setValue:array forKey:keyName];
    
    objc_setAssociatedObject(self, key_associated, mDict, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
}

- (void)l_observingWithKeyPath:(NSString *)keyPath object:(NSObject *)observed change:(NSDictionary *)change {

}

- (void)l_removeObserver:(NSObject *)observer keyPath:(NSString *)keyPath {
    NSDictionary *dict = objc_getAssociatedObject(self, key_associated);
    NSMutableArray *array = [dict valueForKey:keyPath];
    if (array && [array isKindOfClass:[NSMutableArray class]] && [array containsObject:observer]) {
        [array removeObject:observer];
    }
}

/*
- (void)dealloc {
    NSLog(@"invoke dealloc in NSObject+LKVO.h");
}*/

@end
