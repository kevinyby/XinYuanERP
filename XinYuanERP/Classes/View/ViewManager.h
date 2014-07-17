#import <Foundation/Foundation.h>

#define VIEW [ViewManager getInstance]

@class MBProgressHUD;
@class AppNavigationViewController;

@interface ViewManager : NSObject


@property (strong, readonly) UIWindow* window;
@property (strong, readonly) AppNavigationViewController* navigator;
@property (strong, readonly) MBProgressHUD* progress;
@property (assign) BOOL isProgressShowing;


+(ViewManager*) getInstance ;

-(void) showBootViewController;
-(void) showLoginViewController;
-(void) showApnsAlertWithContents: (NSDictionary*)userInfo;


#pragma mark - Test
-(BOOL) isTestDevice;

@end
