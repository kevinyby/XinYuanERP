#import "FinanceSalaryController.h"
#import "AppInterface.h"

@interface FinanceSalaryController ()

@end

@implementation FinanceSalaryController
{
    NSMutableArray* caculateFields ;
    JRLabelCommaTextFieldView* summaryTextField ;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    caculateFields = [NSMutableArray array];
    JsonView* jsonView = self.jsonView;
    
    summaryTextField = (JRLabelCommaTextFieldView*)[jsonView getView:@"summary"];

    [caculateFields removeAllObjects];
    NSArray* fieldsKeys = @[@"baseSalary", @"skillBenefit", @"fullBenefit", @"dutyBenefit", @"dormBenefit", @"foodBenefit"];
    for (int i = 0; i < fieldsKeys.count; i++) {
        [caculateFields addObject: [jsonView getView: fieldsKeys[i]]];
    }
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
        
        view.textField.textFieldDidSetTextBlock = ^void(NormalTextField* tx, NSString* oldText) {
            [self updateSummary];
        };
    }
    
    
    
    // employeeNO. button
    JRTextField* employeeNOBTN = ((JRLabelCommaTextFieldView*)[jsonView getView: PROPERTY_EMPLOYEENO]).textField;
    employeeNOBTN.textFieldDidClickAction = ^void(id sender) {
        
        // popup a table
        PickerModelTableView* pickView = [PickerModelTableView popupWithModel:MODEL_EMPLOYEE willDimissBlock:nil];
        
        pickView.titleHeaderViewDidSelectAction = ^void(JRTitleHeaderTableView* headerTableView, NSIndexPath* indexPath){
            
            FilterTableView* filterTableView = (FilterTableView*)headerTableView.tableView.tableView;
            NSIndexPath* realIndexPath = [filterTableView getRealIndexPathInFilterMode: indexPath];
            
            NSString* employeeNO = [filterTableView realContentForIndexPath: realIndexPath];
            NSDictionary* objects = @{PROPERTY_EMPLOYEENO: employeeNO};
            NSArray* fields = @[PROPERTY_EMPLOYEENO, PROPERTY_EMPLOYEE_NAME, PROPERTY_EMPLOYEE_DEPARTMENT, PROPERTY_EMPLOYEE_JOBTITLE];
            
            [VIEW.progress show];
            [AppServerRequester readModel: MODEL_EMPLOYEE department:DEPARTMENT_HUMANRESOURCE objects:objects fields:fields completeHandler:^(ResponseJsonModel *data, NSError *error) {
                [VIEW.progress hide];
                if (error) {
                    [ACTION alertError: error];
                } else {
                    NSArray* objects = data.results;
                    NSArray* infos = [[objects firstObject] firstObject];
                    NSDictionary* employeeInfo = [DictionaryHelper convert: infos keys:fields];
                    // Automatic fill the textfield .
                    [JsonModelHelper clearModel: jsonView.contentView keys:fields];
                    [jsonView setModel: employeeInfo];
                    
                }
            }];
            
            [PickerModelTableView dismiss];
        };
    };
    
    
     // BTN_Adjust button
    JRButton* BTN_Adjust = (JRButton*)[jsonView getView: @"BTN_Adjust"];
    NSString* department = self.department;
    BTN_Adjust.didClikcButtonAction = ^void(JRButton* btn) {
        if([PermissionChecker checkSignedUserWithAlert: department order:ORDER_FinanceSalaryCHOrder permission:PERMISSION_CREATE]) {
            FinanceSalaryCHOrderController* jsonController = (FinanceSalaryCHOrderController*)[OrderListControllerHelper getNewJsonControllerInstance: department order:ORDER_FinanceSalaryCHOrder];
            jsonController.controlMode = JsonControllerModeCreate;
            
            NSString* employeeNO = self.valueObjects[PROPERTY_EMPLOYEENO];
            if (employeeNO) {
                [jsonController fetchEmployeeNumberData: employeeNO];
            }
            
            [VIEW.navigator pushViewController: jsonController animated:YES];
        };
    };
    
    
    
    
    
    
}



#pragma mark - Private Methods

-(void) updateSummary
{
    float summary = 0.0;
    
    for (int i = 0; i < caculateFields.count; i++) {
        JRLabelCommaTextFieldView* view = caculateFields[i];
        NSString* text = [view getValue];
        float unit = [text floatValue];
        summary += unit;
    }
    
    [summaryTextField setValue: @(summary)];
}


@end
