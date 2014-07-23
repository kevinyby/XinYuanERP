#import <UIKit/UIKit.h>
#import "DataProvider.h"

@class LoginViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (readonly,strong, nonatomic) NSObject<DataProvider> *Store;

+ (instancetype)sharedDelegate;

@end
