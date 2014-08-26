#import "BaseOrderListController.h"
#import "AppInterface.h"

@implementation BaseOrderListController
{
    NSDictionary* orderProperties;
    NSMutableArray* orderSearchProperties;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    orderProperties = [DATA.modelsStructure getModelStructure: self.order];
    orderSearchProperties = [[orderProperties allKeys] mutableCopy];
    
    [OrderListControllerHelper setRightBarButtonItems: self];
    
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
    
    JsonController* jsonController = [JsonBranchHelper getNewJsonControllerInstance: self.department order:self.order];
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
    // popu the view
    UIView* superView = [PopupTableHelper getCommonPopupTableView];
    JRButtonsHeaderTableView* searchTableView = (JRButtonsHeaderTableView*)[superView viewWithTag: POPUP_TABLEVIEW_TAG];
    [searchTableView.tableView setHideSearchBar: YES];
    [PopupViewHelper popView:superView willDissmiss:nil];
    
    // change the button title
    JRButton* rightButton = searchTableView.rightButton;
    [rightButton setTitle:LOCALIZE_KEY(@"SEARCH") forState:UIControlStateNormal];
    
    JRButton* leftButton = searchTableView.leftButton;
    [leftButton setTitle:LOCALIZE_KEY(@"clear") forState:UIControlStateNormal];
    
    // set the table contents
    TableViewBase* tableVieObj = searchTableView.tableView.tableView;
    tableVieObj.allowsSelection = NO;
    tableVieObj.tableViewBaseNumberOfSectionsAction = ^NSInteger(TableViewBase* tableViewObj) {
        return 1;
    };
    tableVieObj.tableViewBaseNumberOfRowsInSectionAction = ^NSInteger(TableViewBase* tableViewObj, NSInteger section) {
        return orderSearchProperties.count;
    };
    tableVieObj.tableViewBaseCellForIndexPathAction = ^UITableViewCell*(TableViewBase* tableViewObj, NSIndexPath* indexPath, UITableViewCell* oldCell) {
        JRLocalizeLabel* label = (JRLocalizeLabel*)[oldCell.contentView viewWithTag: 1000111];
        JRTextField* textField = (JRTextField*)[oldCell.contentView viewWithTag: 1000222];
        if (!label) {
            label = [[JRLocalizeLabel alloc] initWithFrame:CanvasRect(10, 25, 120, 70)];
            label.tag = 1000111;
            [oldCell.contentView addSubview: label];
            
            label.font = [UIFont systemFontOfSize: CanvasFontSize(25)];
            label.disableChangeTextTransition = YES;
        }
        if (!textField) {
            textField = [[JRTextField alloc] initWithFrame:CanvasRect(150, 15, 200, 50)];
            textField.tag = 1000222;
            [oldCell.contentView addSubview: textField];
            
            textField.borderStyle = UITextBorderStyleNone;
            textField.textAlignment = NSTextAlignmentCenter;
            [ColorHelper setBorder: textField color:[UIColor flatGrayColor]];
        }
        label.text = nil;
        textField.text = nil;
        [JRComponentHelper removeComponentShowDatePickerAction: textField];
        
        
        
        
        // set data and event
        NSString* text = APPLOCALIZES(self.order, orderSearchProperties[indexPath.row]);
        NSLog(@"+++++ %@", text);
//        if (indexPath.row == 0) {
//            text = APPLOCALIZE_KEYS(@"createDate", @"from");
//        } else if (indexPath.row == 1) {
//            text = APPLOCALIZE_KEYS(@"createDate", @"to");
//        }
        label.text = text;
        
        if (indexPath.row == 0 || indexPath.row == 1) {
            [JRComponentHelper addComponentShowDatePickerAction: textField pattern:PATTERN_DATE];
        }

        
        return oldCell;
    };
}




#pragma mark - Public Methods and Handle Config

- (void)handleOrderListController
{
    // then , assign the attributes
    NSString* orderType = self.order;
    NSString* department = self.department;
//    __weak BaseOrderListController* weakInstance = self;
    
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
        JsonController* jsonController = [JsonBranchHelper getNewJsonControllerInstance: department order:orderType];
        jsonController.controlMode = JsonControllerModeRead;
        jsonController.identification = identification;
        [VIEW.navigator pushViewController: jsonController animated:YES];
    };
    
    // set from specification
    NSDictionary* config = [JsonBranchHelper getModelsListSpecification: self.department order:orderType];
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
    [JsonBranchHelper iterateHeaderJRLabel:self handler:^BOOL(JRLocalizeLabel *label, int index, NSString *attribute) {
        label.attribute = attribute; return NO;
    }];
    
    
    // for suclass
    [self setInstanceVariablesValues];
    
    [self setExceptionAttributes];
    
    [self setHeadersSortActions];
}


#pragma mark - SubClass Override Methods

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
    [JsonBranchHelper iterateHeaderJRLabel:weakInstance handler:^BOOL(JRLocalizeLabel *label, int index, NSString *attribute) {
        label.jrLocalizeLabelDidClickAction = ^void(JRLocalizeLabel* label) {
            [JsonBranchHelper clickHeaderLabelSortRequestAction: label listController:weakInstance];
        };
        return NO;
    }];
}






@end
