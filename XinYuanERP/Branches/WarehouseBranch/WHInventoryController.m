//
//  WHInventoryController.m
//  XinYuanERP
//
//  Created by Xinyuan4 on 13-12-19.
//  Copyright (c) 2013年 Xinyuan4. All rights reserved.
//

#import "WHInventoryController.h"
#import "AppInterface.h"

#import "UIViewController+CWPopup.h"
#import "PopPDFViewController.h"
#import "PopBubbleView.h"

#import "PDFMainViewController.h"
#import "PDFDataManager.h"


@interface WHInventoryController ()<UITextFieldDelegate>
{
    JRTextField* _unitTxtField ;
    JRTextField* _basicUnitTxtField;
    
    JRTextField* _priceBasicUnitTxtField;
    JRTextField* _priceUnitTxtField;
    
    JRTextField* _amountTxtField;
    
    JRTextField* _remainAmountTxtField;
    JRTextField* _lendAmountTxtField;
    JRTextField* _totalAmountTxtField;
    
    NSMutableArray* _selectedPDFArray;
}

@end

@implementation WHInventoryController

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
    
    __weak WHInventoryController* weakSelf = self;
    
    
    
    [self setUpTextFields];
    
    JRTextField* editCategoryTxtFidld = ((JRLabelTextFieldView*)[self.jsonView getView:@"productCategory"]).textField;
    editCategoryTxtFidld.textFieldDidClickAction = ^void(JRTextField* jrTextField) {
        [WarehouseHelper popTableView:jrTextField settingModel:APPSettings_WHAREHOUSE_PRODUCT_CATEGORY];
    };
    
    
    JRTextField* productDescTxtField = (JRTextField*)[self.jsonView getView:@"productDescPDF"];
    JRButton* addNewDescButton = (JRButton*)[self.jsonView getView:@"BTN_AddPDF"];
    addNewDescButton.didClikcButtonAction = ^void(JRButton* jrButton){
        
    [[PDFDataManager sharedManager] requestWithParameter:@"ProductPDF" WithComplete:^(NSError *error) {
        if (!error) {
            NSLog(@"success ---");
            
            PDFMainViewController* mainVC = [[PDFMainViewController alloc] init];
            mainVC.PDFSelectArray = _selectedPDFArray;
            mainVC.selectBlock = ^(NSMutableArray* selectArray){
                _selectedPDFArray = selectArray;
                productDescTxtField.text = [_selectedPDFArray componentsJoinedByString:KEY_COMMA];
            };
            [self.navigationController pushViewController:mainVC animated:YES];
            
            
        }
    }];
        
//        PopPDFViewController* popView = [[PopPDFViewController alloc] init];
//        popView.title = LOCALIZE_KEY(LOCALIZE_CONNECT_KEYS(MODEL_WHInventory,@"productDesc"));
//        popView.pathArray = @[@{@"PATH":PRODUCTPDF_PREFIXPATH}];
//        popView.selectedMarks = _selectedPDFArray;
//        popView.selectBlock = ^(NSMutableArray* selectArray){
//            _selectedPDFArray = selectArray;
//           productDescTxtField.text = [_selectedPDFArray componentsJoinedByString:KEY_COMMA];
//           [self dismissPopupViewControllerAnimated:YES completion:^{}];
//        };
//        [self presentPopupViewController:popView animated:YES completion:nil];
        
    };
    
    productDescTxtField.textFieldDidClickAction = ^void(JRTextField* jrTextField){
        if (isEmptyString(jrTextField.text)) return;
       [PopBubbleView popTableBubbleView:jrTextField title:LOCALIZE_KEY(LOCALIZE_CONNECT_KEYS(MODEL_WHInventory,@"productDesc")) dataSource:_selectedPDFArray selectedBlock:^(NSInteger selectedIndex, NSString *selectedValue) {
           
           WebViewController* web = [[WebViewController alloc]initWithUrlString:PRODUCTPDF_PATH(selectedValue)];
           [self presentModalViewController:web animated:YES];

       }];
    };
    
    JRComplexView* supplierView = (JRComplexView*)[self.jsonView getView: @"supplierDesc"];
    JRTableView* supplierTableView = (JRTableView*)[self.jsonView getView: @"TABLE_Supplier"];
    supplierTableView.tableViewBaseCellForIndexPathAction = ^UITableViewCell*(TableViewBase* tableViewObj, NSIndexPath* indexPath, UITableViewCell* cell){
        cell.backgroundColor = [UIColor whiteColor];
        cell.textLabel.font = [UIFont systemFontOfSize: [FrameTranslater convertFontSize: 15]];
        return cell;
    };
    supplierTableView.tableViewBaseHeightForIndexPathAction = ^CGFloat(TableViewBase* tableViewObj, NSIndexPath* indexPath){
        return [FrameTranslater convertFontSize: 30];
    };
    
    supplierTableView.tableViewBaseCanEditIndexPathAction = ^BOOL(TableViewBase* tableViewObj, NSIndexPath* indexPath){
        if (self.controlMode == JsonControllerModeCreate) return YES;
        return [PermissionChecker checkSignedUser: DEPARTMENT_PURCHASE order:MODEL_VENDOR permission:PERMISSION_DELETE];
    };
    

 
    supplierTableView.JRTableViewSetValue = ^void(JRTableView* tableView, id value){
        NSMutableArray* contents = [ArrayHelper deepCopy: [value componentsSeparatedByString:KEY_COMMA]];
        tableView.contentsDictionary = [NSMutableDictionary dictionaryWithObject: contents forKey:tableView.attribute];
        [tableView reloadData];
    };
    supplierTableView.JRTableViewGetValue = ^id(JRTableView* tableView){
        NSMutableArray* contents = [tableView.contentsDictionary objectForKey: tableView.attribute];
        NSString* value = nil;
        for (int i = 0 ; i < contents.count; i++) {
            if (i == 0) {
                value = contents[i];
            } else {
                value = [value stringByAppendingFormat:@"%@%@",KEY_COMMA, contents[i]];
            }
        }
        return value;
    };
    
    supplierView.setJRComplexViewValueBlock = ^void(JRComplexView* view, id value) {
        [supplierTableView setValue: value];
    };
    supplierView.getJRComplexViewValueBlock = ^id(JRComplexView* view) {
        return [supplierTableView getValue];
    };
    
    JRButton* buttonAdd = (JRButton*)[self.jsonView getView: @"NESTED_RIGHT.BTN_AddSupplier"];
    buttonAdd.didClikcButtonAction = ^void(JRButton* buttonAdd) {
        
        if (self.controlMode!=JsonControllerModeCreate) {
            if (!([PermissionChecker checkSignedUser: DEPARTMENT_PURCHASE order:MODEL_VENDOR permission:PERMISSION_CREATE]||
                  [PermissionChecker checkSignedUser: DEPARTMENT_PURCHASE order:MODEL_VENDOR permission:PERMISSION_DELETE])) {
                return;
            }
            
        }
        
        NSArray* needFields = @[@"number",@"name",@"category"];
        PickerModelTableView* pickView = [PickerModelTableView popupWithRequestModel:@"Vendor" fields:needFields willDimissBlock:nil];
        pickView.titleHeaderViewDidSelectAction = ^void(JRTitleHeaderTableView* headerTableView, NSIndexPath* indexPath){
            
            FilterTableView* filterTableView = (FilterTableView*)headerTableView.tableView.tableView;
            NSIndexPath* realIndexPath = [filterTableView getRealIndexPathInFilterMode: indexPath];
            NSArray* array = [filterTableView realContentForIndexPath: realIndexPath];
            
            NSString* attribute = supplierTableView.attribute;
            if (!supplierTableView.contentsDictionary) supplierTableView.contentsDictionary = [NSMutableDictionary dictionaryWithObject:[NSMutableArray array] forKey:attribute];
            [[supplierTableView.contentsDictionary objectForKey:attribute] addObject: [array objectAtIndex:2]];
            [supplierTableView reloadData];
            
            [PickerModelTableView dismiss];
        };
        
    };
    
    
    
    //scroll tab view
    self.didShowTabView = ^void(int index, JsonDivView* tabView) {
        if (weakSelf.controlMode == JsonControllerModeCreate) return;
        
        JRButton* button = [weakSelf.tabsButtonsView.subviews objectAtIndex: index];
        NSString* buttonKey = button.attribute;
        
        NSString* productCode = [(((id<JRComponentProtocal>)[weakSelf.jsonView getView:@"productCode"])) getValue];
        
       
        
        if ([buttonKey isEqualToString:@"TAB_MaterialRecord"]) {
             
             
             
        }
        
        else if ([buttonKey isEqualToString:@"TAB_MaintainRecord"]){
            
            JRRefreshTableView*  refreshTableView = (JRRefreshTableView*)[weakSelf.jsonView getView:@"NESTED_MaintainRecord.MaintainRecord_TABLE"];
             NSDictionary* objects = @{@"application": productCode};
            [weakSelf refreshTabTableView:refreshTableView orderModel:ORDER_WHPickingOrder objects:objects];
            
        }
        
        else if ([buttonKey isEqualToString:@"TAB_LendRecord"]){
            
            JRRefreshTableView*  refreshTableView = (JRRefreshTableView*)[weakSelf.jsonView getView:@"NESTED_LendRecord.LendRecord_TABLE"];
             NSDictionary* objects = @{@"productCode": productCode};
            [weakSelf refreshTabTableView:refreshTableView orderModel:ORDER_WHLendOutOrder objects:objects];
            
        }
        
        else  if ([buttonKey isEqualToString:@"TAB_PickingRecord"]) {
            
            JRRefreshTableView*  refreshTableView = (JRRefreshTableView*)[weakSelf.jsonView getView:@"NESTED_PickingRecord.PickingRecord_TABLE"];
             NSDictionary* objects = @{@"productCode": productCode};
            [weakSelf refreshTabTableView:refreshTableView orderModel:ORDER_WHPickingOrder objects:objects];
            
        }
        
    };
    
    if (self.controlMode == JsonControllerModeCreate) {
        _lendAmountTxtField.text = [@(0) stringValue];
    }
    
}

