#import "AppRefreshTableViewController.h"


// For Single Department,  Single Order
@interface AppModelListController : AppRefreshTableViewController


@property (strong) NSString* order;                 // order or model
@property (strong) NSString* department;            // departments or categories

@property (assign) int amounts;                     // the current visible count
@property (assign) int currentRow;
@property (assign) NSIndexPath* selectedIndexPath;


#pragma mark - Public Methods
-(void) getNextRow: (int)idIndex handler:(void(^)(id identification))handler;
-(void) getPreviousRow: (int)idIndex handler:(void(^)(id identification))handler;

@end
