#import "AdminControllerDispatcher.h"
#import "AppInterface.h"

@implementation AdminControllerDispatcher

// User Permissions Settings
+(AppSearchTableViewController*) dispatchToUsersList
{
    AppSearchTableViewController* userList = [[AppSearchTableViewController alloc] init];       // want to update by server , set request model
    userList.headers = @[PROPERTY_EMPLOYEENO, PROPERTY_EMPLOYEE_NAME];
    userList.headersXcoordinates = @[@(50), @(400)];
    
    // numbers
    NSMutableArray* numbers = [ArrayHelper deepCopy: [DATA.usersNONames allKeys]];
    [numbers sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 compare: obj2];
    }];
    // numbers and username
    NSMutableArray* contentsTemp = [NSMutableArray array];
    [IterateHelper iterate: numbers handler:^BOOL(int index, id obj, int count) {
        [contentsTemp addObject: @[obj, DATA.usersNONames[obj]]];
        return NO;
    }];
    
    userList.contentsDictionary = [NSMutableDictionary dictionaryWithObject:contentsTemp forKey:@""];
    userList.realContentsDictionary = [NSMutableDictionary dictionaryWithObject:numbers forKey:@""];
    
    // did click event
    userList.headerTableView.tableView.tableViewBaseDidSelectAction = ^void(TableViewBase* tableViewObj, NSIndexPath* indexPath)
    {
        FilterTableView* filterTableView = (FilterTableView*)tableViewObj;
        NSIndexPath* realIndexPath = [filterTableView getRealIndexPathInFilterMode: indexPath];
        NSString* userNumber = [filterTableView realContentForIndexPath: realIndexPath];
        NSString* employeeName = DATA.usersNONames[userNumber];
        NSMutableArray* actionButtons = [NSMutableArray arrayWithObjects:
                                         LOCALIZE_MESSAGE(@"SettingUserPermissions"),
                                         LOCALIZE_MESSAGE(@"CopyUserAllPermissions"),
                                         LOCALIZE_MESSAGE(@"DeleteUserAllPermissions"),
                                         nil];
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)  [actionButtons addObject: LOCALIZE_KEY(@"CANCEL")];
        UIActionSheet* actionSheet =
        [PopupViewHelper popSheet: employeeName inView:[ViewHelper getTopView] actionBlock:^(UIView *view, NSInteger buttonIndex) {
            UIViewController* controller = nil;
//            UIActionSheet* actionSheet = (UIActionSheet*)view;
//            NSString* clickButtonTitle = [actionSheet buttonTitleAtIndex: buttonIndex];
            
            if (buttonIndex == 0) {
                // edit the permissions
                DepartmentsEditController *departmentController = [[DepartmentsEditController alloc] init];
                departmentController.userNumber = userNumber;
                departmentController.wheels = [AppDataHelper getAllUserCategoryWheels];

                controller = departmentController;
                
            } else if (buttonIndex == 1) {
                // copy the permission to another user
                PickerModelTableView* pickView = [PickerModelTableView popupWithModel:MODEL_EMPLOYEE willDimissBlock:nil];  // popup a users table
                float centerx = pickView.titleLabel.center.x;
                pickView.titleLabel.text = LOCALIZE_MESSAGE_FORMAT(@"CopyUserAllPermissionsSelect", userNumber);
                [pickView.titleLabel adjustWidthToFontText];
                [pickView.titleLabel setCenterX: centerx];
                pickView.titleHeaderViewDidSelectAction = ^void(JRTitleHeaderTableView* headerTableView, NSIndexPath* indexPath){
                    FilterTableView* filterTableView = (FilterTableView*)headerTableView.tableView.tableView;
                    NSIndexPath* realIndexPath = [headerTableView.tableView.tableView getRealIndexPathInFilterMode: indexPath];
                    NSString* toUserNumber = [filterTableView realContentForIndexPath: realIndexPath];
                    
                    if ([userNumber isEqualToString: toUserNumber]) return;
                    
                    [PopupViewHelper popAlert:nil message:LOCALIZE_MESSAGE_FORMAT(@"AskSureToCopyPermissionTo", userNumber, toUserNumber ) style:0 actionBlock:^(UIView *popView, NSInteger index) {
                        
                        if ([[((UIAlertView*)popView) buttonTitleAtIndex: index] isEqualToString: LOCALIZE_KEY(@"OK")]) {
                            
                            // source
                            NSMutableArray* sourceCategories = [[DATA.usersNOPermissions objectForKey: userNumber] objectForKey:CATEGORIES];
                            NSMutableDictionary* sourcePermissions = [[DATA.usersNOPermissions objectForKey: userNumber] objectForKey:PERMISSIONS];
                            // destination
                            NSMutableArray* destinationCategories = [[DATA.usersNOPermissions objectForKey: toUserNumber] objectForKey:CATEGORIES];
                            NSMutableDictionary* destinationPermissions = [[DATA.usersNOPermissions objectForKey: toUserNumber] objectForKey:PERMISSIONS];
                            [destinationCategories setArray:[ArrayHelper deepCopy:sourceCategories]];
                            [destinationPermissions setDictionary:[DictionaryHelper deepCopy: sourcePermissions]];
                            
                            // save user's permissions and categories
                            [VIEW.progress show];
                            VIEW.progress.detailsLabelText = APPLOCALIZE_KEYS(@"KEYS.", @"In_Process", @"save");
                            [DepartmentsEditController saveUserPermissions: toUserNumber categories:destinationCategories permissions:destinationPermissions completion:^(NSError *error) {
                                if (!error) {
                                    // save approvalSettings
                                    [DictionaryHelper duplicate: DATA.approvalSettings copy:userNumber with:toUserNumber];
                                    
                                    NSString* json = [CollectionHelper convertJSONObjectToJSONString: DATA.approvalSettings];
                                    VIEW.progress.detailsLabelText = @"Saving Approvals ...";
                                    [AppServerRequester modifySetting:APPSettings_TYPE_ADMIN_ORDERSAPPROVALS json:json completeHandler:^(ResponseJsonModel *data, NSError *error) {
                                        [VIEW.progress hide];
                                        if (error) {
                                            [ACTION alertMessage: @"Settings Failed , please try again later."];
                                        }
                                    }];
                                } else {
                                    [ACTION alertMessage: @"Settings Failed , please try again later."];
                                }
                            }];
                            
                            [PickerModelTableView dismiss];
                        }
                    } dismissBlock:nil buttons:LOCALIZE_KEY(@"CANCEL"), LOCALIZE_KEY(@"OK"), nil];
                    
                };
                
            } else if (buttonIndex == 2) {
                // delete all the user's permissions
                [PopupViewHelper popAlert:nil message:LOCALIZE_MESSAGE_FORMAT(@"AskSureToDeletePermissionOf", userNumber ) style:0 actionBlock:^(UIView *popView, NSInteger index) {
                    
                    if ([[((UIAlertView*)popView) buttonTitleAtIndex: index] isEqualToString: LOCALIZE_KEY(@"OK")]) {
                        
                        NSMutableArray* categories = [[DATA.usersNOPermissions objectForKey: userNumber] objectForKey:CATEGORIES];
                        NSMutableDictionary* permissions = [[DATA.usersNOPermissions objectForKey: userNumber] objectForKey:PERMISSIONS];
                        [categories removeAllObjects];
                        [permissions removeAllObjects];
                        
                        // save
                        [VIEW.progress show];
                        [DepartmentsEditController saveUserPermissions: userNumber categories:categories permissions:permissions completion:^(NSError *error) {
                            if (!error) {
                                // save approvalSettings
                                [DictionaryHelper delete: DATA.approvalSettings content:userNumber];
                                NSString* json = [CollectionHelper convertJSONObjectToJSONString:DATA.approvalSettings];
                                VIEW.progress.detailsLabelText =  APPLOCALIZE_KEYS(@"KEYS.", @"In_Process", @"save");
                                [AppServerRequester modifySetting:APPSettings_TYPE_ADMIN_ORDERSAPPROVALS json:json completeHandler:^(ResponseJsonModel *data, NSError *error) {
                                    [VIEW.progress hide];
                                    if (error) {
                                        [ACTION alertMessage: @"Settings Failed , please try again later."];
                                    }
                                }];
                            } else {
                                [ACTION alertMessage: @"Settings Failed , please try again later."];
                            }
                        }];
                        
                    }
                } dismissBlock:nil buttons:LOCALIZE_KEY(@"CANCEL"), LOCALIZE_KEY(@"OK"), nil];
                
            }
            
            if (controller) [VIEW.navigator pushViewController: controller animated:YES];
            
        } buttonTitles: actionButtons];
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) actionSheet.cancelButtonIndex = actionSheet.numberOfButtons - 1;
    };
    return userList;
}

