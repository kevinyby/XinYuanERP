#import "PermissionChecker.h"
#import "AppInterface.h"

@implementation PermissionChecker

+(BOOL) checkSignedUserWithAlert: (NSString*)department order:(NSString*)order permission:(NSString*)permission
{
    BOOL isHavePermission = [self checkSignedUser:department order:order permission:permission];
    if (!isHavePermission) {
        [PopupViewHelper popAlert:LOCALIZE_KEY(KEY_WARNING) message:LOCALIZE_MESSAGE_FORMAT(@"YouHaveNoPermissionToDo", LOCALIZE_KEY(order), LOCALIZE_KEY(permission)) style:0 actionBlock:nil dismissBlock:nil buttons: LOCALIZE_KEY(@"OK"), nil];
    }
    return isHavePermission;
}

+(BOOL) checkSignedUser: (NSString*)deparment order:(NSString*)order permission:(NSString*)permission
{
    return [self check:DATA.signedUserName department:deparment order:order permission:permission];
}

+(BOOL) check:(NSString*)username department:(NSString*)deparment order:(NSString*)order permission:(NSString*)permission
{
    NSArray* permissions = [[[[DATA.usersNOPermissions objectForKey: username] objectForKey: PERMISSIONS] objectForKey: deparment] objectForKey:order];
    return [permissions containsObject:permission];
}

@end
