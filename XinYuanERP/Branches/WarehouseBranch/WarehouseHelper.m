//
//  WarehouseHelper.m
//  XinYuanERP
//
//  Created by Xinyuan4 on 14-6-18.
//  Copyright (c) 2014年 Xinyuan4. All rights reserved.
//

#import "WarehouseHelper.h"
#import "AppInterface.h"

@implementation WarehouseHelper

+(void)popTableView:(JRTextField*)jrTextField settingModel:(NSString*)model
{
    NSString* contentKey = model;
    __block BOOL isNeedToSaveToServer = NO;
    
    UIView* superView = [PopupTableHelper getCommonPopupTableView];
    JRButtonsHeaderTableView* modelTableView = (JRButtonsHeaderTableView*)[superView viewWithTag: POPUP_TABLEVIEW_TAG];
    // title label
    modelTableView.titleLabel.text = LOCALIZE_KEY(model);
    // cancel button
    JRButton* cancelBtn = modelTableView.leftButton ;
    cancelBtn.didClikcButtonAction = ^void(id sender) {
        [PopupViewHelper dissmissCurrentPopView];
    };
    JRButton* addBtn = modelTableView.rightButton;
    [addBtn setTitle:LOCALIZE_KEY(KEY_ADD) forState:UIControlStateNormal];
    
    // add button
    addBtn.didClikcButtonAction = ^void(NormalButton* button) {
        NSString* addNewmessage = LOCALIZE_MESSAGE_FORMAT(@"AddNew", LOCALIZE_KEY(model));
        [PopupViewHelper popAlert: addNewmessage message:nil style:UIAlertViewStylePlainTextInput actionBlock:^(UIView *popView, NSInteger index) {
            UIAlertView* alertView = (UIAlertView*)popView;
            NSString* newObject = [alertView textFieldAtIndex: 0].text;
            if (OBJECT_EMPYT(newObject)) return ;
            
            NSMutableArray* sectionsContents = [modelTableView.tableView.tableView.contentsDictionary objectForKey: contentKey];
            // if have this department , then
            if ([sectionsContents containsObject: newObject]) {
                int row = [sectionsContents indexOfObject: newObject];
                NSIndexPath* containsIndexPath = [NSIndexPath indexPathForRow: row inSection: 0];
                [modelTableView.tableView.tableView selectRowAtIndexPath:containsIndexPath animated:YES scrollPosition:UITableViewScrollPositionMiddle];
            } else {
                isNeedToSaveToServer = YES;
                [sectionsContents insertObject:newObject atIndex:0];
                [modelTableView.tableView.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow: 0 inSection:0]] withRowAnimation: UITableViewRowAnimationBottom];
            }
        } dismissBlock:nil buttons:LOCALIZE_KEY(@"CANCEL"), LOCALIZE_KEY(@"OK"), nil];
    };
    
    // search table view
    modelTableView.tableView.tableView.tableViewBaseDidDeleteContentsAction = ^void(TableViewBase* tableViewObj, NSIndexPath* indexPath) {
        isNeedToSaveToServer = YES;
    };
    modelTableView.tableView.tableView.tableViewBaseCanEditIndexPathAction = ^BOOL(TableViewBase* tableViewObj, NSIndexPath* indexPath){
        return YES;
    };
    modelTableView.tableView.tableView.tableViewBaseHeightForIndexPathAction = ^CGFloat(TableViewBase* tableViewObj, NSIndexPath* indexPath) {
        return [FrameTranslater convertCanvasHeight: UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? 100 : 50];
    };
    modelTableView.tableView.tableView.tableViewBaseDidSelectAction = ^(TableViewBase* tableViewObj, NSIndexPath* indexPath){
        // set the new product to text field
        id value = [tableViewObj contentForIndexPath: indexPath];
        [jrTextField setValue: value];
        [PopupViewHelper dissmissCurrentPopView];
    };
    // pop table
    [PopupViewHelper popView:superView inView:[ViewHelper getTopView] tapOverlayAction:^void(UIControl* control){} willDissmiss:^(UIView *view) {
        // will dimiss , then save the product
        if (! isNeedToSaveToServer) return ;
        NSArray* sectionsContents = [modelTableView.tableView.tableView.contentsDictionary objectForKey: contentKey];
        NSString* jobPositionsString = [CollectionHelper convertJSONObjectToJSONString: sectionsContents];
        [VIEW.progress show];
        [AppServerRequester modifySetting:model json:jobPositionsString completeHandler:^(ResponseJsonModel *data, NSError *error) {
            [VIEW.progress hide];
        }];
    }];
    // load the data in the table and show all products
    [AppViewHelper showIndicatorInView: modelTableView];
    [AppServerRequester readSetting: model completeHandler:^(ResponseJsonModel *data, NSError *error) {
        NSArray* array = [NSArray array];
        NSString* settingModelString = data.results[@"settings"];
        if (settingModelString) {
            array = [CollectionHelper convertJSONStringToJSONObject:settingModelString];
        }
        modelTableView.tableView.tableView.contentsDictionary = [DictionaryHelper deepCopy: @{contentKey: array}];
        [modelTableView.tableView reloadTableData];
        [AppViewHelper stopIndicatorInView: modelTableView];
    }];
    
}

+(void)constraint:(JRButtonTextFieldView*)constraintView condition:(JRButtonTextFieldView*)conditionView
{
    JRTextField* conditionTxtField = conditionView.textField;
    JRButton* constraintButton = constraintView.button;
    constraintButton.userInteractionEnabled = !isEmptyString(conditionTxtField.text);
}



@end
