#import <Foundation/Foundation.h>

@interface PermissionChecker : NSObject

+(BOOL) checkSignedUserWithAlert: (NSString*)deparment order:(NSString*)order permission:(NSString*)permission;

+(BOOL) checkSignedUser: (NSString*)deparment order:(NSString*)order permission:(NSString*)permission;

+(BOOL) check:(NSString*)username department:(NSString*)deparment order:(NSString*)order permission:(NSString*)permission;

@end
