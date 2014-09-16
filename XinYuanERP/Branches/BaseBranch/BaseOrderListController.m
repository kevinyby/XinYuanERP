#import "BaseOrderListController.h"
#import "AppInterface.h"

@implementation BaseOrderListController
{
    NSDictionary* config;
    
    
    OrderListSearchHelper* searchHelper;
}


-(void) initializeWithDepartment:(NSString*)department order:(NSString*)orderType
{
    self.order = orderType;
    self.department = department;
    
    config = [OrderListControllerHelper getModelsListSpecification: department order:orderType];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    // set up bar items
    [OrderListControllerHelper setRightBarButtonItems: self];
    
    // set up list controller properties
    [self setupOrderListControllerWithSpecification];
    
}






#pragma mark - Override Super Class Methods

// delete begin -------------------
- (BOOL)tableViewBase:(TableViewBase *)tableViewObj canEditIndexPath:(NSIndexPath*)indexPath
{
    return [PermissionChecker checkSignedUser: self.department order:self.order permission:PERMISSION_DELETE];
}

- (BOOL)tableViewBase:(TableViewBase *)tableViewObj shouldDeleteContentsAtIndexPath:(NSIndexPath*)indexPath
{
    __weak BaseOrderListController* weakInstance = self;
    NSString* orderType = self.order;
    NSString* department = self.department;
    NSIndexPath* realIndexPath = [((FilterTableView*)tableViewObj) getRealIndexPathInFilterMode: indexPath];
    id identification = [[tableViewObj realContentForIndexPath:realIndexPath] firstObject];
    NSString* tips = [[tableViewObj realContentForIndexPath:realIndexPath] safeObjectAtIndex: 1];
    
    [OrderListControllerHelper deleteWithCheckPermission: orderType deparment:department identification:identification tips:tips handler:^(bool isSuccess) {
        if (isSuccess) {
    
            // delete the images
            NSString* imagesFolderName = [OrderListControllerHelper getImageFolderName: weakInstance indexPath:realIndexPath];
            if (! OBJECT_EMPYT(imagesFolderName)) {
                NSString* fullFolderName = [[JsonControllerHelper getImagesHomeFolder: orderType department:department] stringByAppendingPathComponent: imagesFolderName];
                [VIEW.progress show];
                VIEW.progress.detailsLabelText = APPLOCALIZE_KEYS(@"In_Process", @"delete", @"images");
                [AppServerRequester deleteImagesFolder: fullFolderName completeHandler:^(HTTPRequester *requester, ResponseJsonModel *model, NSHTTPURLResponse *httpURLReqponse, NSError *error) {
                    [VIEW.progress hide];
                }];
            }
            
            // Important!!!! put it behide !!! it will affect get image name ....
            [tableViewObj deleteIndexPathWithAnimation: indexPath];
        }
    }];
    
    return NO;  // let the call back delete visual content
}
// delete end -------------------





#pragma mark - Action

-(void)createNewOrderAction:(id)sender
{
    if(! [PermissionChecker checkSignedUserWithAlert: self.department order:self.order permission:PERMISSION_CREATE]) {
        return;
    }
    
    self.isPopNeedRefreshRequest = YES;
    
    JsonController* jsonController = [OrderListControllerHelper getNewJsonControllerInstance: self.department order:self.order];
    jsonController.controlMode = JsonControllerModeCreate;
    [VIEW.navigator pushViewController: jsonController animated:YES];
}


-(void)scanQRCodeAction:(id)sender
{
    QRCodeReaderViewController* QRReadVC = [[QRCodeReaderViewController alloc]init];
    QRReadVC.resultBlock = ^void(NSString* result){
        self.headerTableView.searchBar.textField.text = result;
        self.headerTableView.tableView.filterText = result;
    };
    
    [self.navigationController presentViewController: QRReadVC animated:YES completion:nil];
}


-(void) searchOrderAction: (id)sender
{
    if (!searchHelper) {
        searchHelper = [[OrderListSearchHelper alloc] initWithController:self];
        [self handleSearchHelper: searchHelper];
    }
    
    [searchHelper showSearchTableView];
}




#pragma mark - Handle Porperties With Config

