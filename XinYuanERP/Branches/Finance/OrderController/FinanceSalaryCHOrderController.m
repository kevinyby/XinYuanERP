#import "FinanceSalaryCHOrderController.h"
#import "AppInterface.h"


#define OLD_SUFFIX @"_O"
#define NEW_SUFFIX @"_N"


@implementation FinanceSalaryCHOrderController
{
    NSMutableArray* oldCaculateTxFields;
    JRLabelCommaTextFieldView* oldSummaryTextField ;
    
    NSMutableArray* newCaculateTxFields;
    JRLabelCommaTextFieldView* newSummaryTextField ;
    
    JRLabelCommaTextFieldView* adjustAmountTextField ;
}

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    oldCaculateTxFields = [NSMutableArray array];
    newCaculateTxFields = [NSMutableArray array];
    
    JsonView* jsonView = self.jsonView;
    __weak FinanceSalaryCHOrderController* weakInstance = self;
    
    
    
    ///////_____________________________________________ Begin Caculate ____________________________
    
    oldSummaryTextField = (JRLabelCommaTextFieldView*)[jsonView getView:@"ZZ_LBLBEFORESUM"];
    newSummaryTextField = (JRLabelCommaTextFieldView*)[jsonView getView:@"ZZ_LBLAFTERSUM"];
    
    // adjustAmountTextField
    adjustAmountTextField = (JRLabelCommaTextFieldView*) [jsonView getView: @"NESTED_Right_BOTTOM.adjustAmount"];
    
    
    // auto caculate fields
    NSArray* fieldsKeys = @[@"baseSalary", @"skillBenefit", @"fullBenefit", @"dutyBenefit", @"dormBenefit", @"foodBenefit"];
    NSMutableArray* oldFieldsKeys = [FinanceSalaryCHOrderController tailKeys: fieldsKeys with:OLD_SUFFIX];
    NSMutableArray* newFieldsKeys = [FinanceSalaryCHOrderController tailKeys: fieldsKeys with:NEW_SUFFIX];
    for (int i = 0; i < oldFieldsKeys.count; i++) {
        [oldCaculateTxFields addObject: [jsonView getView: oldFieldsKeys[i]]];
    }
    for (int i = 0; i < newFieldsKeys.count; i++) {
        [newCaculateTxFields addObject: [jsonView getView: newFieldsKeys[i]]];
    }
    
    // set event 1
    [self registryCaculateFieldsShouldSetTextEvent: oldCaculateTxFields];
    [self registryCaculateFieldsShouldSetTextEvent: newCaculateTxFields];
    // set event 2
    [IterateHelper iterate: oldCaculateTxFields handler:^BOOL(int index, id obj, int count) {
        __weak JRLabelCommaTextFieldView* view = obj;
        view.textField.textFieldDidSetTextBlock = ^void(NormalTextField* tx, NSString* oldText) {
            [weakInstance updateBeforeSummary];
            [weakInstance updateSubtraction: index];
        };
        return NO;
    }];
    
    [IterateHelper iterate: newCaculateTxFields handler:^BOOL(int index, id obj, int count) {
        __weak JRLabelCommaTextFieldView* view = obj;
        view.textField.textFieldDidSetTextBlock = ^void(NormalTextField* tx, NSString* oldText) {
            [weakInstance updateAfterSummary];
            [weakInstance updateSubtraction: index];
        };
        return NO;
    }];
    
    ///////_____________________________________________ End Caculate ____________________________
    
    
    
    
    
   
    // employee button
    JRTextField* employeeNOBTN = ((JRLabelCommaTextFieldView*)[jsonView getView: PROPERTY_EMPLOYEENO]).textField;
    employeeNOBTN.textFieldDidClickAction = ^void(JRTextField* sender) {
        // popup a table
        PickerModelTableView* pickView = [PickerModelTableView popupWithModel:MODEL_EMPLOYEE willDimissBlock:nil];
        pickView.titleHeaderViewDidSelectAction = ^void(JRTitleHeaderTableView* headerTableView, NSIndexPath* indexPath){
            
            FilterTableView* filterTableView = (FilterTableView*)headerTableView.tableView.tableView;
            NSIndexPath* realIndexPath = [filterTableView getRealIndexPathInFilterMode: indexPath];
            
            NSString* employeeNO = [filterTableView realContentForIndexPath: realIndexPath];
            [weakInstance fetchEmployeeNumberData: employeeNO];
            
            [PickerModelTableView dismiss];
        };
    };
    
    
    
}




