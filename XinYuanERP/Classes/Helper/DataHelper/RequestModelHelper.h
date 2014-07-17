#import <Foundation/Foundation.h>

@interface RequestModelHelper : NSObject

+ (NSDictionary*) getModelIdentities: (id)identification;
+ (id) getModelIdentification: (NSDictionary*)identities;

+ (NSString*)criterialBetweenDate: (NSDate*)fromDate toDate:(NSDate*)toDate;

+ (NSString*)criterialBetween: (NSString*)fromString to:(NSString*)toString;

@end