// Orders Settings
+(AppWheelViewController*) dispatchToDepartmentsWheel
{
    // departments wheel
    AppWheelViewController* departmentsWheel = [[AppWheelViewController alloc] init]; //[AppViewHelper getDepartmentsWheelController];
    NSArray* allCategories = [DATA.modelsStructure getAllCategories];
    NSMutableArray* wheels = [NSMutableArray array];
    for (NSString* category in allCategories) {
        int orderBillCount = [[DATA.modelsStructure getOrders:category withBill:YES] count];
        if (orderBillCount) [wheels addObject: category];
    }
    
    departmentsWheel.wheels = [ArrayHelper reRangeContents: wheels frontContents:DATA.config[@"WHEELS"][@"SORTED_Categories"]];
    
    // when click
    departmentsWheel.wheelDidTapSwipLeftBlock = ^(AppWheelViewController* wheel, NSInteger index){
        NSString* department = [wheel.wheels objectAtIndex: index];
        
        // orders wheel , with bill
        AppWheelViewController* ordersWheel = [[AppWheelViewController alloc] init]; //[AppViewHelper getOrdersWheelController];
        NSArray* ordersBillsTemp = [DATA.modelsStructure getOrders: department withBill:NO];
        NSMutableArray* userVisualOrders = [ArrayHelper deepCopy: ordersBillsTemp];

        // remove the contains, ie. EmployeeQuitOrder with EmployeeQuitPassOrder
        [DATA.modelsStructure removeInsertModelsIn: userVisualOrders];
        
         // empty
        if (! userVisualOrders.count) return ;
        
        // set the wheels
        ordersWheel.wheels = [ArrayHelper reRangeContents: userVisualOrders frontContents:DATA.config[@"WHEELS"][@"SORTED_Models"][department]];
        
        // when click
        ordersWheel.wheelDidTapSwipLeftBlock = ^(AppWheelViewController* wheel, NSInteger orderIndex){
            NSString* orderType = [wheel.wheels objectAtIndex: orderIndex];
            
            // checkout have 'app1' or not
            NSArray* properties = [[DATA.modelsStructure getModelStructure: orderType] allKeys];
            BOOL isHaveApproval = [properties containsObject: levelApp1] ;
            // set the buttons
            NSArray* buttons = isHaveApproval ? @[LOCALIZE_KEY(@"Approvals_Settings"), LOCALIZE_KEY(@"Expriations_Settings")] : @[LOCALIZE_KEY(@"Expriations_Settings")];
            NSMutableArray* actionButtons = [ArrayHelper deepCopy: buttons];

            
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)  [actionButtons addObject: LOCALIZE_KEY(@"CANCEL")];
            UIActionSheet* actionSheet =
             [PopupViewHelper popSheet: LOCALIZE_MESSAGE(@"SelectAnAction") inView:wheel.view actionBlock:^(UIView *view, NSInteger buttonIndex) {
                 if (buttonIndex < 0 ) return ;
                 UIActionSheet* actionSheet = (UIActionSheet*)view;
                 NSString* clickButtonTitle = [actionSheet buttonTitleAtIndex: buttonIndex];
                 
                 
                 UIViewController* controller = nil;
                 if ([clickButtonTitle isEqualToString:LOCALIZE_KEY(@"Expriations_Settings")]) {
                     // Expriations Settings
                     controller = [AdminControllerDispatcher dispatchToExpirationOrderController: department order:orderType];
                 } else if ([clickButtonTitle isEqualToString:LOCALIZE_KEY(@"Approvals_Settings")]) {
                     // Approvals Settings
                     controller = [AdminControllerDispatcher dispatchToApprovalSettingController: department order:orderType];
                 }
                 if (controller) [VIEW.navigator pushViewController: controller animated:YES];
                
            } buttonTitles: actionButtons];
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) actionSheet.cancelButtonIndex = actionSheet.numberOfButtons - 1;
            
        };
        
        [VIEW.navigator pushViewController: ordersWheel animated:YES];
    };
    
    return departmentsWheel;
}