-(void)setUpTextFields
{
    _unitTxtField  = (JRTextField*)[self.jsonView getView:@"oneUnit"];
    _basicUnitTxtField = ((JRLabelTextFieldView*)[self.jsonView getView:@"basicUnit"]).textField;
    
    _priceBasicUnitTxtField = (JRTextField*)[self.jsonView getView:@"priceBasicUnit"];
    _priceUnitTxtField  = (JRTextField*)[self.jsonView getView:@"priceUnit"];
    _amountTxtField = ((JRLabelTextFieldView*)[self.jsonView getView:@"amount"]).textField;
    
    _remainAmountTxtField = ((JRLabelTextFieldView*)[self.jsonView getView:@"remainAmount"]).textField;
    _lendAmountTxtField = ((JRLabelTextFieldView*)[self.jsonView getView:@"lendAmount"]).textField;
    _totalAmountTxtField = ((JRLabelTextFieldView*)[self.jsonView getView:@"totalAmount"]).textField;
    
    
    _basicUnitTxtField.delegate = self;
    _unitTxtField.delegate = self;
    _priceBasicUnitTxtField.delegate = self;
    _priceUnitTxtField.delegate = self;
//    _lendAmountTxtField.delegate = self;
    _totalAmountTxtField.delegate = self;
    
    _unitTxtField.enabled = NO;
    _priceUnitTxtField.enabled = NO;
    _remainAmountTxtField.enabled = NO;
    
    
//    _amountTxtField.inputValidator = [[NotEmptyInputValidator alloc]init];
//    _amountTxtField.inputValidator.errorMsg =LOCALIZE_KEY(LOCALIZE_CONNECT_KEYS(self.order,_amountTxtField.attribute));
//    
//    _totalAmountTxtField.inputValidator = [[NotEmptyInputValidator alloc]init];
//    _totalAmountTxtField.inputValidator.errorMsg =LOCALIZE_KEY(LOCALIZE_CONNECT_KEYS(self.order,_totalAmountTxtField.attribute));
    
}

