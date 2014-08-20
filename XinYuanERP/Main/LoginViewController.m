#import "LoginViewController.h"
#import "AppInterface.h"

#define ScheduledTaskTime 10


@interface LoginViewController () <UITextFieldDelegate, UIGestureRecognizerDelegate>

@end

@implementation LoginViewController
{
    JsonView* jsonview;
    
    UITextField *userNameTextField;
    UITextField *passwordTextField;
    
    JRImageView* verfiyImageView;
    UITextField *verifyCodeTextField;
    
    JRCheckBox* userCheckBox ;
    JRCheckBox* passwordCheckBox ;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [self getConnectToServer];
    [ACTION destroyReleaseableProcedure];
    
    // get the save username & password
    NSArray* array = [DATA.appSqlite selectFirstUserNameAndPassword];
    NSString* username = [array firstObject];
    NSString* password = [array lastObject];
    userNameTextField.text = username;
    passwordTextField.text = password;
    if (!OBJECT_EMPYT(username)) {
        userCheckBox.checked = YES;
    }
    if (!OBJECT_EMPYT(password)) {
        passwordCheckBox.checked = YES;
    }
}

#pragma mark - Double Tap Gesture Recognizer

-(void) doubleTapAction: (UITapGestureRecognizer*)doubleTapGesture
{
    [jsonview setZoomScale: 1.0 animated: YES];
}
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if (jsonview.zoomScale == 1.0) return NO;
    return YES;
}

