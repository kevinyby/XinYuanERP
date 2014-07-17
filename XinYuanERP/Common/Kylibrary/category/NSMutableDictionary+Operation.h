
#import <Foundation/Foundation.h>

@interface NSMutableDictionary (Operation)

- (BOOL)boolForKey:(id)aKey;
- (void)setBool:(BOOL)anObject forKey:(id <NSCopying>)aKey;

- (NSInteger)integerForKey:(id)aKey;
- (void)setInteger:(NSInteger)anObject forKey:(id <NSCopying>)aKey;

- (float)floatForKey:(id)aKey;
- (void)setFloat:(float)anObject forKey:(id <NSCopying>)aKey;

@end