+(UIViewController*) dispatchToDropboxController
{
    BaseController* dropBoxController = [[SetDropboxController alloc] init];
    
    dropBoxController.viewWillAppearBlock = ^void(BaseController* controller, BOOL animated){
        if (! [DropboxSyncAPIManager getLinkedAccount]) {
            [DropboxSyncAPIManager authorize: VIEW.navigator.topViewController];
        }
    };
    
    return dropBoxController;
}

+(UIViewController*) dispatchToOtherSettingsController
{
    APNSCategoriesController* controller = [[APNSCategoriesController alloc] init];
    return controller;
}



#pragma mark - Private Methods
// expiration
+(UIViewController*) dispatchToExpirationOrderController: (NSString*)department order:(NSString*)order
{
    SetExpirationsController* viewController = [[SetExpirationsController alloc] initWithOrder:order department:department];
    return viewController;
}


// Approvals Settings
+(SetApprovalsController*) dispatchToApprovalSettingController: (NSString*)department order:(NSString*)order
{
    NSString* clazzstring = [order stringByAppendingString: @"SetApprovalsController"];
    Class clazz = NSClassFromString(clazzstring);
    
    SetApprovalsController* viewController = nil;
    if (clazz != NULL) {
        viewController = [[clazz alloc] initWithOrder:order department:department];
    } else {
        viewController = [[SetApprovalsController alloc] initWithOrder: order department:department];
    }
    
    return viewController;
}

@end
