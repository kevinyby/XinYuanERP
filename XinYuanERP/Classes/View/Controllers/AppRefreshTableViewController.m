#import "AppRefreshTableViewController.h"
#import "AppInterface.h"

@interface AppRefreshTableViewController() <RefreshTableViewDelegate>

@end

@implementation AppRefreshTableViewController
{
    BOOL flag ;
}


- (id)init
{
    self = [super init];
    if (self) {
        self.headerTableView.delegate = self;
        flag = NO;
    }
    return self;
}

#pragma mark - Override Super Class Methods

-(void)requestForDataFromServer
{
    if (! flag) {
        flag = YES;
        [AppRefreshTableViewController checkAndAddSortedLimitsColumn: self.requestModel];
    }
    [super requestForDataFromServer];
}

#pragma mark - RefreshTableTriggerDelegate

-(void) didTriggeredTopRefresh: (RefreshTableView*)tableView
{
    [AppRefreshTableViewController compareToSendModelRefreshRequest:self.headerTableView filter:self.contentsFilter requestModel:self.requestModel isTop:YES completion:nil];
}
-(void) didTriggeredBottomRefresh: (RefreshTableView *)tableView
{
    [AppRefreshTableViewController compareToSendModelRefreshRequest:self.headerTableView filter:self.contentsFilter requestModel:self.requestModel isTop:NO completion:nil];
}

#pragma mark - Class Methods

+(void) compareToSendModelRefreshRequest: (JRRefreshTableView*)refreshTableView filter:(ContentFilterBlock)filter requestModel:(RequestJsonModel*)requestJsonModel isTop:(BOOL)isTop completion:(void(^)(BOOL isNoNewData))completion
{
    NSArray* models = requestJsonModel.models;
    NSArray* fields = requestJsonModel.fields;
    NSMutableArray* sorts = requestJsonModel.sorts;
    // this is the importmant , modified it .
    NSMutableArray* criterias = requestJsonModel.criterias;
    
    
    // for roll back
    NSMutableArray* rollbacks = [NSMutableArray array];
    
    for (int i = 0; i < models.count; i++) {
        
        NSString* model = models[i];
        NSArray* innderFields = [fields objectAtIndex:i];
        NSMutableArray* innerSorts = [sorts objectAtIndex: i];
        
        // the feld need to be modified
        NSMutableDictionary* criteria = [criterias objectAtIndex:i] ;
        NSMutableDictionary* criteriaAndDictioanry = [criteria objectForKey:CRITERIAL_AND];
        
        
        
        // --------------------------------------------------------
        // get the sort column and ASC/DESC
        NSString* firstColumnSorteString = [innerSorts safeObjectAtIndex: refreshTableView.refreshCompareColumnSortIndex];
        NSArray* elements = [firstColumnSorteString componentsSeparatedByString: DOT];
        NSString* column = [elements firstObject];
        NSString* ascOrDesc = [elements lastObject];
        
        
        // get the newest or the oldest
        NSArray* contents = [refreshTableView.tableView.realContentsDictionary objectForKey: model];
        if (! contents) continue ;      // for join
        
        NSArray* cellValues = isTop ? [contents firstObject] : [contents lastObject];
        
        // get the newest or the oldest criticalValue of the column
        NSUInteger index = [innderFields indexOfObject: column];
        if (index == NSNotFound) {
            continue;
        }
        id criticalValue = cellValues[index];
        

        // assemble by the criticalValue
        NSString* GT_LT =  (([ascOrDesc isEqualToString: SORT_DESC] && isTop) || ([ascOrDesc isEqualToString: SORT_ASC] && !isTop)) ?  GT_LT = CRITERIAL_GT : CRITERIAL_LT;
        NSString* format = [criticalValue isKindOfClass:[NSNumber class]] ? @"(%@)" : @"%@";
        NSString* GT_LT_StringValue = [GT_LT stringByAppendingFormat:format, criticalValue];                              // GT<>(26)
        // --------------------------------------------------------
        
        
        
        
        // DO THE SET JOB !!!
        [criteriaAndDictioanry setObject: GT_LT_StringValue forKey:column];                                               // { and = { 'column' = GT<>(26) } }
        
        // for roll back Remove it
        [rollbacks addObject:@[criteriaAndDictioanry, column]];
    }
    
    [self sendModelRefreshRequest: refreshTableView filter:filter requestModel:requestJsonModel isTop:isTop completion:completion];
    
    
    // Remove it
    for (int i = 0; i < rollbacks.count; i++) {
        NSArray* rolls = [rollbacks objectAtIndex:i];
        NSMutableDictionary* criteriaAndDictioanry = [rolls firstObject];
        NSString* column = [rolls lastObject];
        [criteriaAndDictioanry removeObjectForKey: column];
    }
}



