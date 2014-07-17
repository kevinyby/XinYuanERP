//
//  NSMutableDictionary+Operation.m
//  XinYuanERP
//
//  Copyright (c) 2013年 Xinyuan4. All rights reserved.
//

#import "NSMutableDictionary+Operation.h"

@implementation NSMutableDictionary (Operation)

- (BOOL)boolForKey:(id)aKey
{
    return [[self objectForKey:aKey]boolValue];
}
- (void)setBool:(BOOL)anObject forKey:(id <NSCopying>)aKey
{
    [self setObject:[NSNumber numberWithBool:anObject] forKey:aKey];
}

- (NSInteger)integerForKey:(id)aKey
{
    return [[self objectForKey:aKey]integerValue];
}
- (void)setInteger:(NSInteger)anObject forKey:(id <NSCopying>)aKey
{
    [self setObject:[NSNumber numberWithInteger:anObject] forKey:aKey];
}

- (float)floatForKey:(id)aKey
{
    return [[self objectForKey:aKey]floatValue];
}
- (void)setFloat:(float)anObject forKey:(id <NSCopying>)aKey
{
    [self setObject:[NSNumber numberWithFloat:anObject] forKey:aKey];
}


@end