#pragma mark - Public Methods
-(void) fetchEmployeeNumberData:(NSString*)employeeNO
{
    // header infos view
    JsonDivView* headerInfoView = (JsonDivView*)[self.jsonView getView:@"NESTED_INFO_HEAD"];
    JsonDivView* leftOldSalaryInfoView = (JsonDivView*)[self.jsonView getView:@"NESTED_Left"];
    JsonDivView* rightNewSalaryInfoView = (JsonDivView*)[self.jsonView getView:@"NESTED_Right"];
    
    // get and assemble data from server
    NSDictionary* objects = @{PROPERTY_EMPLOYEENO: employeeNO};
    
    NSArray* employeeInfosFields = @[PROPERTY_EMPLOYEENO, PROPERTY_EMPLOYEE_NAME, PROPERTY_EMPLOYEE_DEPARTMENT, PROPERTY_EMPLOYEE_JOBTITLE];
    
    NSArray* reqModels = @[DOT_CONNENT(DEPARTMENT_HUMANRESOURCE, MODEL_EMPLOYEE), DOT_CONNENT(DEPARTMENT_FINANCE, ORDER_FinanceSalary),DOT_CONNENT(DEPARTMENT_FINANCE, ORDER_FinanceSalaryCHOrder)];
    NSArray* reqObjects = @[objects,objects,objects];
    NSArray* reqFields = @[employeeInfosFields];
    NSArray* reqLimits = @[@[],@[],@[@(0),@(1)]];
    NSArray* reqSorts = @[@[],@[],@[DOT_CONNENT(@"createDate", SORT_DESC)]];
    
    [VIEW.progress show];
    [AppServerRequester readModels: reqModels  department:SUPERBRANCH objects:reqObjects fields:reqFields limits:reqLimits sorts:reqSorts completeHandler:^(ResponseJsonModel *response, NSError *error) {
        [VIEW.progress hide];
        
        if (response.status) {
            NSString* department = DEPARTMENT_FINANCE;
            
            // info
            NSArray* infos = [[response.results firstObject] firstObject];
            NSDictionary* employeeInfo = [DictionaryHelper convert: infos keys:employeeInfosFields];
            
            // salary info
            NSDictionary* salaryInfo = [[response.results objectAtIndex:1] firstObject];
            NSMutableDictionary* oldSalary = [DictionaryHelper tailKeys: salaryInfo with:OLD_SUFFIX excepts:employeeInfosFields];
            NSMutableDictionary* newSalary = [DictionaryHelper tailKeys: salaryInfo with:NEW_SUFFIX excepts:employeeInfosFields];
            
            // check
            if (! [JsonControllerHelper isAllApplied: ORDER_FinanceSalary  valueObjects:salaryInfo]) {
                [self cannotCreateAlert: ORDER_FinanceSalary department:department identifier:salaryInfo[PROPERTY_IDENTIFIER] employeeNO:employeeNO objects:salaryInfo];
                return ;
            }
            
            
            
            // last salary change info
            NSDictionary* lastSalaryCHInfo = [[response.results lastObject] firstObject];
            id lastSalaryCHId = [lastSalaryCHInfo objectForKey: PROPERTY_IDENTIFIER];
            
            // check
            if (lastSalaryCHInfo) {
                if (! [JsonControllerHelper isAllApplied: ORDER_FinanceSalaryCHOrder valueObjects:lastSalaryCHInfo]) {
                    [self cannotCreateAlert: ORDER_FinanceSalaryCHOrder department:department identifier:lastSalaryCHId employeeNO:employeeNO objects:lastSalaryCHInfo];
                    return ;
                }
                
                NSString* lastAdjustDate = [DateHelper stringFromString:lastSalaryCHInfo[@"adjustDate"] fromPattern:DATE_TIME_PATTERN toPattern:DATE_PATTERN];
                [oldSalary setObject: lastAdjustDate forKey:@"lastAdjustDate"];
                [oldSalary setObject: lastSalaryCHInfo[@"adjustAmount"] forKey:@"lastAdjustAmount"];
            }
            
            
            // Automatic fill the textfield .
            [headerInfoView clearModel];
            [JsonModelHelper clearModel: leftOldSalaryInfoView exceptkeys:@[@"Adjust_Before"]];
            [JsonModelHelper clearModel: rightNewSalaryInfoView exceptkeys:@[@"Adjust_After", @"adjustDate"]];
            
            [headerInfoView setModel: employeeInfo];
            [leftOldSalaryInfoView setModel: oldSalary];      // set the old
            [rightNewSalaryInfoView setModel: newSalary];      // set the new
            
        }
        
    }];
}