+(void) sendModelRefreshRequest: (JRRefreshTableView*)refreshTableView filter:(ContentFilterBlock)filter requestModel:(RequestJsonModel*)requestModel isTop:(BOOL)isTop completion:(void(^)(BOOL isNoNewData))completion
{
    [DATA.requester startPostRequest: requestModel completeHandler:^(HTTPRequester* requester, ResponseJsonModel *data, NSHTTPURLResponse *httpURLReqponse, NSError *error) {
        
        // pase the data
        NSMutableDictionary* newPartRealContentDictionary = [TableContentHelper assembleToRealContentDictionary:data.results keys:data.models];
        
        // check if empty
        BOOL isNoNewData = YES;
        for (NSString* key in newPartRealContentDictionary) {
            NSArray* contents = newPartRealContentDictionary[key];
            if(contents.count != 0) {
                isNoNewData = NO;
                break;
            }
        }
        
        if (! isNoNewData) {
            // integrate the data
            NSMutableDictionary* realContentsDictionary = refreshTableView.tableView.realContentsDictionary;
            NSArray* insertIndexPaths = [AppPageViewHelper insertValues: realContentsDictionary partRealContentDictionary:newPartRealContentDictionary isTop:isTop];    // put it before assemble
            
            refreshTableView.tableView.contentsDictionary = [ListViewControllerHelper convertRealToVisualContents: realContentsDictionary filter:filter];
            UITableViewRowAnimation animationType = isTop ? UITableViewRowAnimationLeft : UITableViewRowAnimationTop;
            [ViewHelper tableViewRowInsert: refreshTableView.tableView insertIndexPaths:insertIndexPaths animation:animationType completion:^(BOOL finished) {
                [refreshTableView doneDownloading: isTop];
                [refreshTableView reloadTableData];
            }];
            
        } else {
             [refreshTableView doneDownloading: isTop];
        }
        
        if (completion) completion(isNoNewData);
    }];
}









#pragma mark - About Sort and Page   (sorts , limits , criterias)

+(void) checkAndAddSortedLimitsColumn: (RequestJsonModel*)requestJsonModel
{
    for (int i = 0; i < requestJsonModel.models.count; i++) {
        // ----- fields
        NSArray* innerFields = [requestJsonModel.fields objectAtIndex:i];
        
        
        // ----- sort
        NSMutableArray* innerSorts = [requestJsonModel.sorts safeObjectAtIndex: i];
        if (! innerSorts) {
            innerSorts = [NSMutableArray array];
            [requestJsonModel.sorts addObject: innerSorts];
            
            // add sort specification
            if ([innerFields containsObject:PROPERTY_IDENTIFIER]) [innerSorts addObject:DOT_CONNENT(PROPERTY_IDENTIFIER, SORT_DESC)];
        }
        
        
        
        // ----- limit
        NSMutableArray* innerLimits = [requestJsonModel.limits safeObjectAtIndex: i];
        if (! innerLimits) {
            innerLimits = [NSMutableArray array];
            [requestJsonModel.limits addObject: innerLimits];
            
            // add limit count
            [innerLimits addObjectsFromArray:@[@(0), @(15)]];
        }
        
        
        
        
        // ----- criteria
        NSMutableDictionary* criteria = [requestJsonModel.criterias safeObjectAtIndex: i];
        if (! criteria) {
            criteria = [NSMutableDictionary dictionary];
            [requestJsonModel.criterias addObject: criteria];
        }
        NSMutableDictionary* andDictionary = [criteria objectForKey:CRITERIAL_AND];
        if (! andDictionary) {
            andDictionary = [NSMutableDictionary dictionary];
            [criteria setObject: andDictionary forKey:CRITERIAL_AND];
        }
    }
}


@end