- (void)setupOrderListControllerWithSpecification
{
    // then , assign the attributes
    NSString* orderType = self.order;
    NSString* department = self.department;
    
    // set common
    self.requestModel = [RequestJsonModel getJsonModel];
    self.requestModel.path = PATH_LOGIC_READ(self.department);
    
    self.appTableDidSelectRowBlock = ^void(AppSearchTableViewController* controller ,NSIndexPath* realIndexPath)
    {
        if(! [PermissionChecker checkSignedUserWithAlert:department order:orderType permission:PERMISSION_READ]) {
            return;
        }
        
        // set identification
        id identification = [controller getIdentification: realIndexPath];
        JsonController* jsonController = [OrderListControllerHelper getNewJsonControllerInstance: department order:orderType];
        jsonController.controlMode = JsonControllerModeRead;
        jsonController.identification = identification;
        [VIEW.navigator pushViewController: jsonController animated:YES];
    };
    
    // set from specification
    if (config) {
        
        if (config[list_REQUEST_PATH]) {
            self.requestModel.path = PATH_LOGIC_READ(config[list_REQUEST_PATH]);
        } else {
            self.requestModel.path = PATH_LOGIC_READ(self.department);
        }
        
        if (config[req_MODELS]) {
            [self.requestModel.models addObjectsFromArray: config[req_MODELS]];
        } else {
            [self.requestModel addModels: orderType, nil];
        }
        
        if (config[req_FIELDS]) [self.requestModel.fields addObjectsFromArray:config[req_FIELDS]];
        
        if (config[req_JOINS]) [self.requestModel.joins addObject: config[req_JOINS]];
        
        if (config[req_SORTS]) {
            [self.requestModel.sorts addObjectsFromArray: [ArrayHelper deepCopy: config[req_SORTS]]];
        } else {
            [self.requestModel.sorts addObjectsFromArray: [ArrayHelper deepCopy: @[@[@"id.DESC"]]]];
        }
        
        if (config[req_LIMITS]) {
            [self.requestModel.limits addObjectsFromArray: [ArrayHelper deepCopy: config[req_LIMITS]]];
        } else {
            [self.requestModel.limits addObjectsFromArray: [ArrayHelper deepCopy: @[@[@(0), @(200)]]]];
        }
        
        // view
        if (config[list_VIEW_HEADERS]) self.headers = config[list_VIEW_HEADERS];
        
        if (config[list_VIEW_HEADERSX]) self.headersXcoordinates = config[list_VIEW_HEADERSX];
        
        if (config[list_VIEW_VALUESX]) self.valuesXcoordinates = config[list_VIEW_VALUESX];
        
        // pre define filter
        if (config[list_VIEW_FILTER]) {
            NSDictionary* filters = config[list_VIEW_FILTER];
            self.contentsFilter = ^void(int elementIndex , int innerCount, int outterCount, NSString* section, id cellElement, NSMutableArray* cellRepository) {
                NSString* filterName = [filters objectForKey: [[NSNumber numberWithInt: elementIndex] stringValue]];
                
                if (filterName) {
                    ContentFilterElementBlock block = [ContentFilterHelper.contentFiltersMap objectForKey: filterName];
                    if (block) {
                        cellElement = block(cellElement, cellRepository);
                    }
                }
                
                if (cellElement) {
                    [cellRepository addObject: cellElement];
                }
            };
        }
        
    }
    
    // after set headers
    [OrderListControllerHelper iterateHeaderJRLabel:self handler:^BOOL(JRLocalizeLabel *label, int index, NSString *attribute) {
        label.attribute = attribute; return NO;
    }];
    
    
    // for suclass
    [self setInstanceVariablesValues];
    
    [self setExceptionAttributes];
    
    [self setHeadersSortActions];
}





#pragma mark - SubClass Override Methods

-(void) handleSearchHelper: (OrderListSearchHelper*)searchHelperObj
{
    NSMutableArray* properties = searchHelperObj.orderSearchProperties;
    NSDictionary* propertiesMap = searchHelperObj.orderPropertiesMap;
    
    [properties removeObject: PROPERTY_IDENTIFIER];
    [properties removeObject: PROPERTY_MODIFIEDUSER];
    [properties removeObject: PROPERTY_FORWARDUSER];
    
    for (NSString* property in config[list_ELIMINATE_SEARCH]) {
        [properties removeObject: property];
    }
    
    [OrderListControllerHelper sortSearchProperties: properties propertiesMap:propertiesMap orderType:self.order];
}

-(void) setInstanceVariablesValues
{
}

-(void) setExceptionAttributes
{
    [ListViewControllerHelper setupExceptionAttributes: self order:self.order];
}

-(void) setHeadersSortActions
{
    __weak BaseOrderListController* weakInstance = self;
    [OrderListControllerHelper iterateHeaderJRLabel:weakInstance handler:^BOOL(JRLocalizeLabel *label, int index, NSString *attribute) {
        label.jrLocalizeLabelDidClickAction = ^void(JRLocalizeLabel* label) {
            [OrderListControllerHelper clickHeaderLabelSortRequestAction: label listController:weakInstance];
        };
        return NO;
    }];
}






@end