#pragma mark - Private Methods

///////_____________________________________________ Pop Cannot Create Alert ____________________________
-(void) cannotCreateAlert: (NSString*)orderType department:(NSString*)department identifier:(id)identifier employeeNO:(NSString*)employeeNO objects:(NSDictionary*)objects
{
    NSString* currentApprovingLevel = [JsonControllerHelper getCurrentApprovingLevel: orderType valueObjects:objects];
    
    NSString* message = LOCALIZE_MESSAGE_FORMAT(@"HaveAnOrderApproving", employeeNO, LOCALIZE_KEY(orderType), LOCALIZE_KEY(currentApprovingLevel));
    message = [message stringByAppendingFormat:@", %@", APPLOCALIZE_KEYS(@"cannot", @"create", self.order)];
    
    [PopupViewHelper popAlert: nil message:message style:0 actionBlock:^(UIView *popView, NSInteger index) {
        if (index == 1) {
            [JsonBranchFactory navigateToOrderController: department order:orderType identifier:identifier];
        }
    } dismissBlock:nil buttons:LOCALIZE_KEY(KEY_CANCEL), LOCALIZE_KEY(@"read"), nil];
}


///////_____________________________________________ Begin Caculate ____________________________

-(void) registryCaculateFieldsShouldSetTextEvent: (NSArray*)caculateFields
{
    // Auto caculate
    for (int i = 0; i < caculateFields.count; i++) {
        __weak JRLabelCommaTextFieldView* view = caculateFields[i];
        
        view.textField.textFieldShouldSetTextBlock = ^BOOL(NormalTextField* textField, NSString* newText) {
            if (OBJECT_EMPYT(newText)) {
                return YES;
            }
            BOOL isNumeric = [StringHelper isNumericValue: newText];
            if (isNumeric) {
                return YES;
            } else {
                [ACTION alertMessage: LOCALIZE_MESSAGE_FORMAT(MESSAGE_ValueNotMatchFormat, LOCALIZE_KEY(LOCALIZE_CONNECT_KEYS(self.order, view.attribute)), LOCALIZE_KEY(json_CHECK_FORMAT_DIGIT))];
                return NO;
            }
        };
        
    }
}

