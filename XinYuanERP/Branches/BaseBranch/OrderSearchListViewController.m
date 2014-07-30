#import "OrderSearchListViewController.h"
#import "AppInterface.h"

@implementation OrderSearchListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self setRightBarButtonItems];
}

- (void)setRightBarButtonItems
{
    // QRCode button item
    UIImage* qrCodeScanImage = IMAGEINIT(@"public_QRCodeScan.png");
    UIImage* qrCodeHightImage =  [ImageHelper applyingAlphaToImage: qrCodeScanImage alpha:0.5];
    UIButton* qrCodeScanButton = [[UIButton alloc]initWithImage:qrCodeScanImage focusImage:qrCodeHightImage target:self action:@selector(scanQRCode:)];
    CGRect rect = CGRectMake(10, 5, qrCodeScanImage.size.width+10, qrCodeScanImage.size.height+10);
    [qrCodeScanButton setFrame:rect];
    
    // new version
    UIBarButtonItem* addButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(createNewOrder:)];
    UIBarButtonItem* qrCodeButtonItem = [[UIBarButtonItem alloc] initWithCustomView: qrCodeScanButton];
    if ([self.order isEqualToString:MODEL_WHInventory]||[self.order isEqualToString:MODEL_EMPLOYEE]) {
        UIBarButtonItem* spaceButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        spaceButtonItem.width = [FrameTranslater convertCanvasWidth: 50];
        self.navigationItem.rightBarButtonItems = @[addButtonItem, spaceButtonItem, qrCodeButtonItem];
    } else {
        self.navigationItem.rightBarButtonItems = @[addButtonItem];
    }

}


#pragma mark - Override Super Class Methods
-(void) appSearchTableViewController: (AppSearchTableViewController*)controller didSelectIndexPath:(NSIndexPath*)indexPath
{
    if([PermissionChecker checkSignedUserWithAlert:self.department order:self.order permission:PERMISSION_READ]) {
        [super appSearchTableViewController: controller didSelectIndexPath:indexPath];
    }
}

// delete -------------------
- (BOOL)tableViewBase:(TableViewBase *)tableViewObj canEditIndexPath:(NSIndexPath*)indexPath
{
    return [PermissionChecker checkSignedUser: self.department order:self.order permission:PERMISSION_DELETE];
}

- (BOOL)tableViewBase:(TableViewBase *)tableViewObj shouldDeleteContentsAtIndexPath:(NSIndexPath*)indexPath
{
    __weak OrderSearchListViewController* weakInstance = self;
    NSString* orderType = self.order;
    NSString* department = self.department;
    NSIndexPath* realIndexPath = [((FilterTableView*)tableViewObj) getRealIndexPathInFilterMode: indexPath];
    id identification = [[tableViewObj realContentForIndexPath:realIndexPath] firstObject];
    NSString* tips = [[tableViewObj realContentForIndexPath:realIndexPath] safeObjectAtIndex: 1];
    
    
    [OrderSearchListViewController deleteWithCheckPermission: orderType deparment:department identification:identification tips:tips handler:^(bool isSuccess) {
        if (isSuccess) {
    
            // delete the images
            NSString* imagesFolderName = [OrderSearchListViewController getImageFolderName: weakInstance indexPath:realIndexPath];
            if (! OBJECT_EMPYT(imagesFolderName)) {
                NSString* fullFolderName = [[JsonControllerHelper getImagesHomeFolder: orderType department:department] stringByAppendingPathComponent: imagesFolderName];
                [VIEW.progress show];
                VIEW.progress.detailsLabelText = APPLOCALIZE_KEYS(@"In_Process", @"delete", @"images");
                [AppServerRequester deleteImagesFolder: fullFolderName completeHandler:^(HTTPRequester *requester, ResponseJsonModel *model, NSHTTPURLResponse *httpURLReqponse, NSError *error) {
                    [VIEW.progress hide];
                }];
            }
            
            // Important!!!! put it behide !!! it will affect get image name ....
            [tableViewObj deleteIndexPathWithAnimation: indexPath];
        }
    }];
    
    return NO;  // let the call back delete visual content
}



#pragma mark - Util

+(NSString*) getImageFolderName:(OrderSearchListViewController*)listController indexPath:(NSIndexPath*)realIndexPath
{
    NSString* order = listController.order;
    NSString* department = listController.department;
    NSArray* fields = listController.requestModel.fields;
    FilterTableView* tableViewObj = (FilterTableView*)listController.headerTableView.tableView;
    NSString* imagesFolderProperty = [JsonBranchFactory getModelsListSpecification: department order:order][@"__Delete_Images_Folder"];
    if (! imagesFolderProperty) return nil;
    
    int imagesFolderValueIndex = -1;     // the id is 0 , the 1 is ... (maybe orderNO)
    for (int i = 0; i < fields.count; i++) {
        NSArray* innerFields = fields[i];
        if ([innerFields containsObject: imagesFolderProperty]) {
            imagesFolderValueIndex = [innerFields indexOfObject: imagesFolderProperty];
            DLOG(@"Get Image Folder Index: %d", imagesFolderValueIndex);
            break;
        }
    }
    if (imagesFolderValueIndex == -1) return nil;
    
    NSArray* realRowContents = [tableViewObj realContentForIndexPath: realIndexPath];
    NSString* imagesFolderName = [realRowContents objectAtIndex: imagesFolderValueIndex];
    
    return imagesFolderName;
}



+(void) deleteWithCheckPermission:(NSString*)orderType deparment:(NSString*)department identification:(id)identification tips:(NSString*)tips handler:(void(^)(bool isSuccess))handler
{
    if([PermissionChecker checkSignedUserWithAlert: department order:orderType permission:PERMISSION_DELETE]) {
        [OrderSearchListViewController delete: orderType deparment:department identification:identification tips:tips handler:handler];
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
// delete -------------------


#pragma mark - Action

-(void)createNewOrder:(id)sender
{
    if(! [PermissionChecker checkSignedUserWithAlert: self.department order:self.order permission:PERMISSION_CREATE]) return;
    self.isPopNeedRefreshRequest = YES;
    if (self.didTapAddNewOrderBlock) self.didTapAddNewOrderBlock(self,sender);
}

-(void)scanQRCode:(id)sender
{
    QRCodeReaderViewController* QRReadVC = [[QRCodeReaderViewController alloc]init];
    QRReadVC.resultBlock = ^void(NSString* result){
        self.headerTableView.searchBar.textField.text = result;
        self.headerTableView.tableView.filterText = result;
    };
    [self.navigationController presentModalViewController:QRReadVC animated:YES];
}


@end
