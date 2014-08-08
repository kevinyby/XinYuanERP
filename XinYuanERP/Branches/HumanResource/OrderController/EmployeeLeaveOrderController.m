#import "EmployeeLeaveOrderController.h"
#import "AppInterface.h"

@interface EmployeeLeaveOrderController ()

@end

@implementation EmployeeLeaveOrderController
{
    NSDictionary* workTimeSettings;
    
    JRTextField* endDateTextField;
    JRTextField* startDateTextField;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    JsonView* jsonView = self.jsonView;
    __weak EmployeeLeaveOrderController* weakInstance = self;
    JsonDivView* bodyMiddel1DivView = (JsonDivView*)[jsonView getView:@"NESTED_MIDDLE_1"];
    JsonDivView* bodyMiddel2DivView = (JsonDivView*)[jsonView getView:@"NESTED_MIDDLE_2"];
    
    
    // employeeNO. TextField
    NSArray* infosFields = @[@"name", @"department",@"jobTitle"];
    JRTextField* employeeNOTextField = ((JRLabelTextFieldView*)[bodyMiddel1DivView getView: PROPERTY_EMPLOYEENO]).textField;
    employeeNOTextField.textFieldDidClickAction = ^void(id sender) {
        // popup a table
        PickerModelTableView* pickView = [PickerModelTableView popupWithModel:MODEL_EMPLOYEE willDimissBlock:nil];
        
        pickView.titleHeaderViewDidSelectAction = ^void(JRTitleHeaderTableView* headerTableView, NSIndexPath* indexPath){
            [VIEW.progress show];
            
            FilterTableView* filterTableView = (FilterTableView*)headerTableView.tableView.tableView;
            NSIndexPath* realIndexPath = [filterTableView getRealIndexPathInFilterMode: indexPath];
            
            NSString* employeeNO = [filterTableView realContentForIndexPath: realIndexPath];
            NSDictionary* objects = @{PROPERTY_EMPLOYEENO: employeeNO};
            [AppServerRequester readModel: MODEL_EMPLOYEE department:DEPARTMENT_HUMANRESOURCE objects:objects fields:infosFields completeHandler:^(ResponseJsonModel *data, NSError *error) {
                [VIEW.progress hide];
                
                NSArray* employeeInfoValues = [[data.results firstObject] firstObject];
                NSMutableDictionary* modelToRender = [DictionaryHelper convert: employeeInfoValues keys:infosFields];
                [modelToRender setObject: employeeNO forKey:PROPERTY_EMPLOYEENO];
                
                // Automatic fill the textfield .
                [JsonModelHelper clearModel: bodyMiddel1DivView exceptkeys:@[@"line1", @"line2", @"line3", @"line4"]];
                [bodyMiddel1DivView setModel: modelToRender];
            }];
            
            [PickerModelTableView dismiss];
        };
    };
    
    
    // start date , end date
    startDateTextField = ((JRLabelTextFieldView*)[bodyMiddel2DivView getView: @"startDate"]).textField;
    endDateTextField = ((JRLabelTextFieldView*)[bodyMiddel2DivView getView: @"endDate"]).textField;
    startDateTextField.textFieldDidSetTextBlock = ^void(NormalTextField* textField, NSString* oldText) {
        [weakInstance caculateLeaveTime];
    };
    endDateTextField.textFieldDidSetTextBlock = ^void(NormalTextField* textField, NSString* oldText) {
        [weakInstance caculateLeaveTime];
    };
}

#pragma mark - Override Super Class Methods

-(BOOL) validateSendObjects: (NSMutableDictionary*)objects order:(NSString*)order
{
    BOOL isSuccessfully = [super validateSendObjects: objects order:order];
    
    if (isSuccessfully) {
        if ([[DateHelper dateFromString: objects[@"startDate"] pattern:PATTERN_DATE_TIME] GTEQ:[DateHelper dateFromString: objects[@"endDate"] pattern:PATTERN_DATE_TIME]]) {
            isSuccessfully = NO;
            [ACTION alertError:LOCALIZE_MESSAGE(@"StartDateGTEndDate")];
        }
    }
    return isSuccessfully;
}


-(void) enableViewsWithReceiveObjects: (NSMutableDictionary*)objects
{
    JsonDivView* NESTED_footerDiv = (JsonDivView*)[self.jsonView getView: @"NESTED_footer"];
    NSArray* levels = [DATA.modelsStructure getModelApprovals: self.order];
    for (int i = 0; i < levels.count; i++) {
        NSString* levelKey = levels[i];
        [NESTED_footerDiv getView: levelKey].hidden = NO;
    }
    
    NSString* virtualFinalAppLevel = [self getTheFinalAppLeveBySettings: objects];
    if (virtualFinalAppLevel) {
        NSString* nextLevel = virtualFinalAppLevel;
        while ((nextLevel = [JsonControllerHelper getNextAppLevel: nextLevel])) {
            [NESTED_footerDiv getView: nextLevel].hidden = YES;
        }
        
        JRButtonTextFieldView* finalButton = (JRButtonTextFieldView*)[NESTED_footerDiv getView: virtualFinalAppLevel];
        JRButtonTextFieldView* realFinalButton = (JRButtonTextFieldView*)[NESTED_footerDiv getView: [levels lastObject]];
        finalButton.button.didClikcButtonAction = realFinalButton.button.didClikcButtonAction;
    }
    
    [super enableViewsWithReceiveObjects:objects];
}


#pragma mark - Private Methods

-(NSString*) getTheFinalAppLeveBySettings: (NSDictionary*)objects
{
    float day = [objects[@"day"] floatValue];
    NSDictionary* orderSettings = DATA.approvalSettings[self.department][self.order];
    NSArray* levels = [DATA.modelsStructure getModelApprovals: self.order];
    for (int i = 0; i < levels.count; i++) {
        NSString* levelKey = levels[i];
        NSDictionary* appValue = orderSettings[levelKey];
        NSString* appleaveDaySpec = appValue[@"APP_LEAVE_DAY"];
        int APP_LEAVE_DAY = [appleaveDaySpec intValue];
        if (!OBJECT_EMPYT(appleaveDaySpec) && (APP_LEAVE_DAY >= day)) {
            return levelKey;
        }
    }
    return nil;
}


-(void) caculateLeaveTime
{
    if (self.controlMode != JsonControllerModeCreate) return;
    
    NSString* startDateString = [startDateTextField getValue];
    NSString* endDateString = [endDateTextField getValue];
    if (OBJECT_EMPYT(startDateString) || OBJECT_EMPYT(endDateString)) {
        return;
    }
    
    if (! workTimeSettings) {
        [AppServerRequester readSetting: @"ADMIN_AtWorkTime" completeHandler:^(ResponseJsonModel *response, NSError *error) {
            if (response.status) {
                NSDictionary* results = response.results;
                NSString* jsonString = results[@"settings"];
                workTimeSettings = [CollectionHelper convertJSONStringToJSONObject: jsonString];
                [self caculateDayAnHour];
            }
        }];
    } else {
        [self caculateDayAnHour];
    }
}

-(void) caculateDayAnHour
{
    // To Be Continue
//    NSString* morningFrom = workTimeSettings[@"morningFrom"];
//    NSString* morningTo = workTimeSettings[@"morningTo"];
//    NSString* afternoonFrom = workTimeSettings[@"afternoonFrom"];
//    NSString* afternoonTo = workTimeSettings[@"afternoonTo"];
//    NSString* workDayFrom = workTimeSettings[@"workDayFrom"];
//    NSString* workDayTo = workTimeSettings[@"workDayTo"];
}

@end
