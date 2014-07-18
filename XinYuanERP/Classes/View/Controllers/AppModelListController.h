#import "AppRefreshTableViewController.h"


// For Single Department,  Single Order
@interface AppModelListController : AppRefreshTableViewController

@property (assign) int amounts;                     // the current visible count
@property (assign) int currentRow;
@property (assign) NSIndexPath* selectedRealIndexPath;


#pragma mark - Public Methods
-(void) getNextRow: (int)idIndex handler:(void(^)(id identification))handler;
-(void) getPreviousRow: (int)idIndex handler:(void(^)(id identification))handler;

@end
