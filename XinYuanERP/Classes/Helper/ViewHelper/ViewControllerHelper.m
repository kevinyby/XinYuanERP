#import "ViewControllerHelper.h"
#import "AppInterface.h"

@implementation ViewControllerHelper

+(CGRect) getLandscapeBounds
{
    CGRect rect = [ViewHelper getScreenBoundsByCurrentOrientation];
    CGFloat longWidth = MAX(rect.size.width, rect.size.height);
    CGFloat shortHeight = MIN(rect.size.width, rect.size.height);
    CGRect landScapeRect = CGRectMake(0, 0, longWidth, shortHeight);
    return landScapeRect;
}

/** @prama dictionary ,which is two dimesion, first dimension element is NSMutableDictionary , second dimesion element is NSArray*/
+(void) filterDictionaryEmptyElement: (NSMutableDictionary*)dictionary {
    NSArray* allKeys = [dictionary allKeys];
    for (NSString* department in allKeys) {
        NSMutableDictionary* ordersPermission = [dictionary objectForKey: department];
        
        NSArray* allKeys = [ordersPermission allKeys];
        for (NSString* order in allKeys) {
            NSArray* permissions = [ordersPermission objectForKey: order];
            
            if (permissions.count == 0) {
                [ordersPermission removeObjectForKey: order];
            }
        }
        
        if (ordersPermission.count == 0) {
            [dictionary removeObjectForKey: department];
        }
    }
}

+(UIViewController*) getPreviousViewControllerBeforePushSelf {
    NSArray* viewControllers = VIEW.navigator.viewControllers;
    return [viewControllers objectAtIndex: viewControllers.count - 1];
}


#pragma mark - 

+(void) popApprovalView: (NSString*)app department:(NSString*)department order:(NSString*)order selectAction:(void(^)(NSString* number))selectAction cancelAction:(void(^)(id sender))cancelAction sendAction:(void(^)(id sender, NSString* number))sendAction
{
    __block NSString* selectNumber = nil;
    
    UIView* superView = [PopupTableHelper getCommonPopupTableView];
    JRButtonsHeaderTableView* searchTableView = (JRButtonsHeaderTableView*)[superView viewWithTag: POPUP_TABLEVIEW_TAG];
    
    NSMutableArray* users = [self getApprovalsUsers: app department:department order:order];
    searchTableView.tableView.headers = @[LOCALIZE_KEY(@"number"), LOCALIZE_KEY(@"name")];
    [PickerModelTableView setEmployeesNumbersNames:searchTableView.tableView.tableView numbers:users];
    
    searchTableView.tableView.tableView.tableViewBaseDidSelectAction = ^void(TableViewBase* tableViewObj, NSIndexPath* indexPath) {
        NSIndexPath* realIndexPath = [(FilterTableView*)tableViewObj getRealIndexPathInFilterMode: indexPath];
        selectNumber = [tableViewObj realContentForIndexPath: realIndexPath];
        if (selectAction) selectAction(selectNumber);
    };
    searchTableView.tableView.headerTableViewHeaderHeightAction = ^CGFloat(HeaderTableView* tableViewObj) {
         return [FrameTranslater convertCanvasHeight: 25.0f];
    };

    // cancel button
    JRButton* cancelBtn = searchTableView.leftButton ;
    [cancelBtn setTitle:LOCALIZE_KEY(@"CANCEL") forState:UIControlStateNormal];
    cancelBtn.didClikcButtonAction = ^void(id sender) {
        [PopupViewHelper dissmissCurrentPopView];
        if (cancelAction) cancelAction(sender);
    };
    

    // send button
    JRButton* sendBtn = searchTableView.rightButton;
    [sendBtn setTitle:LOCALIZE_KEY(@"SEND") forState:UIControlStateNormal];
    sendBtn.didClikcButtonAction = ^void(id sender) {
        // alert ....
        if (OBJECT_EMPYT(selectNumber)) {
            [ACTION alertWarning: LOCALIZE_MESSAGE(MESSAGE_SelectNextLevelApp)];
            return ;
        }
        if (sendAction) sendAction(sender, selectNumber);
    };
    
    // title label
    searchTableView.titleLabel.text = LOCALIZE_MESSAGE(MESSAGE_SelectNextLevelApp);

    [PopupViewHelper popView: superView willDissmiss:nil];
}

+(NSMutableArray*) getApprovalsUsers: (NSString*)app department:(NSString*)department order:(NSString*)order
{
    // assemble approvals users list
    NSDictionary* approvalsettings = [[[DATA.approvalSettings objectForKey: department] objectForKey: order] objectForKey:app ];
    NSArray* approvalUsers = [approvalsettings objectForKey: APPSettings_APPROVALS_USERS];
    
    // FOR TEST
    if (! approvalUsers) {
        if ([VIEW isTestDevice]) approvalUsers = [DATA.usersNONames allKeys];
    }
    NSMutableArray* users = [ArrayHelper deepCopy: approvalUsers];
    NSUInteger level = [[[approvalsettings objectForKey: APPSettings_APPROVALS_PRAMAS] objectForKey:APPSettings_APPROVALS_PRAMAS_LEVEL] integerValue];
    if (level != 0) {
        for (NSString* username in DATA.usersNOLevels) {
            NSNumber* userLevel = DATA.usersNOLevels[username];
            if ([userLevel integerValue] <= level) {
                if (! [users containsObject: username]) {
                    [users addObject: username];
                }
            }
        }
    }
    for (int i = 0; i < users.count; i++) {
        NSString* username = [users objectAtIndex: i];
        BOOL isHaveReadPermission = [PermissionChecker check: username department:department order:order permission:PERMISSION_READ];
        if (! DATA.usersNONames[username] || ! [DATA.usersNOApproval[username] boolValue] || [DATA.usersNOResign[username] boolValue] || ! isHaveReadPermission ) {
            [users removeObject: username];
            i--;
        }
    }
    return [ArrayHelper eliminateDuplicates: users];
}




#pragma mark -
+(NSString*) getUserName: (NSString*)number
{
    NSString* userName = [DATA.usersNONames objectForKey:number];
    if (!userName && IS_SUPERUSER(DATA.signedUserId)) {
        userName = LOCALIZE_KEY(@"ADMINISTRATOR");
    }
    return userName;
}

// ["1","2"] -> [["1", "1Name"], ["2", "2Name"]]
+(NSMutableArray*) getUserNumbersNames: (NSArray*)numbers
{
    NSMutableArray* contents = [NSMutableArray array];
    
    for (int i = 0; i < numbers.count; i++) {
        NSMutableArray* cellValues = [NSMutableArray array];
        NSString* employeeNO = [numbers objectAtIndex:i];
        
        NSString* employeeName = DATA.usersNONames[employeeNO];
        
        [cellValues addObject: employeeNO];
        if (employeeName) {
            [cellValues addObject: employeeName];
        }
        
        [contents addObject:cellValues];
    }
    
    return contents;
}


@end
