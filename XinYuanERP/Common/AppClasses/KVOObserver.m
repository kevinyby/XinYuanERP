//
//  KVOObserver.m
//  XinYuanERP
//
//  Created by Xinyuan4 on 14-7-9.
//  Copyright (c) 2014年 Xinyuan4. All rights reserved.
//

#import "KVOObserver.h"

typedef enum THObserverBlockArgumentsKind {
    THObserverBlockArgumentsNone,
    THObserverBlockArgumentsOldAndNew,
    THObserverBlockArgumentsChangeDictionary
} THObserverBlockArgumentsKind;

@interface KVOObserver()
{
    NSString *_keyPath;
    dispatch_block_t _block;
    
    __unsafe_unretained id _observedObject;
}

@end

@implementation KVOObserver

+(void)initialize
{
    if (!observerQueue) {
        observerQueue = [NSMutableDictionary dictionary];
    }
}

- (id)initForObject:(id)object
            keyPath:(NSString *)keyPath
            options:(NSKeyValueObservingOptions)options
              block:(dispatch_block_t)block
 blockArgumentsKind:(THObserverBlockArgumentsKind)blockArgumentsKind
{
    if((self = [super init])) {
        if(!object || !keyPath || !block) {
            [NSException raise:NSInternalInconsistencyException format:@"Observation must have a valid object (%@), keyPath (%@) and block(%@)", object, keyPath, block];
            self = nil;
        } else {
            _observedObject = object;
            _keyPath = [keyPath copy];
            _block = [block copy];
            
            [_observedObject addObserver:self
                              forKeyPath:_keyPath
                                 options:options
                                 context:(void *)blockArgumentsKind];
        }
    }
    return self;
}

- (void)dealloc
{
    if(_observedObject) {
        [self stopObserving];
    }
    NSLog(@"observerQueue dealloc");
    [observerQueue removeAllObjects];
    observerQueue = nil;
}

- (void)stopObserving
{
    [_observedObject removeObserver:self forKeyPath:_keyPath];
    _block = nil;
    _keyPath = nil;
    _observedObject = nil;
}

-(void) observeValueForKeyPath:(NSString*)keyPath ofObject:(id)object change:(NSDictionary*)change context:(void*)context
{
    switch((THObserverBlockArgumentsKind)context) {
        case THObserverBlockArgumentsNone:
        ((THObserverBlock)_block)();
        break;
        case THObserverBlockArgumentsOldAndNew:
        ((THObserverBlockWithOldAndNew)_block)(change[NSKeyValueChangeOldKey], change[NSKeyValueChangeNewKey]);
        break;
        case THObserverBlockArgumentsChangeDictionary:
        ((THObserverBlockWithChangeDictionary)_block)(change);
        break;
        default:
        [NSException raise:NSInternalInconsistencyException format:@"%s called on %@ with unrecognised context (%p)", __func__, self, context];
    }
}


#pragma mark -
#pragma mark Block-based observer construction.

+ (void)observerForObject:(id)object
                keyPath:(NSString *)keyPath
                  block:(THObserverBlock)block
{
    KVOObserver* observer = [[self alloc] initForObject:object
                                                keyPath:keyPath
                                                options:0
                                                  block:(dispatch_block_t)block
                                     blockArgumentsKind:THObserverBlockArgumentsNone];
    
    NSString *key = [NSString stringWithFormat:@"%@_%@", object, keyPath];
    [observerQueue setObject:observer forKey:key];
    
}

+ (void)observerForObject:(id)object
                keyPath:(NSString *)keyPath
         oldAndNewBlock:(THObserverBlockWithOldAndNew)block
{
   KVOObserver* observer = [[self alloc] initForObject:object
                               keyPath:keyPath
                               options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew
                                 block:(dispatch_block_t)block
                    blockArgumentsKind:THObserverBlockArgumentsOldAndNew];
    
    NSString *key = [NSString stringWithFormat:@"%@_%@", object, keyPath];
    [observerQueue setObject:observer forKey:key];
}

+ (void)observerForObject:(id)object
                keyPath:(NSString *)keyPath
                options:(NSKeyValueObservingOptions)options
            changeBlock:(THObserverBlockWithChangeDictionary)block
{
    KVOObserver* observer = [[self alloc] initForObject:object
                               keyPath:keyPath
                               options:options
                                 block:(dispatch_block_t)block
                    blockArgumentsKind:THObserverBlockArgumentsChangeDictionary];
    
    NSString *key = [NSString stringWithFormat:@"%@_%@", object, keyPath];
    [observerQueue setObject:observer forKey:key];
}




@end
