#import "EmployeeLeaveOrderController.h"
#import "AppInterface.h"

@interface EmployeeLeaveOrderController ()

@end

@implementation EmployeeLeaveOrderController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    JsonView* jsonView = self.jsonView;
    
    NSArray* infosFields = @[@"name", @"department",@"jobTitle"];
    
    
    // employeeNO. TextField
    JsonDivView* bodyDivView = (JsonDivView*)[jsonView getView:@"NESTED_MIDDLE_1"];
    JRTextField* employeeNOTextField = ((JRLabelTextFieldView*)[jsonView getView: PROPERTY_EMPLOYEENO]).textField;
    
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
                [JsonModelHelper clearModel: bodyDivView exceptkeys:@[@"line1", @"line2", @"line3", @"line4"]];
                [bodyDivView setModel: modelToRender];
            }];
            
            [PickerModelTableView dismiss];
        };
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

@end
