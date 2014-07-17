#import "AppModelListController.h"

@interface SetPermissionListController : AppModelListController

@property (assign) NSMutableDictionary* orderPermissions;

- (id)initWithDepartment: (NSString*)department;

@end
