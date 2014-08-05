#import "APNSCategoriesController.h"
#import "AppInterface.h"

@interface APNSCategoriesController () <UITableViewDelegate, UITableViewDataSource>

@end

@implementation APNSCategoriesController
{
    NSString* workTime;
    NSString* traceFile ;
    NSString* retiredAge;
    NSString* workAge;
    
    NSString* fuelConsumption;
    NSString* materialRequisition;
    
}


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
        
        workTime = APPLOCALIZE_KEYS(@"atWork",@"time",@"Setting");
        traceFile = APPLOCALIZE_KEYS(@"Trace",@"Files",@"time",@"Setting");
        retiredAge = APPLOCALIZE_KEYS(@"Retire",@"age",@"Notify",@"Setting");
        workAge = APPLOCALIZE_KEYS(@"Work",@"age",@"Notify",@"Setting");
        
        fuelConsumption = APPLOCALIZE_KEYS(@"FuelConsumption",@"exception",@"Notify",@"Setting");
        materialRequisition = APPLOCALIZE_KEYS(@"MaterialRequisition",@"limit",@"Notify",@"Setting");
        
        // data
        self.sections = @[LOCALIZE_KEY(DEPARTMENT_HUMANRESOURCE), LOCALIZE_KEY(DEPARTMENT_VEHICLE), LOCALIZE_KEY(DEPARTMENT_WAREHOUSE)];
        self.contents =  @[
                          @[workTime,traceFile,retiredAge,workAge],
                          
                          @[fuelConsumption],
                          
                          @[materialRequisition],
                          
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
    self.navigationItem.title = LOCALIZE_KEY(@"General_Settings");
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
    NSString* cellText = [[self.contents safeObjectAtIndex: indexPath.section] safeObjectAtIndex: indexPath.row];
    GeneralEditController* controller = [[GeneralEditController alloc] init];
    controller.apnsType = @"APNS_TEST";
    
    if (![cellText isEqualToString: workTime]){
        [controller initializeTableHeaderAddButtonView];
    }
    // did select event
    
    
    // DEPARTMENT_HUMANRESOURCE
    if (indexPath.section == 0)
    {
        NSMutableDictionary* specification = [DictionaryHelper deepCopy: [JsonFileManager getJsonFromFile: @"Components.json"][@"AdministratorAPNS"]];
        
        if ([cellText isEqualToString: workTime])
        {
            NSString* xibName = @"WorkTimeSetting_IPAD";

            controller = [[GeneralEditController alloc] initWithNibName: xibName bundle:[NSBundle mainBundle]];
            controller.apnsType = @"AtWorkTime";
            controller.viewDidLoadBlock = ^void(BaseController* controllerObj){
                
                JsonDivView* jsonDivView = (JsonDivView*)controllerObj.view;
                [FrameHelper translateSubViewsFramesRecursive: jsonDivView];
                
                for (UIView* subView in jsonDivView.subviews) {
                    if ([subView isKindOfClass: [JsonDivView class]]) {
                        [LayerHelper setBasicAttributes: subView.layer config:@{@"BorderColor": @(7), @"BorderWidth": @(1), @"CornerRadius": @(5), @"MasksToBounds": @(TRUE)}];
                        for (UIView* v in subView.subviews) {
                            
                            if ([v isKindOfClass: [JRTextField class]]) {
                                [JRComponentHelper setupDatePickerToComponent: v pattern:@"HH:mm"];
                                ((JRTextField*)v).textFieldDidSetTextBlock = ^void(NormalTextField* textField, NSString* oldText){
                                    NSString* attribute = ((JRTextField*)textField).attribute;
                                    NSString* att = nil;
                                    if ([attribute rangeOfString: @"From"].location != NSNotFound) {
                                        att = [attribute stringByReplacingOccurrencesOfString: @"From" withString:@""];
                                    } else if ([attribute rangeOfString: @"To"].location != NSNotFound) {
                                        att = [attribute stringByReplacingOccurrencesOfString: @"To" withString:@""];
                                    }
                                    
                                    JRTextField* from = (JRTextField*)[jsonDivView getView:[att stringByAppendingString: @"From"]];
                                    JRTextField* to = (JRTextField*)[jsonDivView getView:[att stringByAppendingString: @"To"]];
                                    JRLabel* label = (JRLabel*)[jsonDivView getView:[att stringByAppendingString: @"Label"]];
                                    
                                    NSString* fromString = [from getValue];
                                    NSString* toString = [to getValue];
                                    if (OBJECT_EMPYT(fromString) || OBJECT_EMPYT(toString)) {
                                        return;
                                    }
                                    
                                    NSDateFormatter *dateFormatter= [[NSDateFormatter alloc] init];
                                    [dateFormatter setDateFormat: @"HH:mm"];
                                    NSDate *dateFrom =[dateFormatter dateFromString: fromString];
                                    NSDate *dateTo = [dateFormatter dateFromString: toString];
                                    
                                    NSDateComponents* components = [[NSCalendar currentCalendar]
                                                                       components:kCFCalendarUnitDay | kCFCalendarUnitHour | kCFCalendarUnitMinute
                                                                       fromDate:dateFrom
                                                                       toDate:dateTo
                                                                       options:0];
                                    NSInteger hour = [components hour];
                                    if (hour < 0) {
                                        hour = 24 + hour;
                                    }
                                    NSInteger minute = [components minute];
                                    if (minute < 0) {
                                        minute = 60 + minute;
                                    }
                                    
                                    NSString* format = minute == 0 ? @"%d" : @"%d:%02d";
                                    [label setValue: [NSString stringWithFormat: format, hour,minute]];
                                    [label adjustWidthToFontText];
                                };
                            } else if ([v isKindOfClass: [JRLabel class]]) {
                                [((JRLabel*)v) setValue: nil];
                            }
                        }
                        
                    }
                }
            };
            
            controller.APNSGetDataSendToServerAction = ^NSMutableDictionary*(GeneralEditController* controllerObj){
                NSMutableDictionary* result = [NSMutableDictionary dictionary];
                NSDictionary* model = [((JsonDivView*)controllerObj.view) getModel];
                for (NSString* key in model) {
                    if ([key rangeOfString:@"Label"].location == NSNotFound) {
                        [result setObject: model[key] forKey:key];
                    }
                }
                return result;
            };
            
            controller.APNSDidGetDataFromServerAction = ^void(GeneralEditController* controllerObj, NSDictionary* results) {
                [((JsonDivView*)controllerObj.view) setModel: results];
            };
            
            
        } else
            
        {
            
            // Trace Files
            if ([cellText isEqualToString: traceFile])
            {
                controller.apnsType = @"APNS_TraceFilesDate";
                [DictionaryHelper replaceKeys: specification[@"COMPONENTS"][@"NESTED_BODY"][@"COMPONENTS"] keys:@[@"1"] withKeys:@[@"KEYS.save.Day.count"]];
                [specification[@"COMPONENTS"][@"NESTED_BODY"][@"COMPONENTS"] removeObjectForKey: @"2"];
                [specification[@"COMPONENTS"][@"NESTED_BODY"][@"COMPONENTS"] removeObjectForKey: @"3"];
                
                controller.viewDidLoadBlock = ^void(BaseController* controllerObj){
                    ((GeneralEditController*)controllerObj).apnsSettingsTableView.hidden = YES;
                };
                
            } else
                // @"Retire",@"age"
                if ([cellText isEqualToString: retiredAge])
                {
                    controller.apnsType = @"APNS_RetireAge";
                    [DictionaryHelper replaceKeys: specification[@"COMPONENTS"][@"NESTED_BODY"][@"COMPONENTS"] keys:@[@"1",@"2"] withKeys:@[@"KEYS.male.Retire.age",@"KEYS.female.Retire.age"]];
                    [specification[@"COMPONENTS"][@"NESTED_BODY"][@"COMPONENTS"] removeObjectForKey: @"3"];
                    
                } else
                    // "Work",@"age"
                    if ([cellText isEqualToString: workAge])
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
            
        }

        
    // DEPARTMENT_VEHICLE
    } else if (indexPath.section == 1)
    {
        
        
        
    // DEPARTMENT_WAREHOUSE
    } else if (indexPath.section == 2)
    {
        NSMutableDictionary* specification = [DictionaryHelper deepCopy: [JsonFileManager getJsonFromFile: @"Components.json"][@"AdministratorAPNS"]];
        
        // @"MaterialRequisition",@"limit"
        if ([cellText isEqualToString: materialRequisition]) {
            static const char* objectKey = nil;
            static const char* textFieldKey = nil;
            controller.apnsType = @"APNS_MaterialLimit";
            [DictionaryHelper replaceKeys: specification[@"COMPONENTS"][@"NESTED_BODY"][@"COMPONENTS"] keys:@[@"1",@"2",@"3"] withKeys:@[@"productName",@"date",@"amount"]];
            
            controller.APNSDidGetDataFromServerAction = ^void(GeneralEditController* controllerObj, NSDictionary* results) {
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
            controller.APNSGetDataSendToServerAction = ^NSMutableDictionary*(GeneralEditController* controllerObj){
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
                            [(GeneralEditController*)controllerObj getViewsDataTo: objects[previousCode]];
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
                        [(GeneralEditController*)controllerObj setDataToViews: data[APNS_RESULTS_USERS] parameters:data[APNS_RESULTS_PARAMETERS]];
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
