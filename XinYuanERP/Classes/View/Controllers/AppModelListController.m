#import "AppModelListController.h"
#import "AppInterface.h"

#define HeaderHeight 50

@implementation AppModelListController


-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    // ... in filter mode selected error occured
    if (!self.headerTableView.tableView.isInFilteringMode && self.currentRow) {
        NSIndexPath* currentIndexPath = [NSIndexPath indexPathForRow:self.currentRow inSection: 0];
        [self.headerTableView.tableView selectRowAtIndexPath:currentIndexPath animated:YES scrollPosition:UITableViewScrollPositionMiddle];
    }
    
}

#pragma mark - Public Mthods

-(void) getPreviousRow: (int)idIndex handler:(void(^)(id identification))handler
{
    int temp = self.currentRow - 1;
    id identifier = nil;
    if (temp >= 0) {
        self.currentRow = temp;
        identifier = [self getCurrentIdentification: idIndex];
    }
    handler(identifier);
}

-(void) getNextRow: (int)idIndex handler:(void(^)(id identification))handler
{
    int temp = self.currentRow + 1;
    if (temp < self.amounts) {
        self.currentRow = temp;
        id identifier = [self getCurrentIdentification: idIndex];
        handler(identifier);
    } else {
        [AppRefreshTableViewController compareToSendModelRefreshRequest:self.headerTableView filter:self.contentsFilter requestModel:self.requestModel isTop:NO completion:^(BOOL isNoNewData) {
            if (isNoNewData) {
                handler(nil);
            } else {
                self.currentRow = temp;
                id identifier = [self getCurrentIdentification: idIndex];
                handler(identifier);
            }
            
            // update amounts
            self.amounts = [[self.headerTableView.tableView realContentsForSection: 0] count];
        }];
    }
}

#pragma mark - Private Methods

-(id) getCurrentIdentification: (int)idIndex
{
    NSIndexPath* currentIndexPath = [NSIndexPath indexPathForRow:self.currentRow inSection: 0];
    NSArray* values = [self valueForIndexPath: currentIndexPath];
    id identifier = [values objectAtIndex:idIndex];
    return identifier;
}


#pragma mark - Override Super Class Methods

-(void) appSearchTableViewController: (AppSearchTableViewController*)controller didSelectIndexPath:(NSIndexPath*)indexPath
{
    self.currentRow = indexPath.row;
    // update amounts
    self.amounts = [[self.headerTableView.tableView realContentsForSection: 0] count];
    
    // call super
    [super appSearchTableViewController:controller didSelectIndexPath:indexPath];
}


@end