#pragma mark -
#pragma mark - Response

-(NSMutableDictionary*) assembleReadResponse: (ResponseJsonModel*)response
{
    
    NSDictionary* responseObject = [[response.results firstObject] firstObject];
    NSMutableDictionary* resultsObj = [DictionaryHelper deepCopy: responseObject];
    
    float totalAmount = [resultsObj[@"totalAmount"] floatValue];
    float lendAmount = [resultsObj[@"lendAmount"] floatValue];
    float remainAmount = totalAmount - lendAmount;
    
    [resultsObj setObject:[NSNumber numberWithFloat:remainAmount] forKey:@"remainAmount"];
    [resultsObj setObject:resultsObj[@"basicUnit"] forKey:@"oneUnit"];
    
    self.valueObjects = [DictionaryHelper deepCopy:resultsObj];
    
    NSMutableDictionary* modelToRender = [JsonControllerHelper getRenderModel: self.order];
    [DictionaryHelper combine: modelToRender with:self.valueObjects];
    
    return modelToRender;
    
}

#pragma mark -
#pragma mark - UITextField Delegate

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField == _basicUnitTxtField) _unitTxtField.text = _basicUnitTxtField.text;
    
    if (textField == _amountTxtField) {
        if ([_amountTxtField.text floatValue]<=0) {
            [Utility showAlert:LOCALIZE_MESSAGE(@"AmountMustGTRZero")];
            return;
        }
    }
   
    if (textField == _priceBasicUnitTxtField){
        
        if (isEmptyString(_amountTxtField.text)) {
            [self showAlterMessage:@"amount"];
            _priceBasicUnitTxtField.text = @"";
            return;
        }
        _priceUnitTxtField.text = [AppMathUtility calculateDivision:_priceBasicUnitTxtField.text dividend:_amountTxtField.text];
    }
    
    if (textField == _totalAmountTxtField) {
        if (isEmptyString(_lendAmountTxtField.text))return;
        _remainAmountTxtField.text = [AppMathUtility calculateSubtraction:_totalAmountTxtField.text minuend:_lendAmountTxtField.text];
        
    }
}