#pragma mark - UITextFieldDelegate Methods
// userNameTextField , passwordTextField , verifyCodeTextField
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        if (jsonview.zoomScale != 2.0) [jsonview setZoomScale: 2.0 animated:YES];
    }
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - JSON VIEW TEST HERE
- (void) previewJsonView
{
    // for test , remove in production
    
    [DATA.modelsStructure renderModels: nil];
    NSMutableDictionary* categories = [DictionaryHelper deepCopy: [DATA.modelsStructure getAllOders:YES]];
    if (!categories[CATEGORIE_SHAREDORDER]) [categories setObject:[NSMutableArray array] forKey:CATEGORIE_SHAREDORDER];
//    if (!categories[DEPARTMENT_VEHICLE]) [categories setObject:[NSMutableArray array] forKey:DEPARTMENT_VEHICLE];
    [categories[DEPARTMENT_SECURITY] addObject:@"SecurityJournalOrder"];
    [CategoriesLocalizer setCategories: categories];
    [AppDataHelper dealWithSignedBasicData: nil];
    

#pragma mark - JSON VIEW TEST HERE
    NormalButton* langurageButton = [[NormalButton alloc] init];
    langurageButton.backgroundColor = WHITE_COLOR;
    langurageButton.didClikcButtonAction = ^(UIButton* button) {
        
        NSArray* localizeLanguages = [LocalizeHelper localize: LANGUAGES];
        [PopupViewHelper popSheet: @"Select a language" inView:button.superview actionBlock:^(UIView *popView, NSInteger index) {
            if (index >= 0 && index < LANGUAGES.count) {
                NSString* languageSelected = LANGUAGES[index];
                [CategoriesLocalizer setCurrentLanguage: languageSelected];
                
                // Set Preference Language
                [[NSUserDefaults standardUserDefaults] setObject: languageSelected forKey: PREFERENCE_LANGUAGE];
                [[NSUserDefaults standardUserDefaults] synchronize];

                UIView* view = [VIEW.navigator topViewController].view;
                for (UIView* subView in view.subviews) {
                    if ([subView isKindOfClass:[JsonView class]]){
                        JsonView* jsonview_ = (JsonView*)subView;
                        [JsonViewHelper refreshJsonViewLocalizeText: jsonview_];
                    }
                }

            }
        } buttonTitles: localizeLanguages];

    };
    langurageButton.frame = CGRectMake(10, 200, 50, 20);
    [ColorHelper setBorder: langurageButton];


    JsonController* jsonController = [[WHLendOutOrderController alloc] initWithOrder:@"WHLendOutOrder" department:DEPARTMENT_WAREHOUSE];
//    JsonController* jsonController = [[EmployeeQuitOrderController alloc] initWithOrder:@"EmployeeQuitOrder" department:DEPARTMENT_HUMANRESOURCE];
//    JsonController* jsonController = [[JsonController alloc] initWithOrder:@"FinanceSalary" department:DEPARTMENT_FINANCE];
//    UIViewController* jsonController = [AdminControllerDispatcher dispatchToOtherSettingsController];
    
//    NSString* sbname = @"Main_iPhone";
//    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad){
//        sbname = @"Main_iPad";
//    }
//    UIStoryboard* sb = [UIStoryboard storyboardWithName:sbname bundle:nil];
//    assert(sb != nil);
//    UIViewController* controller = [sb instantiateViewControllerWithIdentifier:@"Cards"];
//    [self presentViewController:controller animated:YES completion:nil];
    [VIEW.navigator pushViewController: jsonController animated:YES];
    [jsonController.view addSubview: langurageButton];
    [ColorHelper setBorderRecursive: jsonController.jsonView];
  

   
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
//    [self previewJsonView];
//    return;
    
    
#pragma mark - Json View
    __weak LoginViewController* weakInstance = self;
    jsonview =  (JsonView*)[JsonViewRenderHelper renderFile:@"Views" specificationsKey:@"LoginView"];
    [jsonview setViewFrame: [ViewHelper getScreenBoundsByCurrentOrientation]];
    [ColorHelper clearBorderRecursive: jsonview];
    
    [self.view addSubview: jsonview];
    
    // Check box
    userCheckBox = ((JRLabelCheckBoxView*)[jsonview getView: @"rememberUserName"]).checkBox;
    passwordCheckBox = ((JRLabelCheckBoxView*)[jsonview getView: @"rememberPawword"]).checkBox;
    
    // verify code
    verifyCodeTextField = (JRTextField*)[jsonview getView: @"verifyCode"];
    verfiyImageView = (JRImageView*)[jsonview getView: @"IMG_VerifyCodeImg"];
    verfiyImageView.didClickAction = ^(JRImageView* imageView) {
        [weakInstance getConnectToServer];
    };

    // username & password
    userNameTextField = ((JRLabelCommaTextFieldView*)[jsonview getView: @"username"]).textField;
    passwordTextField = ((JRLabelCommaTextFieldView*)[jsonview getView: @"password"]).textField;
    
    // For zooming
    userNameTextField.delegate = self;
    passwordTextField.delegate = self;
    verifyCodeTextField.delegate = self;
    UITapGestureRecognizer* doubleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapAction:)];
    doubleTapGesture.numberOfTapsRequired = 2;
    doubleTapGesture.delegate = self;
    [jsonview addGestureRecognizer: doubleTapGesture];
    
    
    // lauguage setting
    JRButton* languageButton = ((JRLabelButtonView*)[jsonview getView: @"languageSet"]).button;
    __weak JsonView* weakJsonView = jsonview;
    languageButton.didClikcButtonAction = ^(id button) {
        [AppViewHelper refreshLocalizeTextBySelectLanguage: weakJsonView];
    };
    
    // login button
    JRButton* loginButton = (JRButton*)[jsonview getView: @"loginBtn"];
    loginButton.didClikcButtonAction = ^(id sender) {
        [weakInstance loginRequest];
    };
    
    [JsonViewHelper refreshJsonViewLocalizeText: jsonview];
}

#pragma mark - Private Methods

-(void) getConnectToServer
{
    RequestJsonModel* model = [RequestJsonModel getJsonModel];
    model.path = PATH_SETTING(@"getConnection");
    
    // show indicator
    [AppViewHelper showIndicatorInViewAndDisableInteraction: verfiyImageView];
    [DATA.requester startPostRequest:model completeHandler:^(HTTPRequester* requester, ResponseJsonModel *data, NSHTTPURLResponse *httpURLReqponse, NSError *error) {
        [AppViewHelper stopIndicatorInViewAndEnableInteraction: verfiyImageView];
        if (error) {
            [ACTION alertError: error];
        } else if (data.status){
            NSDictionary* allHeaders = [httpURLReqponse allHeaderFields];
            NSString* cookie = [allHeaders objectForKey: HTTP_RES_HEADER_COOKIE];
            if (cookie) {
                // data cookie
                DATA.cookies = cookie;
                DLOG(@" ------ Models Structure & Set Cookie Success");
            }
            
            // initialize the administrators
            if ([data.descriptions isEqualToString:HR_INITAILIZED_ADMIN_KEY]) {
                [AdministratorAction initializeAdministrator];
            }
            
            // data modelstructure
            [DATA.modelsStructure renderModels: data.results];
            [CategoriesLocalizer setCategories: [DATA.modelsStructure getAllOders: YES]];
            
            // verify code
            UIImage *image = [UIImage imageWithData:data.binaryData];
            if (image) verfiyImageView.image = image;
        }
    }];
}


