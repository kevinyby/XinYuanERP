#import <Foundation/Foundation.h>

@interface AppDropboxExporter : NSObject


+(void) exportDb:(NSString*)model department:(NSString*)department object:(NSDictionary*)object ;

+(BOOL) exportDb:(NSString*)model department:(NSString*)department dictionary:(NSDictionary*)dictionary ;

@end
