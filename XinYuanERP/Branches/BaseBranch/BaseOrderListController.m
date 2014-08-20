#import "BaseOrderListController.h"
#import "AppInterface.h"

@implementation BaseOrderListController

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
    UIButton* qrCodeScanButton = [[UIButton alloc] initWithImage:qrCodeScanImage focusImage:qrCodeHightImage target:self action:@selector(scanQRCode:)];
    CGRect rect = CGRectMake(10, 5, qrCodeScanImage.size.width+10, qrCodeScanImage.size.height+10);
    [qrCodeScanButton setFrame:rect];
    UIBarButtonItem* qrCodeButtonItem = [[UIBarButtonItem alloc] initWithCustomView: qrCodeScanButton];
    
    // Add button item
    UIBarButtonItem* addButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(createNewOrder:)];
    
    
    // Search button item
    UIBarButtonItem* searchButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(searchOrder:)];
    
    
    // Space button item
    UIBarButtonItem* spaceButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    spaceButtonItem.width = [FrameTranslater convertCanvasWidth: 50];
    
    
    //
    NSArray* items = nil;
    if ([self.order isEqualToString:MODEL_WHInventory]||[self.order isEqualToString:MODEL_EMPLOYEE]) {
       items = @[addButtonItem, spaceButtonItem, searchButtonItem, spaceButtonItem, qrCodeButtonItem];
    } else {
        items = @[addButtonItem, spaceButtonItem, searchButtonItem];
    }
    
    self.navigationItem.rightBarButtonItems = items;
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
    __weak BaseOrderListController* weakInstance = self;
    NSString* orderType = self.order;
    NSString* department = self.department;
    NSIndexPath* realIndexPath = [((FilterTableView*)tableViewObj) getRealIndexPathInFilterMode: indexPath];
    id identification = [[tableViewObj realContentForIndexPath:realIndexPath] firstObject];
    NSString* tips = [[tableViewObj realContentForIndexPath:realIndexPath] safeObjectAtIndex: 1];
    
    [OrderListControllerHelper deleteWithCheckPermission: orderType deparment:department identification:identification tips:tips handler:^(bool isSuccess) {
        if (isSuccess) {
    
            // delete the images
            NSString* imagesFolderName = [OrderListControllerHelper getImageFolderName: weakInstance indexPath:realIndexPath];
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
// delete -------------------





#pragma mark - Action

-(void)createNewOrder:(id)sender
{
    if(! [PermissionChecker checkSignedUserWithAlert: self.department order:self.order permission:PERMISSION_CREATE]) return;
    self.isPopNeedRefreshRequest = YES;
    if (self.didTapAddNewOrderBlock) self.didTapAddNewOrderBlock(self,sender);
}



-(void) searchOrder: (id)sender
{
    // popu the view
    UIView* superView = [PopupTableHelper getCommonPopupTableView];
    JRButtonsHeaderTableView* searchTableView = (JRButtonsHeaderTableView*)[superView viewWithTag: POPUP_TABLEVIEW_TAG];
    [searchTableView.tableView setHideSearchBar: YES];
    [PopupViewHelper popView:superView willDissmiss:nil];
    
    // change the button title
    JRButton* rightButton = searchTableView.rightButton;
    [rightButton setTitle:LOCALIZE_KEY(@"SEARCH") forState:UIControlStateNormal];
    
    JRButton* leftButton = searchTableView.leftButton;
    [leftButton setTitle:LOCALIZE_KEY(@"clear") forState:UIControlStateNormal];
    
    // set the table contents
    
}



-(void)scanQRCode:(id)sender
{
    QRCodeReaderViewController* QRReadVC = [[QRCodeReaderViewController alloc]init];
    QRReadVC.resultBlock = ^void(NSString* result){
        self.headerTableView.searchBar.textField.text = result;
        self.headerTableView.tableView.filterText = result;
    };

    [self.navigationController presentViewController: QRReadVC animated:YES completion:nil];
}


@end
