//
//  main.m
//  KVO_Simulate
//
//  Created by liangce on 16/10/11.
//  Copyright © 2016年 liangce. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSObject+LKVO.h"
#import "Person.h"
#import "LObserver.h"
#import <objc/message.h>
#import <objc/runtime.h>

int main(int argc, const char * argv[]) {
    @autoreleasepool {

        Person *person = [[Person alloc] init];
        
        LObserver *observer = [[LObserver alloc] init];
        [person l_addObserver:observer withKeyPath:@"name"];
        
        person.name = @"Tom";
        [person l_removeObserver:observer keyPath:@"name"];
        
    }
    return 0;
}
