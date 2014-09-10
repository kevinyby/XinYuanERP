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
    return [OrderListControllerHelper getModelsListSpecification: department order:order][@"__Delete_Images_Folder"];
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






#pragma mark - Header Sorts

+(void) iterateHeaderJRLabel: (BaseOrderListController*)listController handler:(BOOL(^)(JRLocalizeLabel* label, int index, NSString* attribute))handler
{
    NSArray* headers = listController.headers;
    UIView* headerView = listController.headerTableView.headerView;
    for (int i = 0; i < headers.count; i++) {
        NSString* attribute = headers[i];
        JRLocalizeLabel* jrLabel = (JRLocalizeLabel*)[headerView viewWithTag:ALIGNTABLE_HEADER_LABEL_TAG(i)];
        if (handler) {
            if (handler(jrLabel, i, attribute)) {
                return;
            }
        }
    }
}

+(JRLocalizeLabel*) getHeaderJRLabelByAttribute: (BaseOrderListController*)listController attribute:(NSString*)attribute
{
    NSArray* headers = listController.headers;
    UIView* headerView = listController.headerTableView.headerView;
    for (int i = 0; i < headers.count; i++) {
        JRLocalizeLabel* jrLabel = (JRLocalizeLabel*)[headerView viewWithTag:ALIGNTABLE_HEADER_LABEL_TAG(i)];
        if ([jrLabel.attribute isEqualToString: attribute]) {
            return jrLabel;
        }
    }
    return nil;
}



+(void) clickHeaderLabelSortRequestAction: (JRLocalizeLabel*)label listController:(BaseOrderListController*)listController
{
    RequestJsonModel* requestModel = listController.requestModel;
    
    [[requestModel.limits firstObject] replaceObjectAtIndex: 0 withObject: @(0)];
    
    NSString* attribute = label.attribute;
    
    // just first objects default
    NSString* sortString = [[requestModel.sorts firstObject] firstObject];
    NSString* newSortString = sortString;
    if ([sortString rangeOfString: attribute].location == NSNotFound) {
        
        // if is create Date
        if ([sortString rangeOfString: PROPERTY_IDENTIFIER].location != NSNotFound && [attribute isEqualToString: PROPERTY_CREATEDATE]) {
            newSortString = [sortString stringByReplacingOccurrencesOfString: PROPERTY_IDENTIFIER withString:PROPERTY_CREATEDATE];
        } else {
            newSortString = [attribute stringByAppendingFormat:@".%@", SORT_ASC];
        }
        
    }
    
    // revert
    newSortString = [self reverseSortString: newSortString];
    [[requestModel.sorts firstObject] replaceObjectAtIndex: 0 withObject: newSortString];
    [listController requestForDataFromServer];
}

+(NSString*) reverseSortString: (NSString*)sortString
{
    NSString* newSortString = sortString;
    if ([sortString rangeOfString:SORT_ASC].location != NSNotFound) {
        newSortString = [sortString stringByReplacingOccurrencesOfString: SORT_ASC withString:SORT_DESC];
    } else if([sortString rangeOfString:SORT_DESC].location != NSNotFound) {
        newSortString = [sortString stringByReplacingOccurrencesOfString: SORT_DESC withString:SORT_ASC];
    }
    return newSortString;
}










+(void) navigateToOrderController: (NSString*)department order:(NSString*)order identifier:(id)identifier
{
    JsonController* jsonController = [OrderListControllerHelper getNewJsonControllerInstance: department order:order];
    jsonController.controlMode = JsonControllerModeRead;
    jsonController.identification = identifier;
    
    [VIEW.navigator pushViewController: jsonController animated:YES];
}







#pragma mark - Navigation

+(JsonController*) getNewJsonControllerInstance:(NSString*)department order:(NSString*)order
{
    // controller
    NSString* controllerCalzzstring = [NSString stringWithFormat: @"%@%@", order, @"Controller"];
    Class controllerCalzz = NSClassFromString(controllerCalzzstring);
    if (controllerCalzz == Nil) controllerCalzz = [JsonController class];
    JsonController* jsonController = [[controllerCalzz alloc] init];
    jsonController.order = order;
    jsonController.department = department;
    jsonController.controlMode = JsonControllerModeNull;
    return jsonController;
}


+(NSDictionary*) getModelsListSpecification: (NSString*)department
{
    NSString* departmentListFileName = [department stringByAppendingString: @"List.json"];
    NSDictionary* result = [JsonFileManager getJsonFromFile: departmentListFileName];
    return result;
}

+(NSDictionary*) getModelsListSpecification: (NSString*)department order:(NSString*)order
{
    NSDictionary* result = [self getModelsListSpecification: department];
    if (order) {
        result = result[order];
    }
    return result;
}





#pragma mark - Search Item

+(void) sortSearchProperties: (NSMutableArray*)searchProperties propertiesMap:(NSDictionary*)propertiesMap orderType:(NSString*)orderType
{
    NSMutableArray* results = [NSMutableArray array];
    
    NSMutableArray* dateArray = [NSMutableArray array];
    NSMutableArray* levelArray = [NSMutableArray array];
    NSMutableArray* lengthArray = [NSMutableArray array];
    NSMutableArray* booleanArray = [NSMutableArray array];
    for (NSString* property in searchProperties) {
        
        NSArray* levelApps = @[levelApp1, levelApp2, levelApp3, levelApp4, PROPERTY_CREATEUSER];
        if ([levelApps containsObject: property]) {
            
            [levelArray addObject: property];
            
        } else {
            
            BOOL isBooleanValue = [propertiesMap[property] isEqualToString:@"boolean"];
            if (isBooleanValue) {
                
                [booleanArray addObject: property];
                
            } else {
                
                BOOL isDate = [propertiesMap[property] isEqualToString:@"Date"];
                if (isDate) {
                    
                    [dateArray addObject: property];
                    
                } else {
                    
                    [lengthArray addObject: property];
                    
                }
                
            }
        }
        
    }
    
    dateArray = [ArrayHelper reRangeContents:dateArray frontContents:@[PROPERTY_CREATEDATE]];
    
    [lengthArray sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [@([APPLOCALIZES(orderType, obj1) length]) compare: @([APPLOCALIZES(orderType, obj2) length])];
    }];
    [booleanArray sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [@([APPLOCALIZES(orderType, obj1) length]) compare: @([APPLOCALIZES(orderType, obj2) length])];
    }];
    
    [levelArray removeObject: PROPERTY_CREATEUSER];
    [levelArray sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 compare: obj2];
    }];
    [levelArray insertObject: PROPERTY_CREATEUSER atIndex:0];
    
    
    [results addObjectsFromArray: dateArray];
    [results addObjectsFromArray: lengthArray];
    [results addObjectsFromArray: levelArray];
    [results addObjectsFromArray: booleanArray];
    
    [searchProperties setArray: results];
}




@end