-(void)loginRequest
{
//    [((NSArray*)userNameTextField.text) objectAtIndex:0];
    NSString* verifyCode = verifyCodeTextField.text ? verifyCodeTextField.text : @"" ;
//    if (OBJECT_EMPYT(verifyCode)) {
//        [ACTION alertWarning: @"Verify Code Cannot Be Empty!"];
//        return;
//    }
    
    NSString* tokenStr = [UserInstance sharedInstance].DGUDID;
    NSString* username = userNameTextField.text ? userNameTextField.text : @"";
    NSString* password = passwordTextField.text ? passwordTextField.text : @"";
    
    [UserInstance sharedInstance].userJobNum = username;
    [UserInstance sharedInstance].userPwd = password;
    
    DATA.signedUserName = username;
    DATA.signedUserPassword = password;

    
    // Rember password and username
    if (passwordCheckBox.checked) {
        [DATA.appSqlite updatePassword: passwordTextField.text];
    } else {
        [DATA.appSqlite updatePassword: @""];
    }
    if (userCheckBox.checked) {
        [DATA.appSqlite updateUsername: userNameTextField.text];
    } else {
        [DATA.appSqlite updateUsername: @""];
    }
    
    // Send Login request
    RequestJsonModel* model = [RequestJsonModel getJsonModel];
    model.path = PATH_USER(@"signin");
    [model.parameters setObject:tokenStr forKey:@"APNSTOKEN"];
    [model.parameters setObject:verifyCode forKey:@"VERIFYCODE"];
    [model addModels: CATEGORIE_USER, nil];
    
    password = [AppRSAHelper encrypt: password];
    [model addObjects: @{@"username":username, @"password":  password} ,nil];

    [VIEW.progress show];
    [DATA.requester startPostRequestWithAlertTips:model completeHandler:^(HTTPRequester *requester, ResponseJsonModel *response, NSHTTPURLResponse *httpURLReqponse, NSError *error) {
        if (response.status) {
            [self getUserAuthoritysWithObject: response.results];
        } else {
            [VIEW.progress hide];
        }
    }];
}


#pragma mark - SIGN SUCCESSFULLY
-(void)getUserAuthoritysWithObject:(NSDictionary*)permissionsJsons
{
    DATA.signedUserId = [[permissionsJsons objectForKey: USER_IDENTIFIER ] integerValue];
    DATA.usersNOPermissions = [AppDataParserHelper parseUserPermissions: [permissionsJsons objectForKey: ALL_USERS_PERMISSIONS]];
    
    
    // get the refresh data first time
    __weak LoginViewController* weakInstance = self;
    [AppDataHelper refreshServerBasicData:^(BOOL isSuccess) {
        [weakInstance accessIntoWheels];
        [VIEW.progress hide];
    }];
    
    
    // start the refresh action
    static BOOL flag = NO;
    if (! flag) {
        flag = !flag;
        [ScheduledTask setSharedInstance: [[ScheduledTask alloc] initWithTimeInterval: 1]];
        [ScheduledTask.sharedInstance registerSchedule:self timeElapsed:ScheduledTaskTime repeats:0];
        [ScheduledTask.sharedInstance start];
    }
}

