//
//  ContractController.m
//  XinYuanERP
//
//  Created by Xinyuan4 on 14-6-19.
//  Copyright (c) 2014年 Xinyuan4. All rights reserved.
//

#import "ContractController.h"
#import "AppInterface.h"

#import "ContractPayCell.h"

#import "UIViewController+CWPopup.h"
#import "PopPDFViewController.h"
#import "PopBubbleView.h"

@interface ContractController ()<UITextFieldDelegate>
{
    JRRefreshTableView* _contractPayTableView;
    NSMutableArray* _contractPayContents;
    
    JRTextField* _shouldReceiveTxtField;
    JRTextField* _unReceiveTxtField;
    
    NSMutableArray* _selectedPDFArray;
    
    JRTextField* _totalAmountTxtField;
    JRTextField* _contractNOTxtField;

}

@end

@implementation ContractController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
         _selectedPDFArray = [NSMutableArray array];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    
    JRTextField* numberTxtField = ((JRLabelTextFieldView*)[self.jsonView getView:@"clientNumber"]).textField;
    JRTextField* nameTxtField = ((JRLabelTextFieldView*)[self.jsonView getView:@"clientName"]).textField;
    numberTxtField.textFieldDidClickAction = ^void(JRTextField* jrTextField){
        NSArray* needFields = @[@"number",@"name"];
        PickerModelTableView* pickView = [PickerModelTableView popupWithRequestModel:MODEL_CLIENT fields:needFields willDimissBlock:nil];
        pickView.tableView.headersXcoordinates = @[@(20), @(200)];
        pickView.titleHeaderViewDidSelectAction = ^void(JRTitleHeaderTableView* headerTableView, NSIndexPath* indexPath){
            
            FilterTableView* filterTableView = (FilterTableView*)headerTableView.tableView.tableView;
            NSIndexPath* realIndexPath = [filterTableView getRealIndexPathInFilterMode: indexPath];
            
            NSArray* array = [filterTableView contentForIndexPath: indexPath];
            jrTextField.text = [array objectAtIndex:0];
            nameTxtField.text = [array objectAtIndex:1];

            [PickerModelTableView dismiss];
        };
    };
   
    
    __weak ContractController* weakSelf = self;
    __block ContractController* blockSelf = self;
    
    
    _contractPayContents = [[NSMutableArray alloc] init];
    _contractPayTableView = (JRRefreshTableView*)[self.jsonView getView:@"NESTED_TOP_RIGHT_TableOne"];
    _contractPayTableView.tableView.tableViewBaseNumberOfSectionsAction = ^NSInteger(TableViewBase* tableViewObje){
        return 1;
    };
    _contractPayTableView.tableView.tableViewBaseNumberOfRowsInSectionAction = ^NSInteger(TableViewBase* tableViewObj, NSInteger section) {
        return blockSelf->_contractPayContents.count;
    };
    _contractPayTableView.tableView.tableViewBaseCellForIndexPathAction = ^UITableViewCell*(TableViewBase* tableViewObj, NSIndexPath* indexPath, UITableViewCell* oldCell) {
        static NSString *CellIdentifier = @"Cell";
        ContractPayCell* cell = [tableViewObj dequeueReusableCellWithIdentifier:CellIdentifier];
//        ContractPayCell* cell = (ContractPayCell*)[tableViewObj cellForRowAtIndexPath:indexPath];
        if (cell == nil) {
            cell = [[ContractPayCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            [cell setTextFieldDelegate:weakSelf];
        }
        [cell setDatas: [blockSelf->_contractPayContents safeObjectAtIndex: indexPath.row]];
        [weakSelf refreshTotal];
        return cell;
    };
    


    
    JRTextField* productDescTxtField = (JRTextField*)[self.jsonView getView:@"attachFile"];
    JRButton* attachFileButton = (JRButton*)[self.jsonView getView:@"BTN_AttachFile"];
    attachFileButton.didClikcButtonAction = ^void(JRButton* jrButton){
        
        PopPDFViewController* popView = [[PopPDFViewController alloc] init];
        popView.title = LOCALIZE_KEY(LOCALIZE_CONNECT_KEYS(@"Contract",@"attachFile"));
        popView.pathArray = @[@{@"PATH":CONTRACTPDF_PREFIXPATH}];
        popView.selectedMarks = _selectedPDFArray;
        popView.selectBlock = ^(NSMutableArray* selectArray){
            _selectedPDFArray = selectArray;
            productDescTxtField.text = [_selectedPDFArray componentsJoinedByString:KEY_COMMA];
            [self dismissPopupViewControllerAnimated:YES completion:^{}];
        };
        [self presentPopupViewController:popView animated:YES completion:nil];
    };
    
    productDescTxtField.textFieldDidClickAction = ^void(JRTextField* jrTextField){
        if (isEmptyString(jrTextField.text)) return;
        [PopBubbleView popTableBubbleView:jrTextField title:LOCALIZE_KEY(LOCALIZE_CONNECT_KEYS(@"Contract",@"attachFile"))
                               dataSource:_selectedPDFArray selectedBlock:^(NSInteger selectedIndex, NSString *selectedValue) {
            WebViewController* web = [[WebViewController alloc]initWithUrlString:CONTRACTPDF_PATH(selectedValue)];
            [self presentModalViewController:web animated:YES];
            
        }];
    };
    
    //select salesMan
    JRTextField* salesManTxtField = ((JRLabelTextFieldView*)[self.jsonView getView:@"salesMan"]).textField;
    salesManTxtField.textFieldDidClickAction = ^void(JRTextField* jrTextField){
        PickerModelTableView* pickView = [PickerModelTableView popupWithModel:MODEL_EMPLOYEE willDimissBlock:nil];
        pickView.titleHeaderViewDidSelectAction = ^void(JRTitleHeaderTableView* headerTableView, NSIndexPath* indexPath){
            FilterTableView* filterTableView = (FilterTableView*)headerTableView.tableView.tableView;
            NSIndexPath* realIndexPath = [filterTableView getRealIndexPathInFilterMode: indexPath];
            
            jrTextField.text = [DATA.usersNONames objectForKey:[filterTableView realContentForIndexPath: realIndexPath]];
            [PickerModelTableView dismiss];
        };
    };
    
    
    self.didShowTabView = ^void(int index, JsonDivView* tabView) {
        if (weakSelf.controlMode == JsonControllerModeCreate) return;
        
        JRButton* button = [weakSelf.tabsButtonsView.subviews objectAtIndex: index];
        NSString* buttonKey = button.attribute;
        
        NSString* orderNO = [(((id<JRComponentProtocal>)[weakSelf.jsonView getView:@"orderNO"])) getValue];
        
        if ([buttonKey isEqualToString:@"TAB_Cost"]) {
            
            JRRefreshTableView*  refreshTableView = (JRRefreshTableView*)[weakSelf.jsonView getView:@"NESTED_Cost.Cost_TABLE"];
            NSDictionary* objects = @{@"application": orderNO};
            
            [AppViewHelper showIndicatorInView:  refreshTableView];
            [AppServerRequester readModel: ORDER_WHPickingOrder department:DEPARTMENT_WAREHOUSE objects: objects fields:@[PROPERTY_ORDERNO,@"totalPrice"] completeHandler:^(ResponseJsonModel *data, NSError *error) {
                [AppViewHelper stopIndicatorInView:  refreshTableView];
                
                NSArray* array = [data.results lastObject];
                NSMutableDictionary* keysMap = [NSMutableDictionary dictionary];
                [keysMap setObject:ORDER_WHPickingOrder forKey:LOCALIZE_KEY(ORDER_WHPickingOrder)];
                NSMutableDictionary* contentDic = [NSMutableDictionary dictionaryWithObject:array forKey:LOCALIZE_KEY(ORDER_WHPickingOrder)];
                refreshTableView.tableView.contentsDictionary = contentDic;
                refreshTableView.tableView.keysMap = keysMap;
                [refreshTableView reloadTableData];
                
                refreshTableView.tableView.tableViewBaseDidSelectAction = ^void(TableViewBase* tableViewObj, NSIndexPath* indexPath) {
                    // get the department and orderType
                    NSString* order = [[tableViewObj keysMap] objectForKey:[[tableViewObj sections] objectAtIndex: indexPath.section]];
                    NSString* department = [DATA.modelsStructure getCategory: order];
                    
                    // get identificaion
                    id identification = [tableViewObj contentForIndexPath:indexPath];
                    // show
                    [JsonBranchFactory navigateToOrderController: department order:order identifier:identification];
                };
                
            }];
        }
    };
    
    
    
    _shouldReceiveTxtField = ((JRLabelCommaTextFieldView*)[self.jsonView getView:@"shouldReceive"]).textField;
    _unReceiveTxtField = ((JRLabelCommaTextFieldView*)[self.jsonView getView:@"unReceive"]).textField;
    _totalAmountTxtField = ((JRLabelCommaTextFieldView*)[self.jsonView getView:@"totalAmount"]).textField;
    _totalAmountTxtField.delegate = self;
    
    _contractNOTxtField = ((JRLabelTextFieldView*)[self.jsonView getView:@"contractNO"]).textField;
    _contractNOTxtField.delegate = self;

}

#pragma mark -
#pragma mark - Request

-(BOOL) validateSendObjects: (NSMutableDictionary*)objects order:(NSString*)order
{
    if ([_totalAmountTxtField.text floatValue] != [_shouldReceiveTxtField.text floatValue]){
        [Utility showAlert: LOCALIZE_MESSAGE(@"ShouldSumNotEqualTotalSum")];
        return NO;
    }
    return [super validateSendObjects:objects order:order];
}

-(NSMutableDictionary*) assembleSendObjects: (NSString*)divViewKey
{
    NSMutableDictionary* objects = [super assembleSendObjects: divViewKey];
    
    NSMutableArray* tranlateArray = [self translateDateInArray:_contractPayContents fromPattern:DATE_PATTERN toPattern:DATE_TIME_PATTERN];
    
    [objects setObject:tranlateArray forKey:@"ContractPayBills"];
    
    
    return objects;
}


#pragma mark -
#pragma mark - Response


-(void) renderWithReceiveObjects: (NSMutableDictionary*)objects
{
    NSLog(@"objects === %@",objects);
    [self.jsonView setModel: objects];
    NSMutableArray* billObjects = [objects objectForKey:@"ContractPayBills"];
    _contractPayContents = [self translateDateInArray:billObjects fromPattern:DATE_TIME_PATTERN toPattern:DATE_PATTERN];
    [_contractPayTableView reloadTableData];
}


#pragma mark -
#pragma mark - UITextField Delegate
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
//    if (isEmptyString(_totalAmountTxtField.text)) {
//        NSString* localizeTip = LOCALIZE_KEY(LOCALIZE_CONNECT_KEYS(@"Contract",@"totalAmount"));
//        NSString* localizeValue = LOCALIZE_MESSAGE_FORMAT(MESSAGE_ValueCannotEmpty, localizeTip);
//        [Utility showAlert:localizeValue];
//    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{

    //contractNO
    if (textField == _contractNOTxtField) {
        if (![Utility checkDigitAndAlphabetFormat:_contractNOTxtField.text]) {
            [Utility showAlert:LOCALIZE_MESSAGE(@"OnlyDigitAndAlphabet")];
            _contractNOTxtField.text = @"";
        }
        return;
    }
    //total Amount
    if (textField == _totalAmountTxtField) {
        [self calculateRemainRate:_totalAmountTxtField.text];
        [_contractPayTableView.tableView  reloadData];
        return;
    }
    
    /*cell subViews*/
    JRTextField* jrTextField = (JRTextField*)textField;
    if (jrTextField.inputValidator && ![jrTextField textFieldValidate]) {
        jrTextField.text = @"";
        return;
    }
    
    ContractPayCell* payCell = (ContractPayCell*)[TableViewHelper getTableViewCell: _contractPayTableView.tableView cellSubView:jrTextField];
    NSIndexPath* indexPath  = [_contractPayTableView.tableView indexPathForCell: payCell];
    int row = indexPath.row;
    
    if (jrTextField == payCell.installmentTxtField) {
        [self modifyTableViewSourceIndex:indexPath fromView:jrTextField];
        return;
    }
    
    
    payCell.payRateTxtField.text = [AppMathUtility calculateRate:jrTextField.text dividend:_totalAmountTxtField.text];
    if (row == _contractPayContents.count-1) {
        [_contractPayContents replaceObjectAtIndex:row withObject:[payCell getDatas]];
        NSString* upPayText = [AppMathUtility calculateSubtraction:_totalAmountTxtField.text minuend:[self calculateHavePaidTotal]];
        if ([upPayText floatValue] > 0) {
            [self calculateRemainRate:upPayText];
        }else if ([upPayText floatValue] < 0){
            [Utility showAlert:LOCALIZE_MESSAGE(@"InstallmentOutOfRate")];
            return;
        }
    }else{
        [_contractPayContents replaceObjectAtIndex:row withObject:[payCell getDatas]];
    }
    [_contractPayTableView.tableView  reloadData];
    [_contractPayTableView.tableView  scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
    
    
}

#pragma mark -
#pragma mark - Calculate Pay

-(void)refreshTotal
{
    if (_contractPayContents.count == 0 || self.controlMode != JsonControllerModeCreate) return;
    _shouldReceiveTxtField.text = [self calculateHavePaidTotal];
    _unReceiveTxtField.text = [self calculateHavePaidTotal];
}


-(void)calculateRemainRate:(NSString*)paidText
{
    NSMutableDictionary* values = [NSMutableDictionary dictionary];
    [values setObject: paidText forKey:@"payAmount"];
    NSString* rateString = [AppMathUtility calculateRate:paidText dividend:_totalAmountTxtField.text];
    [values setObject: rateString forKey:@"payRate"];
    [values setObject:@" " forKey:@"installment"];
    [values setObject:@" " forKey:@"willPayDate"];
    [_contractPayContents addObject:values];
}

-(NSString*)calculateHavePaidTotal
{
    float payTotal = 0;
    for (int i = 0; i < [_contractPayContents count] ; i++ ) {
        NSDictionary* dic = [_contractPayContents objectAtIndex:i];
        
        NSString* subTotal = [dic objectForKey:@"payAmount"];
        payTotal += [subTotal floatValue];
        
    }
    return [NSString stringWithFormat:@"%.2f",payTotal];
}

#pragma mark - 
#pragma mark - TranslateDate
-(NSMutableArray*)translateDateInArray:(NSMutableArray*)array fromPattern:(NSString*)fromPattern toPattern:(NSString*)toPattern
{
    NSMutableArray* afterTranslateArray = [NSMutableArray array];
    for (NSMutableDictionary* mutDic in array) {
        NSString* sourceStr = [mutDic objectForKey:@"willPayDate"];
        NSString* targetStr = [DateHelper stringFromString:sourceStr fromPattern:fromPattern toPattern:toPattern];
        [mutDic setObject:targetStr forKey:@"willPayDate"];
        [afterTranslateArray addObject:mutDic];
    }
    return afterTranslateArray;
}

#pragma mark -
#pragma mark - SelectedDate
-(void)dateWasSelected:(NSDate*)selectedDate element:(id)element
{
    JRTextField* jrTextField = (JRTextField*)element;
    jrTextField.text = [DateHelper stringFromDate:selectedDate pattern:DATE_PATTERN];
    [self modifyTableViewSourceIndex:[self getIndexPathFromView:jrTextField] fromView:jrTextField];
    
}

#pragma mark - 
#pragma mark - Handle TableView
-(NSIndexPath*)getIndexPathFromView:(JRTextField*)jrTextField
{
    ContractPayCell* payCell = (ContractPayCell*)[TableViewHelper getTableViewCell: _contractPayTableView.tableView cellSubView:jrTextField];
    return [_contractPayTableView.tableView indexPathForCell: payCell];
}

-(void)modifyTableViewSourceIndex:(NSIndexPath*) indexPath fromView:(JRTextField*)jrTextField
{
    NSMutableDictionary* itemValues = [_contractPayContents safeObjectAtIndex:indexPath.row];
    if (itemValues) {
        [itemValues setObject:jrTextField.text forKey:jrTextField.attribute];
    }
    [_contractPayContents replaceObjectAtIndex:indexPath.row withObject:itemValues];
}


#pragma mark -
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
