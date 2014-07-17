#import "FinanceAccountController.h"
#import "AppInterface.h"

@interface FinanceAccountController ()

@end

@implementation FinanceAccountController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    JsonView* jsonView = self.jsonView;
    
    //----------- Another Tabs Views
    JRRefreshTableView* detailsTableView = (JRRefreshTableView*)[jsonView getView:@"NESTED_DETAILS.DETAILS_TABLE"];

//    detailsTableView.tableView.tableFooterView = nil;
    
    self.didShowTabView = ^void(int index, JsonDivView* tabView) {
        // Contract
        if (index == 1) {
            detailsTableView.tableView.contentsDictionary = [NSMutableDictionary dictionaryWithDictionary:@{@"aaaa":@[@"Loading", @"fdsafda"]}];
            [detailsTableView reloadTableData];
            // Lend Out Staff
        }
    };
}



@end
