#import "ClientController.h"
#import "AppInterface.h"

@implementation ClientController

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
    JRRefreshTableView* contractTableView = (JRRefreshTableView*)[jsonView getView:@"NESTED_CONTRACT.CONTRACT_TABLE"];
    JRRefreshTableView* borrowoutTableView = (JRRefreshTableView*)[jsonView getView:@"NESTED_BORROWOUT.BORROWOUT_TABLE"];
    JRRefreshTableView* consultTableView = (JRRefreshTableView*)[jsonView getView:@"NESTED_CONSULT.CONSULT_TABLE"];
    
    self.didShowTabView = ^void(int index, JsonDivView* tabView) {
        // Contract
        if (index == 1) {
            contractTableView.tableView.contentsDictionary = [NSMutableDictionary dictionaryWithDictionary:@{@"aaaa":@[@"Loading", @"fdsafda"]}];
            [contractTableView reloadTableData];
        // Lend Out Staff
        } else if(index == 2) {
            borrowoutTableView.tableView.contentsDictionary = [NSMutableDictionary dictionaryWithDictionary:@{@"aaaa":@[@"fadsaf", @"Loading"]}];
            [borrowoutTableView reloadTableData];
        } else if (index == 3) {
            consultTableView.tableView.contentsDictionary = [NSMutableDictionary dictionaryWithDictionary:@{@"aaaa":@[@"Fecthing", @"bbbbbb"]}];
            [consultTableView reloadTableData];
        }
    };
    
}

@end
