#import "AdministratorAction.h"
#import "AppInterface.h"

@implementation AdministratorAction


-(void) savePermissions: (NSString*)username permissions:(NSString*)permission categories:(NSString*)categories completeHandler:(void (^)(NSError* errorObj))completeHandler {
    // Save the user's permission
    NSArray* objects = @[@{@"permissions":permission,@"categories":categories}];
    NSArray* model = @[PATH_ADMIN(@"modifyUserPermissions"), @{req_MODELS:@[DOT_CATEGORY_DOT_MODEL(CATEGORIE_USER,MODEL_USER)], req_OBJECTS:objects, req_IDENTITYS:@[@{@"username":username}]}];
    
    [DATA.requester startPostRequest:(RequestJsonModel*)model completeHandler:^(HTTPRequester* requester, ResponseJsonModel *data, NSHTTPURLResponse *httpURLReqponse, NSError *error) {
        if (completeHandler) completeHandler(error);
    }];
}

-(void) saveExpiredDate: (NSString*)department order:(NSString*)order identifier:(id)identifier date:(NSDate*)date completeHandler:(void (^)(NSError* errorObj))completeHandler {
    RequestJsonModel* model = [RequestJsonModel getJsonModel];
    model.path = PATH_LOGIC_MODIFY(department);
    [model addModels: order, nil];
    [model addObjects: @{@"expiredDate": [Utility stringFromDate:date]}, nil];
    [model.identities addObject:@{@"id":identifier}];
    
    [DATA.requester startPostRequest:model completeHandler:^(HTTPRequester* requester, ResponseJsonModel *data, NSHTTPURLResponse *httpURLReqponse, NSError *error) {
        if (completeHandler) completeHandler(error);
    }];
}





+(void) initializeAdministrator
{
    if ([PopupViewHelper isCurrentPopingView]) return;
    [PopupViewHelper popAlert:LOCALIZE_MESSAGE(HR_INITAILIZED_ADMIN_KEY) message:LOCALIZE_MESSAGE(@"Ask_Setting_Now") style:0 actionBlock:nil dismissBlock:^(UIView *popView, NSInteger index) {
        if (index == 1) {
            
            // show
            JsonView* mainJsonView =  (JsonView*)[JsonViewRenderHelper renderFile:@"Components" specificationsKey:@"InitializeMainUser"];
            [ColorHelper clearBorderRecursive: mainJsonView];
            [PopupViewHelper popView:mainJsonView inView:[ViewHelper getTopView] tapOverlayAction:^void(UIControl* control){} willDissmiss:nil];
            UIView* mainDivView = [mainJsonView getView:@"NESTED_Body"];
            mainDivView.center = [mainDivView.superview middlePoint];
            // close button
            JRButton* closeBTN = (JRButton*)[mainJsonView getView:@"BTN_Close"];
            closeBTN.didClikcButtonAction = ^(JRButton* button) {
                [PopupViewHelper dissmissCurrentPopView];
            };
            // event
            JRButton* nextBTN = (JRButton*)[mainJsonView getView:@"next"];
            nextBTN.didClikcButtonAction = ^void(JRButton* button) {
                
                // check
                if (! [AdministratorAction isSuccess: mainJsonView notEmpties:@[@"username", @"password", @"re_password"] shouldEquals:@[@[@"password", @"re_password"]]]) return;
                
                NSDictionary* mainObects = [mainJsonView getModel];
                [PopupViewHelper dissmissCurrentPopView];
                
                
                // show next
                [VIEW.progress show];
                [VIEW.progress hide: YES afterDelay:1.2];
                double delayInSeconds = 0.8;
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    
                    // show
                    JsonView* minorJsonView =  (JsonView*)[JsonViewRenderHelper renderFile:@"Components" specificationsKey:@"InitializeMinorUser"];
                    [ColorHelper clearBorderRecursive: minorJsonView];
                    [PopupViewHelper popView:minorJsonView inView:[ViewHelper getTopView] tapOverlayAction:^void(UIControl* control){} willDissmiss:nil];
                    UIView* minorDivView = [minorJsonView getView:@"NESTED_Body"];
                    minorDivView.center = [minorDivView.superview middlePoint];
                    // close button
                    JRButton* closeBTN = (JRButton*)[minorJsonView getView:@"BTN_Close"];
                    closeBTN.didClikcButtonAction = ^(JRButton* button) {
                        [PopupViewHelper dissmissCurrentPopView];
                    };
                    // event
                    JRButton* submitBTN = (JRButton*)[minorJsonView getView:@"submit"];
                    submitBTN.didClikcButtonAction = ^void(JRButton* button) {
                        [PopupViewHelper dissmissCurrentPopView];
                        
                        // check
                        if (! [AdministratorAction isSuccess: minorJsonView notEmpties:@[@"username", @"password", @"re_password"] shouldEquals:@[@[@"password", @"re_password"]]]) return;
                        
                        NSDictionary* minorObjects = [minorJsonView getModel];
                        
                        RequestJsonModel* requestModel = [RequestJsonModel getJsonModel];
                        requestModel.path = @"/user/signup";
                        [requestModel addModels: MODEL_USER, MODEL_USER, nil];
                        [requestModel addObjects: mainObects, minorObjects, nil ];
                        
                        [VIEW.progress show];
                        [DATA.requester startPostRequest:requestModel completeHandler:^(HTTPRequester* requester, ResponseJsonModel *data, NSHTTPURLResponse *httpURLReqponse, NSError *error) {
                            [VIEW.progress hide];
                            
                            if (data.status) {
                                [PopupViewHelper popAlert:LOCALIZE_KEY(@"message") message:LOCALIZE_MESSAGE(@"Create_Admin_Successfully") style:0 actionBlock:nil dismissBlock:nil buttons:LOCALIZE_KEY(@"OK"), nil];
                                
                            } else {
                                [ACTION alertError: @"Create Administrators Failed"];
                            }
                        }];
                    };
                    
                });
                
            };
            
            
        }
    } buttons:LOCALIZE_KEY(@"CANCEL"), LOCALIZE_KEY(@"OK"), nil];
}


+(BOOL) isSuccess: (JsonView*)jsonview notEmpties:(NSArray*)notEmpties shouldEquals:(NSArray*)shouldEquals
{
    NSString* message = nil;
    // check values
    [JsonControllerHelper validateNotEmptyObjects: notEmpties jsonView:jsonview message:&message];
    if (!message) [JsonControllerHelper validateShouldEqualsObjects:shouldEquals jsonView:jsonview message:&message];
    if (message) {
        [ACTION alertMessage: message];
        return NO;
    }
    
    return YES;
}

@end
