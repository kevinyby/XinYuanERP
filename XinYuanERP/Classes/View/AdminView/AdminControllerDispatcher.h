#import <Foundation/Foundation.h>

@class AppWheelViewController;
@class AppSearchTableViewController;

@interface AdminControllerDispatcher : NSObject

+(AppSearchTableViewController*) dispatchToUsersList;
+(AppWheelViewController*) dispatchToDepartmentsWheel;
+(UIViewController*) dispatchToDropboxController;
+(UIViewController*) dispatchToOtherSettingsController;

@end
