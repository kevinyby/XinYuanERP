#import "AppSearchTableViewController.h"
#import "AppInterface.h"

@interface AppSearchTableViewController () 

@end

@implementation AppSearchTableViewController

@synthesize headerTableView;

-(id)init {
    self = [super init];
    if (self) {
        self.automaticallyAdjustsScrollViewInsets = NO;
        headerTableView = [[JRRefreshTableView alloc] init];
        headerTableView.headerLabelClass = [JRLocalizeLabel class];
        [headerTableView.searchBar setHiddenCancelButton: YES];
        headerTableView.tableView.proxy = self;
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    if (! self.isMovingToParentViewController) {        // pop
        if (self.isPopNeedRefreshRequest) {
            [self requestForDataFromServer];
        }
    } else {                                            // push
        if (self.requestModel) {
            [self requestForDataFromServer];
        }
    }
    
    self.isPopNeedRefreshRequest = NO;
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    [self.view addSubview:headerTableView];
    [self initializeSubViewConstraints];
}

-(void) requestForDataFromServer
{
    if (! self.requestModel) return;
    if (! VIEW.isProgressShowing) {
        [VIEW.progress show];
        VIEW.progress.labelText = nil;
        VIEW.progress.detailsLabelText = nil;
    }
    [DATA.requester startPostRequestWithAlertTips:self.requestModel completeHandler:^(HTTPRequester* requester, ResponseJsonModel *data, NSHTTPURLResponse *httpURLReqponse, NSError *error) {
        [self didReceiveDataFromServer: data error:error];
        if (VIEW.progress.labelText == nil && VIEW.progress.detailsLabelText == nil) {
            [VIEW.progress hide];
        }
    }];
}
-(void) didReceiveDataFromServer: (ResponseJsonModel*)data error:(NSError*)error
{
    if (data.status) {
        // load the data to view
        [ListViewControllerHelper assembleTableContents: self.headerTableView.tableView objects:data.results keys:data.models filter:self.contentsFilter];
        [self reloadTableData];
    } else {
        // TO DO LIST
    }
}


#pragma mark - Public Methods

-(void) reloadTableData {
    headerTableView.tableView.filterText = headerTableView.tableView.filterText;
}

-(NSArray*) sections {
    return self.headerTableView.tableView.sections;
}

-(void)setHeaders:(NSArray *)headers
{
    _headers = headers;
    self.headerTableView.headers = [LocalizeHelper localize: headers];
}

-(void)setHeadersXcoordinates:(NSArray *)headersXcoordinates
{
    _headersXcoordinates = headersXcoordinates;
    self.headerTableView.headersXcoordinates = headersXcoordinates;
}

-(void)setValuesXcoordinates:(NSArray *)valuesXcoordinates
{
    _valuesXcoordinates = valuesXcoordinates;
    self.headerTableView.valuesXcoordinates = valuesXcoordinates;
}

-(NSMutableDictionary*) realContentsDictionary
{
    return headerTableView.tableView.realContentsDictionary;
}

-(void) setRealContentsDictionary:(NSMutableDictionary *)realContentsDictionary
{
    headerTableView.tableView.realContentsDictionary = realContentsDictionary;
}

-(NSMutableDictionary*) contentsDictionary
{
    return headerTableView.tableView.contentsDictionary;
}

-(void) setContentsDictionary:(NSMutableDictionary *)contentsDictionary
{
    headerTableView.tableView.contentsDictionary = contentsDictionary;
}

#pragma mark - TableViewBaseTableProxy
- (void)tableViewBase:(TableViewBase *)tableViewObj didSelectIndexPath:(NSIndexPath*)indexPath
{
    if (self.appTableDidSelectRowBlock) self.appTableDidSelectRowBlock(self, indexPath);
}

- (void)tableViewBase:(TableViewBase *)tableViewObj willShowCell:(UITableViewCell*)cell indexPath:(NSIndexPath*)indexPath
{
    if (self.willShowCellBlock) self.willShowCellBlock(self, indexPath, cell);
}

- (NSString*)tableViewBase:(TableViewBase *)tableViewObj titleForDeleteButtonAtIndexPath:(NSIndexPath*)indexPath
{
    return LOCALIZE_KEY(KEY_DELETE);
}

#pragma mark - Public Methods
-(id) valueForIndexPath: (NSIndexPath*)indexPath
{
    return [headerTableView.tableView realContentForIndexPath: indexPath];
}

-(id) getIdentification: (NSIndexPath*)indexPath {
    return [[self valueForIndexPath: indexPath] firstObject];
}


#pragma mark - Private Methods
-(void) initializeSubViewConstraints
{
    [headerTableView setTranslatesAutoresizingMaskIntoConstraints: NO];
    float barHeight = VIEW.navigator.navigationBar.frame.size.height;
    [self.view addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat:@"|-0-[headerTableView]-0-|"
                               options:NSLayoutFormatAlignAllTrailing
                               metrics:nil
                               views:NSDictionaryOfVariableBindings(headerTableView)]];
    [self.view addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat:@"V:|-(barHeight)-[headerTableView]-0-|"
                               options:NSLayoutFormatAlignAllTrailing
                               metrics:@{@"barHeight":@(barHeight)}
                               views:NSDictionaryOfVariableBindings(headerTableView)]];
}



@end