-(void) accessIntoWheels
{
#pragma mark - IF Administrator Signined
    if (IS_ADMINISTATOR(DATA.signedUserId)) {
        [ACTION initialiazeAdministerProcedure];
        AppWheelViewController* controller = [[AppWheelViewController alloc] init];
        controller.wheels = @[@"User_Permissions_Settings", @"Orders_Settings", @"Dropbox_Settings", @"General_Settings"];
        controller.wheelDidTapSwipLeftBlock = ^(AppWheelViewController* wheel, NSInteger index){
            UIViewController* nextController = nil;
            
            if (index == 0) {
                // User Permissions Settings
                nextController = [AdminControllerDispatcher dispatchToUsersList];
            } else if (index == 1){
                // Orders Settings
                nextController = [AdminControllerDispatcher dispatchToDepartmentsWheel];
            } else if (index == 2) {
                // Dropbox Settings
                nextController = [AdminControllerDispatcher dispatchToDropboxController];
            } else if (index == 3) {
                // Others Settings
                nextController = [AdminControllerDispatcher dispatchToOtherSettingsController];
            }
            
            if (nextController) [VIEW.navigator pushViewController:nextController animated:YES];
        };
        [VIEW.navigator pushViewController:controller animated:YES];
    }
    
    
#pragma mark - IF User Signined
    else {
        [ApproveHelper refreshBadgeIconNumber: DATA.signedUserName];
        
        AppWheelViewController* departmentWheel = [AppViewHelper getDepartmentsWheelController];
        departmentWheel.wheels = [AppDataHelper getUserCategoryWheels: DATA.signedUserName];
        departmentWheel.wheelDidTapSwipLeftBlock = ^(AppWheelViewController* wheel, NSInteger index) {
            NSString* department = [wheel.wheels objectAtIndex: index];
            UIViewController* controller = nil;
            
            
            if ([department isEqualToString: CATEGORIE_CARDS]) {
                
                NSString* sbname = @"Main_iPhone";
                if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad){
                    sbname = @"Main_iPad";
                }
                UIStoryboard* sb = [UIStoryboard storyboardWithName:sbname bundle:nil];
                assert(sb != nil);
                controller = [sb instantiateViewControllerWithIdentifier:@"Cards"];
                
            } else if ([department isEqualToString: CATEGORIE_APPROVAL] || [department isEqualToString: WHEEL_TRACE_STATUS_FILE]) {
                
                EmployeeController* employeeController = [[EmployeeController alloc] initWithOrder: MODEL_EMPLOYEE department:DEPARTMENT_HUMANRESOURCE];
                employeeController.identification = @{PROPERTY_EMPLOYEENO: DATA.signedUserName};
                employeeController.controlMode = JsonControllerModeRead;
                
                NSString* buttonKey = [department isEqualToString: CATEGORIE_APPROVAL] ? @"ZZ_TAB_BTNPending" : @"TraceStatus";
                JRButton* actionButton = (JRButton*)[employeeController.jsonView getView:buttonKey];
                [actionButton sendActionsForControlEvents: UIControlEventTouchUpInside];
                controller = employeeController;

                
                
            } else {
                
                // show the orders
                AppWheelViewController* orderWheel = [AppViewHelper getOrdersWheelController];
                orderWheel.wheels = [AppDataHelper getUserModelWheels: DATA.signedUserName department:department];
                JsonBranchFactory* branchFactory = [JsonBranchFactory factoryCreateBranch: department];
                orderWheel.wheelDidTapSwipLeftBlock = ^(AppWheelViewController* wheel, NSInteger index) {
                    NSString* order = [wheel.wheels objectAtIndex: index];
                    
                    NSString* orderClazzString = [NSString stringWithFormat:@"%@%@", order, @"ListController"];
                    BaseOrderListController* orderListController = [[NSClassFromString(orderClazzString) alloc] init];
                    if (!orderListController) {
                        orderListController = [[BaseOrderListController alloc] init ];
                    }
                    
                    orderListController.order = order;
                    orderListController.department = department;
                    [branchFactory handleOrderListController: orderListController order:order];
                    [VIEW.navigator pushViewController:orderListController animated:YES];
                };
                controller = orderWheel;
                
            }
            
            if ([controller isKindOfClass:[UINavigationController class]]){
                [self presentViewController:controller animated:YES completion:nil];
            }else{
                [VIEW.navigator pushViewController: controller animated:YES];
            }
        };
        
        [VIEW.navigator pushViewController:departmentWheel animated:YES];
    }
    
}


#pragma mark - Scheduled Action

-(void) scheduledTask
{
    if ([VIEW isTestDevice]) return;
    
    [AppDataHelper refreshServerBasicData:nil];
}

@end
