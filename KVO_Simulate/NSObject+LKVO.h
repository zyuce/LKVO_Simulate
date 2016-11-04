//
//  NSObject+LKVO.h
//  KVO_Simulate
//
//  Created by liangce on 16/10/11.
//  Copyright © 2016年 liangce. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (LKVO)

- (void)l_addObserver:(NSObject *)observer withKeyPath:(NSString *)keyPath;

- (void)l_observingWithKeyPath:(NSString *)keyPath object:(NSObject *)observed change:(NSDictionary *)change;

- (void)l_removeObserver:(NSObject *)observer keyPath:(NSString *)keyPath;

@end
