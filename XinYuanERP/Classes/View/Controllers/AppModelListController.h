#import "AppSearchTableViewController.h"


@interface AppModelListController : AppSearchTableViewController <RefreshTableViewDelegate>


#pragma mark - Public Methods

-(void) getNextRow: (int)idIndex handler:(void(^)(id identification))handler;
-(void) getPreviousRow: (int)idIndex handler:(void(^)(id identification))handler;

@end
