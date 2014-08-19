#import "AppModelListController.h"
#import "AppInterface.h"

#define HeaderHeight 50


@implementation AppModelListController

- (id)init
{
    self = [super init];
    if (self) {
        self.headerTableView.delegate = self;
    }
    return self;
}

#pragma mark - RefreshTableTriggerDelegate

-(void) didTriggeredTopRefresh: (RefreshTableView*)tableView
{
    [DATA.requester startPostRequestWithAlertTips:self.requestModel completeHandler:^(HTTPRequester* requester, ResponseJsonModel *data, NSHTTPURLResponse *httpURLReqponse, NSError *error) {
        if (data.status) {
            // load the data to view
            
            NSArray* keys = data.models;
            NSArray* objects = data.results;
            ContentFilterBlock filter = self.contentsFilter;
            
            AlignTableView* tableViewObj = self.headerTableView.tableView;
            NSMutableDictionary* realContentsDictionary = [TableContentHelper assembleToRealContentDictionary: objects keys:keys];
            tableViewObj.realContentsDictionary = realContentsDictionary;
            NSMutableDictionary* contentsDictionary = [ListViewControllerHelper convertRealToVisualContents: realContentsDictionary filter:filter];
            tableViewObj.contentsDictionary = contentsDictionary;
            
            [self reloadTableData];

            [self.headerTableView doneDownloading: YES];
        }
    }];
    
}
-(void) didTriggeredBottomRefresh: (RefreshTableView *)tableView
{
    [AppModelListController getNextPageData: self.headerTableView filter:self.contentsFilter requestModel:self.requestModel completion:nil];
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
        [AppModelListController getNextPageData:self.headerTableView filter:self.contentsFilter requestModel:self.requestModel completion:^(BOOL isHaveNoNewData) {
            if (isHaveNoNewData) {
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







#pragma mark - Class Methods

+(void) getNextPageData: (JRRefreshTableView*)refreshTableView filter:(ContentFilterBlock)filter requestModel:(RequestJsonModel*)requestModel completion:(void(^)(BOOL isHaveNoNewData))completion
{
    NSMutableArray* limit = [requestModel.limits firstObject];
    int limitPerCount = [[limit lastObject] intValue];
    [limit replaceObjectAtIndex: 0 withObject: @([[limit firstObject] intValue] + limitPerCount)];
    
    [self sendModelRefreshRequest: refreshTableView filter:filter requestModel:requestModel isTop:NO completion:completion];
}

+(void) sendModelRefreshRequest: (JRRefreshTableView*)refreshTableView filter:(ContentFilterBlock)filter requestModel:(RequestJsonModel*)requestModel isTop:(BOOL)isTop completion:(void(^)(BOOL isHaveNoNewData))completion
{
    [DATA.requester startPostRequest: requestModel completeHandler:^(HTTPRequester* requester, ResponseJsonModel *data, NSHTTPURLResponse *httpURLReqponse, NSError *error) {
        
        NSArray* models = data.models;
        NSArray* results = data.results;
        
        // pase the data
        NSMutableDictionary* newPartRealContentDictionary = [TableContentHelper assembleToRealContentDictionary:results keys:models];
        
        // check if empty
        BOOL isHaveNoNewData = YES;
        for (NSString* key in newPartRealContentDictionary) {
            NSArray* contents = newPartRealContentDictionary[key];
            if(contents.count != 0) {
                isHaveNoNewData = NO;
                break;
            }
        }
        
        if (! isHaveNoNewData) {
            // integrate the data
            NSMutableDictionary* realContentsDictionary = refreshTableView.tableView.realContentsDictionary;
            NSArray* insertIndexPaths = [AppTableContentsHelper insertValues: realContentsDictionary partRealContentDictionary:newPartRealContentDictionary isTop:isTop];    // put it before assemble
            
            NSMutableDictionary* contentsDictionary = [ListViewControllerHelper convertRealToVisualContents: realContentsDictionary filter:filter];
            refreshTableView.tableView.contentsDictionary = contentsDictionary;
            
            [ViewHelper tableViewRowInsert: refreshTableView.tableView insertIndexPaths:insertIndexPaths animation:isTop ? UITableViewRowAnimationBottom : UITableViewRowAnimationTop completion:^(BOOL finished) {
                [refreshTableView doneDownloading: isTop];
                [refreshTableView reloadTableData];
            }];
            
        } else {
            [refreshTableView doneDownloading: isTop];
        }
        
        if (completion) completion(isHaveNoNewData);
    }];
}




@end