-(void)showAlterMessage:(NSString*)attribute
{
    NSString* localizeTip = LOCALIZE_KEY(LOCALIZE_CONNECT_KEYS(self.order,attribute));
    NSString* localizeValue = LOCALIZE_MESSAGE_FORMAT(MESSAGE_ValueCannotEmpty, localizeTip);
    [Utility showAlert:localizeValue];
}



-(void)refreshTabTableView:(JRRefreshTableView*)refreshTableView orderModel:(NSString*)order objects:(NSDictionary*)objects
{
   
    // send the request
    [AppViewHelper showIndicatorInView:  refreshTableView];
    [AppServerRequester readModel: order department:DEPARTMENT_WAREHOUSE objects: objects fields:@[PROPERTY_ORDERNO] completeHandler:^(ResponseJsonModel *data, NSError *error) {
        [AppViewHelper stopIndicatorInView:  refreshTableView];
        
        NSArray* array = [data.results lastObject];
        NSMutableDictionary* keysMap = [NSMutableDictionary dictionary];
        [keysMap setObject:order forKey:LOCALIZE_KEY(order)];
        NSMutableDictionary* contentDic = [NSMutableDictionary dictionaryWithObject:array forKey:LOCALIZE_KEY(order)];
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
            [OrderListControllerHelper navigateToOrderController: department order:order identifier:identification];
        };
        
    }];
}

//-(NSMutableDictionary*)filterContentDic:(NSMutableDictionary*)contentDic handle:(void (^)(id element))handler
//{
//    NSMutableDictionary* filterDic = [NSMutableDictionary dictionary];
//    NSMutableArray* filterArray = [NSMutableArray array];
//    NSArray* values = [[contentDic allValues] firstObject];
//    for (NSArray* val in values) {
//        NSMutableArray* mutVal = [NSMutableArray arrayWithArray:val];
//        if (handler) {
//            handler(mutVal);
//        }
//        [filterArray addObject:mutVal];
//    }
//    [filterDic setObject:filterArray forKey:[[contentDic allKeys] firstObject]];
//    return filterDic;
//}


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
