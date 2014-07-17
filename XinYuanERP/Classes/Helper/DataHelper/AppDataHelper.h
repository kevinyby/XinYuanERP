#import <Foundation/Foundation.h>


@class RSAEncrypt;


@interface AppDataHelper : NSObject


+(void) refreshServerBasicData: (void(^)(BOOL isSuccess))completeHandler;
+(void) dealWithSignedBasicData: (NSArray*)objects;



+(NSMutableArray*) getAllUserCategoryWheels;
+(NSMutableArray*) getUserCategoryWheels: (NSString*)username;
+(NSMutableArray*) getUserModelWheels: (NSString*)username department:(NSString*)department;


#pragma mark - APNS Contents Generator 
+ (NSMutableDictionary*) getApnsContents: (NSString*)department order:(NSString*)order identities:(NSDictionary*)identities forwardUser:(NSString*)forwardUser alert:(NSString*)alert ;


@end
