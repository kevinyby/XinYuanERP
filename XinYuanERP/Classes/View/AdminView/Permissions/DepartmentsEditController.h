#import "AppWheelViewController.h"

@interface DepartmentsEditController : AppWheelViewController


@property (strong) NSString* userNumber;




#pragma mark - Class Methods

+(void) saveUserPermissions: (NSString*)userNumber categories:(NSMutableArray*)categories permissions:(NSMutableDictionary*)permissions completion:(void(^)(NSError* error))completion;;
@end
