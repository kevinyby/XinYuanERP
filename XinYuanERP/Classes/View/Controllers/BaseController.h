#import <UIKit/UIKit.h>

@class BaseController;

typedef void(^BaseControllerViewDidLoadBlock)(BaseController* controller);
typedef void(^BaseControllerViewWillAppearBlock)(BaseController* controller, BOOL animated);
typedef void(^BaseControllerViewDidAppearBlock)(BaseController* controller, BOOL animated);
typedef void(^BaseControllerViewDidDisappearBlock)(BaseController* controller, BOOL animated);

@interface BaseController : UIViewController

@property (copy) BaseControllerViewDidLoadBlock viewDidLoadBlock;
@property (copy) BaseControllerViewWillAppearBlock viewWillAppearBlock;
@property (copy) BaseControllerViewDidAppearBlock viewDidAppearBlock;
@property (copy) BaseControllerViewDidDisappearBlock viewDidDisappearBlock;

@end
