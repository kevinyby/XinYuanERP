#import "OrderSearchListViewHelper.h"
#import "AppInterface.h"

@implementation OrderSearchListViewHelper


#pragma mark - Util

+(NSString*) getImageFolderName:(OrderSearchListViewController*)listController indexPath:(NSIndexPath*)realIndexPath
{
    NSString* order = listController.order;
    NSString* department = listController.department;
    NSArray* fields = listController.requestModel.fields;
    FilterTableView* tableViewObj = (FilterTableView*)listController.headerTableView.tableView;
    NSString* deleteImagesFolderProperty = [OrderSearchListViewHelper getDeleteImageFolderProperty: department order:order];
    if (! deleteImagesFolderProperty) return nil;
    
    int imagesFolderValueIndex = -1;     // the id is 0 , the 1 is ... (maybe orderNO)
    for (int i = 0; i < fields.count; i++) {
        NSArray* innerFields = fields[i];
        if ([innerFields containsObject: deleteImagesFolderProperty]) {
            imagesFolderValueIndex = [innerFields indexOfObject: deleteImagesFolderProperty];
            DLOG(@"Get Image Folder Index: %d", imagesFolderValueIndex);
            break;
        }
    }
    if (imagesFolderValueIndex == -1) return nil;
    
    NSArray* realRowContents = [tableViewObj realContentForIndexPath: realIndexPath];
    NSString* imagesFolderName = [realRowContents objectAtIndex: imagesFolderValueIndex];
    
    return imagesFolderName;
}

+(NSString*) getDeleteImageFolderProperty: (NSString*)department order:(NSString*)order
{
    return [JsonBranchFactory getModelsListSpecification: department order:order][@"__Delete_Images_Folder"];
}


+(void) deleteWithCheckPermission:(NSString*)orderType deparment:(NSString*)department identification:(id)identification tips:(NSString*)tips handler:(void(^)(bool isSuccess))handler
{
    if([PermissionChecker checkSignedUserWithAlert: department order:orderType permission:PERMISSION_DELETE]) {
        [OrderSearchListViewHelper delete: orderType deparment:department identification:identification tips:tips handler:handler];
    }
}

+(void) delete:(NSString*)orderType deparment:(NSString*)department identification:(id)identification tips:(NSString*)tips handler:(void(^)(bool isSuccess))handler
{
    [PopupViewHelper popAlert:LOCALIZE_KEY(KEY_WARNING) message:LOCALIZE_MESSAGE_FORMAT(MESSAGE_SureToDelete, tips) style:0 actionBlock: ^(UIView *view, NSInteger index) {
        UIAlertView* alertView = (UIAlertView*)view;
        NSString* buttonTitle = [alertView buttonTitleAtIndex: index];
        if ([buttonTitle isEqualToString: LOCALIZE_KEY(@"OK")]) {
            
            [VIEW.progress show];
            VIEW.progress.detailsLabelText = LOCALIZE_MESSAGE_FORMAT(@"DeletingStuffAndWait", tips);
            [AppServerRequester deleteModel: orderType department:department identities:@{PROPERTY_IDENTIFIER: identification} completeHandler:^(bool isSuccessfully) {
                [VIEW.progress hide];
                if (handler) {
                    handler(isSuccessfully);
                }
            }];
            
        }
    } dismissBlock:nil buttons:LOCALIZE_KEY(@"OK"), LOCALIZE_KEY(@"CANCEL"), nil];
}


@end
