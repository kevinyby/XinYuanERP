#import "OrderListControllerHelper.h"
#import "AppInterface.h"

@implementation OrderListControllerHelper



#pragma mark - View Did Load

+ (void)setRightBarButtonItems: (BaseOrderListController*)listController
{
    // QRCode button item
    UIImage* qrCodeScanImage = IMAGEINIT(@"public_QRCodeScan.png");
    UIImage* qrCodeHightImage =  [ImageHelper applyingAlphaToImage: qrCodeScanImage alpha:0.5];
    UIButton* qrCodeScanButton = [[UIButton alloc] initWithImage:qrCodeScanImage focusImage:qrCodeHightImage target:listController action:@selector(scanQRCodeAction:)];
    CGRect rect = CGRectMake(10, 5, qrCodeScanImage.size.width+10, qrCodeScanImage.size.height+10);
    [qrCodeScanButton setFrame:rect];
    UIBarButtonItem* qrCodeButtonItem = [[UIBarButtonItem alloc] initWithCustomView: qrCodeScanButton];
    
    // Add button item
    UIBarButtonItem* addButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:listController action:@selector(createNewOrderAction:)];
    
    
    // Search button item
    UIBarButtonItem* searchButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:listController action:@selector(searchOrderAction:)];
    
    
    // Space button item
    UIBarButtonItem* spaceButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    spaceButtonItem.width = [FrameTranslater convertCanvasWidth: 50];
    
    
    //
    NSArray* items = nil;
    if ([listController.order isEqualToString:MODEL_WHInventory]||[listController.order isEqualToString:MODEL_EMPLOYEE]) {
        items = @[addButtonItem, spaceButtonItem, searchButtonItem, spaceButtonItem, qrCodeButtonItem];
    } else {
        items = @[addButtonItem, spaceButtonItem, searchButtonItem];
    }
    
    listController.navigationItem.rightBarButtonItems = items;
}



#pragma mark - Delete Order

+(NSString*) getImageFolderName:(BaseOrderListController*)listController indexPath:(NSIndexPath*)realIndexPath
{
    NSString* order = listController.order;
    NSString* department = listController.department;
    NSArray* fields = listController.requestModel.fields;
    FilterTableView* tableViewObj = (FilterTableView*)listController.headerTableView.tableView;
    NSString* deleteImagesFolderProperty = [OrderListControllerHelper getDeleteImageFolderProperty: department order:order];
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
    return [JsonBranchHelper getModelsListSpecification: department order:order][@"__Delete_Images_Folder"];
}


+(void) deleteWithCheckPermission:(NSString*)orderType deparment:(NSString*)department identification:(id)identification tips:(NSString*)tips handler:(void(^)(bool isSuccess))handler
{
    if([PermissionChecker checkSignedUserWithAlert: department order:orderType permission:PERMISSION_DELETE]) {
        [OrderListControllerHelper delete: orderType deparment:department identification:identification tips:tips handler:handler];
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
