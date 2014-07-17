#import "APNSCategoriesController.h"
#import "AppInterface.h"

@interface APNSCategoriesController () <UITableViewDelegate, UITableViewDataSource>

@end

@implementation APNSCategoriesController


@synthesize settingsTableView;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // table
        settingsTableView = [[UITableView alloc] init];
        settingsTableView.delegate = self;
        settingsTableView.dataSource = self;
        settingsTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        if ([settingsTableView respondsToSelector:@selector(setSeparatorInset:)]) [settingsTableView setSeparatorInset:UIEdgeInsetsZero];
        settingsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        // data
        self.sections = @[LOCALIZE_KEY(DEPARTMENT_HUMANRESOURCE), LOCALIZE_KEY(DEPARTMENT_VEHICLE), LOCALIZE_KEY(DEPARTMENT_WAREHOUSE)];
        self.contents =  @[
                          @[APPLOCALIZE_KEYS(@"Trace",@"Files",@"time",@"Setting"),APPLOCALIZE_KEYS(@"Retire",@"age",@"Notify",@"Setting"),APPLOCALIZE_KEYS(@"Work",@"age",@"Notify",@"Setting")],
                          
                          @[APPLOCALIZE_KEYS(@"FuelConsumption",@"exception",@"Notify",@"Setting")],
                          
                          @[APPLOCALIZE_KEYS(@"MaterialRequisition",@"limit",@"Notify",@"Setting")],
                          
                          ];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    

    [self.view addSubview: settingsTableView];
    
    // set frame directly
    settingsTableView.frame = self.view.bounds;
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear: animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    self.navigationItem.title = LOCALIZE_KEY(@"Notify_Settings");
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.contents safeObjectAtIndex: section] ? [self.contents[section] count] : 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* cellIdentifier = @"setting_cell";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier: cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        [ColorHelper setBorder:cell color:[UIColor flatGrayColor]];
    }
    cell.textLabel.text = [[self.contents safeObjectAtIndex: indexPath.section] safeObjectAtIndex: indexPath.row];
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.sections ? self.sections.count : 1;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return [FrameTranslater convertCanvasHeight: 45];
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    static NSString* headerFooterIdentifier = @"setting_header_footer";
    UIView* headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:headerFooterIdentifier];
    if (! headerView) {
        // headerView
        headerView = [[UIView alloc] init];
        [ColorHelper setBackGround:headerView color:@[@(242),@(242),@(242)]];
        
        // label
        JRLabel* titleLabel = [[JRLabel alloc] init];
        titleLabel.tag = 201405;
        [headerView addSubview: titleLabel];
        titleLabel.textColor = [UIColor flatDarkGrayColor];
        [FrameHelper setFrame:CGRectMake(0, 0, 0, 50) view:titleLabel];
        [ColorHelper setBackGround: 0];
    }
    JRLabel* titleLabel = (JRLabel*)[headerView viewWithTag: 201405];
    titleLabel.text = [self.sections safeObjectAtIndex: section];
    [titleLabel adjustWidthToFontText];
    return headerView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    APNSEditController* controller = [[APNSEditController alloc] init];
    controller.apnsType = @"APNS_TEST";
    // did select event
    
    // DEPARTMENT_HUMANRESOURCE
    if (indexPath.section == 0) {
        NSMutableDictionary* specification = [DictionaryHelper deepCopy: [JsonFileManager getJsonFromFile: @"Components.json"][@"AdministratorAPNS"]];
        
        // Trace Files
        if (indexPath.row == 0)
        {
            controller.apnsType = @"APNS_TraceFilesDate";
            [DictionaryHelper replaceKeys: specification[@"COMPONENTS"][@"NESTED_BODY"][@"COMPONENTS"] keys:@[@"1"] withKeys:@[@"KEYS.save.Day.count"]];
            [specification[@"COMPONENTS"][@"NESTED_BODY"][@"COMPONENTS"] removeObjectForKey: @"2"];
            [specification[@"COMPONENTS"][@"NESTED_BODY"][@"COMPONENTS"] removeObjectForKey: @"3"];
            
            controller.viewDidLoadBlock = ^void(BaseController* controllerObj){
                ((APNSEditController*)controllerObj).apnsSettingsTableView.hidden = YES;
            };
            
        } else
        // @"Retire",@"age"
        if (indexPath.row == 1)
        {
            controller.apnsType = @"APNS_RetireAge";
            [DictionaryHelper replaceKeys: specification[@"COMPONENTS"][@"NESTED_BODY"][@"COMPONENTS"] keys:@[@"1",@"2"] withKeys:@[@"KEYS.male.Retire.age",@"KEYS.female.Retire.age"]];
            [specification[@"COMPONENTS"][@"NESTED_BODY"][@"COMPONENTS"] removeObjectForKey: @"3"];
            
        } else
            // "Work",@"age"
        if (indexPath.row ==2)
        {
            controller.apnsType = @"APNS_WorkAge";
            [DictionaryHelper replaceKeys: specification[@"COMPONENTS"][@"NESTED_BODY"][@"COMPONENTS"] keys:@[@"1"] withKeys:@[@"KEYS.Notify.Work.age"]];
            [specification[@"COMPONENTS"][@"NESTED_BODY"][@"COMPONENTS"] removeObjectForKey: @"2"];
            [specification[@"COMPONENTS"][@"NESTED_BODY"][@"COMPONENTS"] removeObjectForKey: @"3"];
        }
        
        void(^previousViewDidLoadBlock)(BaseController* controllerObj) = controller.viewDidLoadBlock;
        controller.viewDidLoadBlock = ^void(BaseController* controllerObj){
            if (previousViewDidLoadBlock) {
                previousViewDidLoadBlock(controllerObj);
            }
            [APNSCategoriesController addAPNSSettingsJsonDivView: controllerObj.view specification:specification];
        };
        
    // DEPARTMENT_VEHICLE
    } else if (indexPath.section == 1)
    {
        
        
        
    // DEPARTMENT_WAREHOUSE
    } else if (indexPath.section == 2)
    {
        NSMutableDictionary* specification = [DictionaryHelper deepCopy: [JsonFileManager getJsonFromFile: @"Components.json"][@"AdministratorAPNS"]];
        
        // @"MaterialRequisition",@"limit"
        if (indexPath.row == 0) {
            static const char* objectKey = nil;
            static const char* textFieldKey = nil;
            controller.apnsType = @"APNS_MaterialLimit";
            [DictionaryHelper replaceKeys: specification[@"COMPONENTS"][@"NESTED_BODY"][@"COMPONENTS"] keys:@[@"1",@"2",@"3"] withKeys:@[@"productName",@"date",@"amount"]];
            
            controller.APNSDidGetDataFromServer = ^void(APNSEditController* controllerObj, NSDictionary* results) {
                NSMutableDictionary* objects = [DictionaryHelper deepCopy: results];
                objc_setAssociatedObject(controllerObj, &objectKey, nil, OBJC_ASSOCIATION_RETAIN);
                objc_setAssociatedObject(controllerObj, &objectKey, objects, OBJC_ASSOCIATION_RETAIN);
                
                // ------------------------------------ Begin . Set datas to view
                NSString* productCode = [[objects allKeys] firstObject];
                NSMutableDictionary* data = objects[productCode];
                JRTextField* productNameTx = (JRTextField*)((JRLabelCommaTextFieldView*)[(JsonDivView*)[controllerObj.view viewWithTag:APNSEditControllerJSONDivTag] getView: @"productName"]).textField;
                objc_setAssociatedObject(productNameTx, &textFieldKey, productCode, OBJC_ASSOCIATION_RETAIN);
                [productNameTx setValue: data[@"name"]];
                [controllerObj setDataToViews: data[APNS_RESULTS_USERS] parameters:data[APNS_RESULTS_PARAMETERS]];
                // ------------------------------------ End . Set datas to view
            };
            controller.APNSGetDataSendToServer = ^NSMutableDictionary*(APNSEditController* controllerObj){
                NSMutableDictionary* objects = objc_getAssociatedObject(controllerObj, &objectKey);
                return objects;
            };
            
            
            controller.viewDidLoadBlock = ^void(BaseController* controllerObj){
                [APNSCategoriesController addAPNSSettingsJsonDivView: controllerObj.view specification:specification];
                JsonDivView* divView = (JsonDivView*)[controllerObj.view viewWithTag:APNSEditControllerJSONDivTag];
                
                // DATE
                JRTextField* dateTextField = ((JRLabelCommaTextFieldView*)[divView getView: @"date"]).textField;
                dateTextField.textFieldDidClickAction = ^void(JRTextField* textFieldObj) {
                    [JRComponentHelper showDatePicker: textFieldObj];
                };
                
                // PRODUCT
                JRTextField* productNameTextField = ((JRLabelCommaTextFieldView*)[divView getView: @"productName"]).textField;
                productNameTextField.textFieldDidClickAction = ^void(JRTextField* productNameTx) {
                    PickerModelTableView* pickerTableView = [PickerModelTableView popupWithRequestModel: MODEL_WHInventory fields:@[@"productCode", @"productName"] willDimissBlock:nil];
                    pickerTableView.tableView.headersXcoordinates = @[@(100),@(300)];
                    pickerTableView.tableView.tableView.tableViewBaseDidSelectAction = ^void(TableViewBase* tableViewObj, NSIndexPath* indexPath){
                        [PickerModelTableView dismiss];
                        NSMutableDictionary* objects = objc_getAssociatedObject(controllerObj, &objectKey);
                        
                        // PREVIOUS
                        NSString* previousCode = objc_getAssociatedObject(productNameTx, &textFieldKey);
                        if (previousCode && ![previousCode isEqualToString:@""]) {
                            [(APNSEditController*)controllerObj getViewsDataTo: objects[previousCode]];
                        }
                        
                        // NOW
                        NSArray* contents = [tableViewObj contentForIndexPath: indexPath];
                        id productCode = [contents firstObject];
                        NSString* productName = [contents lastObject];
                        
                        // ------------------------------------ Begin . Set datas to view
                        NSMutableDictionary* data = objects[productCode];
                        if (!data) {
                            data = [NSMutableDictionary dictionary];
                            [objects setObject: data forKey:productCode];
                            [data setObject: productName forKey:@"name"];
                        }
                        objc_setAssociatedObject(productNameTx, &textFieldKey, productCode, OBJC_ASSOCIATION_RETAIN);
                        [productNameTx setValue: data[@"name"]];
                        [(APNSEditController*)controllerObj setDataToViews: data[APNS_RESULTS_USERS] parameters:data[APNS_RESULTS_PARAMETERS]];
                        // ------------------------------------ End . Set datas to view
                        
                    };
                };
            };
            
            
        }
        
        
    }
    
    
    
    // show it out
    controller.viewWillAppearBlock = ^void(BaseController* controller, BOOL animated){
        controller.title = [tableView cellForRowAtIndexPath:indexPath].textLabel.text;
    };
    controller.view.backgroundColor = [UIColor whiteColor];
    [VIEW.navigator pushViewController: controller animated:YES];
}


+(void) addAPNSSettingsJsonDivView: (UIView*)view specification:(NSDictionary*)specification
{
    JsonView* jsonView = (JsonView*)[JsonViewRenderHelper render: @"AdministratorAPNS" specifications:specification];
    JsonDivView* bodyDivView = (JsonDivView*)[jsonView getView:@"NESTED_BODY"];
    [view addSubview: bodyDivView];
    
    [ViewHelper resizeWidthBySubviewsOccupiedWidth: bodyDivView];
    [bodyDivView setCenterX:[view sizeWidth]/2];
    [bodyDivView setOriginY:[jsonView originY]];
    bodyDivView.tag = APNSEditControllerJSONDivTag;
//                [ColorHelper setBorderRecursive: bodyView];
}


@end
