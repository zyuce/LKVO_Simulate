//
//  LObserver.m
//  KVO_Simulate
//
//  Created by liangce on 16/10/20.
//  Copyright © 2016年 liangce. All rights reserved.
//

#import "LObserver.h"
#import "Person.h"
#import "NSObject+LKVO.h"

@interface LObserver()

@property (nonatomic, strong) Person *person;

@end

@implementation LObserver

- (instancetype)init {
    self = [super init];
    if (self) {

    }
    
    return self;
}

- (void)l_observingWithKeyPath:(NSString *)keyPath object:(NSObject *)observed change:(NSDictionary *)change {
    NSLog(@"l_observingWithKeyPath:object:change: method has been invoked.");
}

@end
