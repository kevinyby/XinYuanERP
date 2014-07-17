#import "EmployeeCHOrderController.h"
#import "AppInterface.h"



#define OLD_SUFFIX @"_O"
#define NEW_SUFFIX @"_N"



@implementation EmployeeCHOrderController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    __weak EmployeeCHOrderController* weakInstance = self;
    
    JsonView* jsonView = self.jsonView;
    
    JRImageView* photoImageView = (JRImageView*)[jsonView getView: @"IMG_Photo_old"];
    
    // employeeNO. button
    JRTextField* employeeNOBTN = ((JRLabelCommaTextFieldView*)[jsonView getView: PROPERTY_EMPLOYEENO]).textField;
    employeeNOBTN.textFieldDidClickAction = ^void(id sender) {
        // popup a table
        PickerModelTableView* pickView = [PickerModelTableView popupWithModel:MODEL_EMPLOYEE willDimissBlock:nil];
        // all the employee , include the resigned
        NSMutableArray* numbers = [ArrayHelper deepCopy: [DATA.usersNONames allKeys]];
        [PickerModelTableView setEmployeesNumbersNames:pickView.tableView.tableView numbers:numbers];
        
        pickView.titleHeaderViewDidSelectAction = ^void(JRTitleHeaderTableView* headerTableView, NSIndexPath* indexPath, TableViewBase* tableView){
            NSString* employeeNO = [tableView realContentForIndexPath: indexPath];
            NSDictionary* objects = @{PROPERTY_EMPLOYEENO: employeeNO};
            [VIEW.progress show];
            [AppServerRequester readModel: MODEL_EMPLOYEE department:DEPARTMENT_HUMANRESOURCE objects:objects completeHandler:^(ResponseJsonModel *data, NSError *error) {
                [VIEW.progress hide];
                if (error) {
                    [ACTION alertError: error];
                } else {
                    NSDictionary* employeeInfo = [[data.results firstObject] firstObject];
                    NSMutableDictionary* objects = [DictionaryHelper deepCopy: employeeInfo];
                    if (objects[@"livingAddress"]) [objects setObject:[RSAKeysKeeper simpleDecrypt:objects[@"livingAddress"]] forKey:@"livingAddress"];
                    NSArray* excepts = @[PROPERTY_EMPLOYEENO];
                    
                    NSMutableDictionary* oldModel = [DictionaryHelper tailKeys: objects with:OLD_SUFFIX excepts:excepts];
                    NSMutableDictionary* newModel = [DictionaryHelper tailKeys: objects with:NEW_SUFFIX excepts:excepts];

                    // Automatic fill the textfield .
                    [jsonView clearModel];
                    [jsonView setModel: oldModel];      // set the old
                    [jsonView setModel: newModel];      // set the new
                    [jsonView setModel: @{PROPERTY_EMPLOYEENO: employeeInfo[PROPERTY_EMPLOYEENO]}];  // set the unchanged
                    
                    // Load the Original Photo
                    weakInstance.valueObjects = oldModel;
                    NSString* originalPhotoPath = [JsonControllerHelper getImageNamePathWithOrder: MODEL_EMPLOYEE attribute:@"IMG_Photo" jsoncontroller:weakInstance];
                    
                    [AppViewHelper showIndicatorInView:photoImageView];
                    [AppServerRequester getImage: originalPhotoPath completeHandler:^(id identification, UIImage *image, NSError *error) {
                        [AppViewHelper stopIndicatorInView: photoImageView];
                        photoImageView.image = image;
                    }];
                }
            }];
            
            [PickerModelTableView dismiss];
        };
    };
    
    
    // OVERRIDE THE APP4 BUTTON
    JRButton* app4Button = ((JRButtonTextFieldView*)[jsonView getView:@"NESTED_footer.app4"]).button;
    NormalButtonDidClickBlock preClickAction = app4Button.didClikcButtonAction;
    app4Button.didClikcButtonAction = ^void(JRButton* button){
        preClickAction(button); // call super/ old;
        
        NSString* originalPhotoPath = [JsonControllerHelper getImageNamePathWithOrder: MODEL_EMPLOYEE attribute:@"IMG_Photo" jsoncontroller:weakInstance];
        
        NSString* newPhotoPath = [JsonControllerHelper getImageNamePathWithOrder: ORDER_EmployeeCHOrder attribute:@"IMG_Photo_new" jsoncontroller:weakInstance];
        [DATA.requester startPostRequest:IMAGE_URL(@"replace") parameters:@{@"PATH":newPhotoPath, @"DESTINATION_PATH":originalPhotoPath} completeHandler:^(HTTPRequester *requester, ResponseJsonModel *model, NSHTTPURLResponse *httpURLReqponse, NSError *error) {
            NSLog(@"DONE!!!!~~~~~~~~");
        }];
    };
}

#pragma mark - Override Super Class
-(BOOL) validateSendObjects: (NSMutableDictionary*)objects order:(NSString*)order
{
    NSString* workMask = [((id<JRComponentProtocal>)[self.jsonView getView:@"password_N"]) getValue];
    if (!OBJECT_EMPYT(workMask)) {
        if (workMask.length < 7 || [workMask rangeOfCharacterFromSet:[NSCharacterSet decimalDigitCharacterSet]].location == NSNotFound || [workMask rangeOfCharacterFromSet:[NSCharacterSet letterCharacterSet]].location == NSNotFound) {
            [ACTION alertMessage:LOCALIZE_MESSAGE(@"PasswordEnhanced")];
            return NO;
        }
    }
    
    return [super validateSendObjects:objects order:order];
}

-(void)translateSendObjects:(NSMutableDictionary *)objects order:(NSString *)order
{
    [super translateSendObjects:objects order:order];
    
    // rsa
    if (objects[@"password_N"]) {
        NSString* encryptWordMask = [AppRSAHelper encrypt: objects[@"password_N"]];
        if (encryptWordMask) {
            [objects setObject: encryptWordMask forKey:@"password_N"];
        }
    }
    //
    if (objects[@"livingAddress_O"]) [objects setObject:[RSAKeysKeeper simpleEncrypty:objects[@"livingAddress_O"]] forKey:@"livingAddress_O"];
    if (objects[@"livingAddress_N"]) [objects setObject:[RSAKeysKeeper simpleEncrypty:objects[@"livingAddress_N"]] forKey:@"livingAddress_N"];
}

-(void)translateReceiveObjects:(NSMutableDictionary *)objects
{
    [super translateReceiveObjects:objects];
    
    if (![JsonControllerHelper isAllApplied: self.order valueObjects:objects]) {
        NSString* decryptWordMask = [AppRSAHelper decrypt: objects[@"password_N"]];
        [objects setObject: decryptWordMask forKey:@"password_N"];
    }
    
    //
    if (objects[@"livingAddress_O"]) [objects setObject:[RSAKeysKeeper simpleDecrypt:objects[@"livingAddress_O"]] forKey:@"livingAddress_O"];
    if (objects[@"livingAddress_N"]) [objects setObject:[RSAKeysKeeper simpleDecrypt:objects[@"livingAddress_N"]] forKey:@"livingAddress_N"];
}


@end
