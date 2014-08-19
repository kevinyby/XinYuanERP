#import "AppSearchTableViewController.h"


@interface AppModelListController : AppSearchTableViewController <RefreshTableViewDelegate>


@property (assign) int amounts;                     // the current visible count
@property (assign) int currentRow;


#pragma mark - Public Methods

-(void) getNextRow: (int)idIndex handler:(void(^)(id identification))handler;
-(void) getPreviousRow: (int)idIndex handler:(void(^)(id identification))handler;

@end
