//
//  KVOObserver.h
//  XinYuanERP
//
//  Created by Xinyuan4 on 14-7-9.
//  Copyright (c) 2014年 Xinyuan4. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^THObserverBlock)(void);
typedef void(^THObserverBlockWithOldAndNew)(id oldValue, id newValue);
typedef void(^THObserverBlockWithChangeDictionary)(NSDictionary *change);

static NSMutableDictionary *observerQueue;

@interface KVOObserver : NSObject



#pragma mark -
#pragma mark Block-based observers.


+ (void)observerForObject:(id)object
                keyPath:(NSString *)keyPath
                  block:(THObserverBlock)block;

+ (void)observerForObject:(id)object
                keyPath:(NSString *)keyPath
         oldAndNewBlock:(THObserverBlockWithOldAndNew)block;

+ (void)observerForObject:(id)object
                keyPath:(NSString *)keyPath
                options:(NSKeyValueObservingOptions)options
            changeBlock:(THObserverBlockWithChangeDictionary)block;



#pragma mark -
#pragma mark Lifetime management

- (void)stopObserving;

@end