-(void) updateSubtraction: (int)index
{
    // summary
    id newSum = [newSummaryTextField getValue];
    id oldSum = [oldSummaryTextField getValue];
    
    if (!OBJECT_EMPYT(newSum) && !OBJECT_EMPYT(oldSum)) {
        
        float oldFloatValue = [oldSum floatValue];
        float newFloatValue = [newSum floatValue];
        
        JRLabel* sumSubtractLabel = (JRLabel*)[newSummaryTextField viewWithTag: 110];
        if (! sumSubtractLabel) {
            sumSubtractLabel = [[JRLabel alloc] init];
            sumSubtractLabel.tag = 110;
            [newSummaryTextField addSubview: sumSubtractLabel];
            sumSubtractLabel.frame = CGRectMake([newSummaryTextField sizeWidth] + [FrameTranslater convertCanvasWidth: 5], 0, [FrameTranslater convertCanvasWidth: 80], [newSummaryTextField sizeHeight]);
            sumSubtractLabel.textColor = [UIColor blueColor];
            sumSubtractLabel.font = [UIFont fontWithName:@"Arial" size:[FrameTranslater convertFontSize: 15]];
        }
        
        float subtractValue = newFloatValue - oldFloatValue;
        [FinanceSalaryCHOrderController setValueToTipLabel: sumSubtractLabel subtractValue:subtractValue ];
        [adjustAmountTextField setValue: @(subtractValue)];
        
    }
    
    
    // each
    JRLabelCommaTextFieldView* newTextField = [newCaculateTxFields safeObjectAtIndex: index];
    JRLabelCommaTextFieldView* oldTextField = [oldCaculateTxFields objectAtIndex: index];
    
    id newValue = [newTextField getValue];
    id oldValue = [oldTextField getValue];
    
    JRLabel* subtractLabel = [FinanceSalaryCHOrderController getTipLabel: newTextField];
    if (!OBJECT_EMPYT(newValue) && !OBJECT_EMPYT(oldValue)) {
        float oldFloatValue = [oldValue floatValue];
        float newFloatValue = [newValue floatValue];
        float subtractValue = newFloatValue - oldFloatValue;
        [FinanceSalaryCHOrderController setValueToTipLabel: subtractLabel subtractValue:subtractValue];
    } else {
        subtractLabel.text = nil;
    }
    

}

-(void) updateBeforeSummary
{
    float summary = [FinanceSalaryCHOrderController getSummary: oldCaculateTxFields];
    [oldSummaryTextField setValue: @(summary)];
}

-(void) updateAfterSummary
{
    float summary = [FinanceSalaryCHOrderController getSummary: newCaculateTxFields];
    [newSummaryTextField setValue: @(summary)];
}

///////_____________________________________________ End Caculate ____________________________









#pragma mark - Class Methods

+(NSMutableArray*) tailKeys: (NSArray*)keys with:(NSString *)tail
{
    NSMutableArray* results = [NSMutableArray arrayWithCapacity: keys.count];
    [IterateHelper iterate: keys handler:^BOOL(int index, id obj, int count) {
        NSString* newKey = [obj stringByAppendingString: tail];
        [results addObject: newKey];
        return NO;
    }];
    return results;
}


+(float) getSummary: (NSArray*)caculateTxFields
{
    float summary = 0.0;
    
    for (int i = 0; i < caculateTxFields.count; i++) {
        JRLabelCommaTextFieldView* view = caculateTxFields[i];
        NSString* text = [view getValue];
        float unit = [text floatValue];
        summary += unit;
    }
    
    return summary;
}


+(JRLabel*) getTipLabel: (UIView*)view
{
    JRLabel* subtractLabel = (JRLabel*)[view viewWithTag: 110];
    if (! subtractLabel) {
        subtractLabel = [[JRLabel alloc] init];
        subtractLabel.tag = 110;
        [view addSubview: subtractLabel];
        subtractLabel.frame = CGRectMake([view sizeWidth] + [FrameTranslater convertCanvasWidth: 10] , 0, [FrameTranslater convertCanvasWidth: 80], [view sizeHeight]);
        subtractLabel.textColor = [UIColor redColor];
        subtractLabel.font = [UIFont fontWithName:@"Arial" size:[FrameTranslater convertFontSize: 15]];
    }
    return subtractLabel;
}

+(void) setValueToTipLabel: (JRLabel*)label subtractValue:(float)subtractValue
{
    NSString* sign = subtractValue < 0 ? @"" : @"+";
    label.text = [sign stringByAppendingFormat:@"%.2f", subtractValue];
}


@end
