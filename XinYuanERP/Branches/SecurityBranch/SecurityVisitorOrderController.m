#import "SecurityVisitorOrderController.h"

@interface SecurityVisitorOrderController ()<UITableViewDelegate>

@end

@implementation SecurityVisitorOrderController{
    NSString* currentDate;
    
    JRButton* acceptButton;
    JRTextField* acceptLabel;
    
    JRButton* passInButton;
    JRTextField* passIn_time,*passIn_name;
    JRButton* passOutButton;
    JRTextField* passOut_time, *passOut_name;
    
    JRButton* stuffButton;
    JRButton* camButton;
}
@synthesize imagePicker;

-(void) viewDidLoad{
    [super viewDidLoad];
    currentDate = [DateHelper stringFromDate:[NSDate date] pattern:PATTERN_DATE_TIME];
    
    JRButtonTextFieldView* acceptStack = (JRButtonTextFieldView*)[self.jsonView getView:@"doneButton"];
    acceptButton = (JRButton*)acceptStack.button;
    acceptLabel = (JRTextField*)acceptStack.textField;
    
    JRButtonTextFieldView* passInStack = (JRButtonTextFieldView*)[self.jsonView getView:@"passIn_time"];
    passInButton = (JRButton*)passInStack.button;
    passIn_time = (JRTextField*)passInStack.textField;
    passIn_name = ((JRLabelTextFieldView*)[self.jsonView getView:@"passIn_name"]).textField;
    
    JRButtonTextFieldView* passOutStack = (JRButtonTextFieldView*)[self.jsonView getView:@"passOut_time"];
    passOutButton = (JRButton*)passOutStack.button;
    passOut_time = (JRTextField*)passOutStack.textField;
    passOut_name = ((JRLabelTextFieldView*)[self.jsonView getView:@"passOut_name"]).textField;
    
    stuffButton = (JRButton*)[self.jsonView getView:@"stuff_button"];
    camButton = (JRButton*)[self.jsonView getView:@"camButton"];
    
    [self registerButtonEvent];
}

-(void) registerButtonEvent{
    int weak_mode = self.controlMode;
    __weak NSString* weak_date = currentDate;
    //done button pressed, fill the
    //current user name in the acceptLabel
    __weak JRTextField* acceptLabel_weak = acceptLabel;
    NSString* oid = [self.identification stringValue];
    NSString* userID = [NSString stringWithFormat:@"%d",DATA.signedUserId];
    acceptButton.didClikcButtonAction = ^void(id sender){
        acceptLabel_weak.text = DATA.signedUserName;
        if (weak_mode == JsonControllerModeRead){
            //start request to modify
            [AppServerRequester modifyModel:@"SecurityVisitorOrder" department:DEPARTMENT_SECURITY objects:@{@"doneButtonEmployeeNO":userID} identities:@{@"id":oid} completeHandler:^(ResponseJsonModel *data, NSError *error) {
                if (!error)
                    NSLog(@"modify successd");
            }];
        }
    };
    
    //Pass In button pressed.
    //get current time fill in passIn_time
    //get current user name(security) in passIn_name
    //NOTE: we should create this business when
    //user press this button, and maybe push notify
    //associate person? not sure
    __weak JRTextField* passIn_time_weak = passIn_time;
    __weak JRTextField* passIn_name_weak = passIn_name;
    NormalButtonDidClickBlock previousBlock = passInButton.didClikcButtonAction;
    passInButton.didClikcButtonAction = ^void(id sender){
        if (weak_mode == JsonControllerModeCreate){
            
            passIn_time_weak.text = weak_date;
            //get current user info
            passIn_name_weak.text = DATA.signedUserName;
            if(previousBlock) previousBlock(sender);
        }
    };
    
    //Pass Out button pressed.
    //get current time fill in passOut_time
    //get current user name(security) in passOut_time
    __weak JRTextField* passOut_time_weak = passOut_time;
    __weak JRTextField* passOut_name_weak = passOut_name;
    passOutButton.didClikcButtonAction = ^void(id sender){
        passOut_time_weak.text = weak_date;
        passOut_name_weak.text = DATA.signedUserName;
        if (weak_mode == JsonControllerModeRead){
            //start request to modify
            [AppServerRequester modifyModel:@"SecurityVisitorOrder" department:DEPARTMENT_SECURITY objects:@{@"passOut_name":userID, @"passOut_time":[DateHelper stringFromDate:[NSDate date] pattern:PATTERN_DATE_TIME]} identities:@{@"id":oid} completeHandler:^(ResponseJsonModel *data, NSError *error) {
                if (!error)
                    NSLog(@"modify successd");
            }];
        }
    };
    
    
    //cam button, pop imagPicker controller
}

@end
