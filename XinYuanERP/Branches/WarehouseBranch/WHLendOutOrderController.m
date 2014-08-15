//
//  WHLendOutOrderController.m
//  XinYuanERP
//
//  Created by Xinyuan4 on 13-12-21.
//  Copyright (c) 2013年 Xinyuan4. All rights reserved.
//

#import "WHLendOutOrderController.h"
#import "AppInterface.h"


@interface WHLendOutOrderController ()
{
    JsonDivView* _bottomView;
    
    JRImageView* _backgroundView;
    
    JRButton* _priorPageButton;
    JRButton* _nextPageButton;
    
    
    JRTextField* _productCodeTxtField;
    float _remainInventory;
    
}

@property (nonatomic,assign) int incrementInt;

@end

@implementation WHLendOutOrderController

//@synthesize _incrementInt;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(BOOL) viewWillAppearShouldRequestServer
{
    return [super viewWillAppearShouldRequestServer] && self.isMovingToParentViewController;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    __weak WHLendOutOrderController* weakSelf = self;
    __block WHLendOutOrderController* blockSelf = self;
    
    /*select staffCategory and staffNO*/
    JRTextField* staffCategoryTxtField = ((JRLabelCommaTextFieldView*)[self.jsonView getView:@"staffCategory"]).textField;
    JRTextField* staffNOTxtField = ((JRLabelCommaTextFieldView*)[self.jsonView getView:@"staffNO"]).textField;
    NSArray* arr = [DATA.usersNONames allValues];
    NSDictionary* dic = @{@"施工队": @[], @"客户资料":@[], @"员工资料":arr,@"供应商":@[]};
    
    JRTextFieldDidClickAction clickBlock = ^void(JRTextField* jrTextField){
        [CustomPickerView showPicker:jrTextField title:@"选择人员" pickerDataSource:dic doneBlock:^(NSInteger selectedIndex, NSString *selectedValue) {
            NSArray* array = [selectedValue componentsSeparatedByString:KEY_COMMA];
            staffCategoryTxtField.text = [array firstObject];
            staffNOTxtField.text = [array lastObject];
        }];
    };
    staffCategoryTxtField.textFieldDidClickAction = clickBlock;
    staffNOTxtField.textFieldDidClickAction = clickBlock;
    
    /*select product*/
    _productCodeTxtField= ((JRLabelTextFieldView*)[self.jsonView getView:@"productCode"]).textField;
    JRTextField* productNameTxtField = ((JRLabelTextFieldView*)[self.jsonView getView:@"productName"]).textField;
    JRTextField* unitTxtField = ((JRLabelTextFieldView*)[self.jsonView getView:@"unit"]).textField;
    
    
    _productCodeTxtField.textFieldDidClickAction = ^void(JRTextField* jrTextField){
        
        NSArray* needFields = @[@"productCode",@"productName",@"totalAmount",@"lendAmount",@"basicUnit"];
        PickerModelTableView* pickView = [PickerModelTableView popupWithRequestModel:MODEL_WHInventory fields:needFields willDimissBlock:nil];
        pickView.tableView.headersXcoordinates = @[@(20), @(150),@(280),@(400),@(520)];
        pickView.titleHeaderViewDidSelectAction = ^void(JRTitleHeaderTableView* headerTableView, NSIndexPath* indexPath){
            
            FilterTableView* filterTableView = (FilterTableView*)headerTableView.tableView.tableView;
            NSIndexPath* realIndexPath = [filterTableView getRealIndexPathInFilterMode: indexPath];
            NSArray* array = [filterTableView realContentForIndexPath: realIndexPath];
            
            jrTextField.text = [array objectAtIndex:1];
            productNameTxtField.text = [array objectAtIndex:2];
            unitTxtField.text = [array objectAtIndex:5];
            blockSelf->_remainInventory = [[array objectAtIndex:3] floatValue] - [[array objectAtIndex:4] floatValue];
            
            [PickerModelTableView dismiss];
        };
        
    };
    
    
//    JRButtonTextFieldView* createUserView = (JRButtonTextFieldView*)[self.jsonView getView:@"NESTED_TOP.createUser"];
//    JRButtonTextFieldView* app1View = (JRButtonTextFieldView*)[self.jsonView getView:@"NESTED_TOP.app1"];
//    JRButtonTextFieldView* app2View= (JRButtonTextFieldView*)[self.jsonView getView:@"NESTED_TOP.app2"];
    
//    [KVOObserver observerForObject:createUserView.textField keyPath:@"text" oldAndNewBlock:^(id oldValue, id newValue) {
//        NSLog(@"oldValue === %@",oldValue);
//        app1View.button.userInteractionEnabled  =  !OBJECT_EMPYT(newValue);
//        NSLog(@"newValue === %@",newValue);
//    }];
//    
//    [KVOObserver observerForObject:app1View.textField keyPath:@"text" oldAndNewBlock:^(id oldValue, id newValue) {
//        app2View.button.userInteractionEnabled  =  !OBJECT_EMPYT(newValue);
//        NSLog(@"oldValue === %@",oldValue);
//        NSLog(@"newValue === %@",newValue);
//    }];
    
//    [WarehouseHelper constraint:app1View condition:createUserView];
//    [WarehouseHelper constraint:app2View condition:app1View];
    
//    JRButton* BTN_ReturnNumButton = (JRButton*)[self.jsonView getView:@"NESTED_BOTTOM.BTN_ReturnNum"];
//    [self constraint:app2View complete:^(BOOL success){
//        BTN_ReturnNumButton.userInteractionEnabled = success;
//    }];
    
    
    _incrementInt = 0;
    _bottomView = ((JsonDivView*)[self.jsonView getView:@"NESTED_BOTTOM"]);
    _backgroundView = ((JRImageView*)[self.jsonView getView:@"BG_BOTTOM_IMAGE"]);
    _priorPageButton = (JRButton*)[self.jsonView getView:@"BTN_PriorPage"];
    _nextPageButton = (JRButton*)[self.jsonView getView:@"BTN_NextPage"];
    
    JRButton* returnButton = ((JRButton*)[self.jsonView getView:@"NESTED_BOTTOM.BTN_ReturnNum"]);
    returnButton.didClikcButtonAction =  ^void(JRButton* button){
        [WHLendOutOrderController deriveReturnViews: weakSelf index:weakSelf.incrementInt];
        weakSelf.incrementInt++;
        
        // override preview
        NSString* LASTimageKey = [NSString stringWithFormat:@"%@%d.%@",@"NESTED_MIDDLE_INCREMENT_",_incrementInt-1,@"IMG_Photo_Return"];
        JRImageView* jrImageView = (JRImageView*)[self.jsonView getView:LASTimageKey];
        jrImageView.didClickAction = ^void(JRImageView* imageView) {
            [JRComponentHelper previewImagesWithBrowseImageView: imageView config:nil];
        };
    };
    
    [WHLendOutOrderController deriveReturnViews: self index:0];
    weakSelf.incrementInt++;
}

+(void) removerDeriveReturnViews: (WHLendOutOrderController*)controller index:(int)index
{
    NSString* NESTEDTAG = [NSString stringWithFormat:@"%@%d",@"NESTED_MIDDLE_INCREMENT_",index];
    JsonDivView* nestedDivView = (JsonDivView*)[controller.jsonView getView: NESTEDTAG] ;
    [nestedDivView removeFromSuperview];
    if (index != 0) {
        [controller baseSuperViewMove:- [nestedDivView sizeHeight]];
    }
}

+(void) deriveReturnViews: (WHLendOutOrderController*)controller index:(int)index
{
    NSDictionary* specifications = controller.jsonView.specifications[@"COMPONENTS"][@"NESTED_MIDDLE_INCREMENT_"];
    
    NSString* NESTEDTAG = [NSString stringWithFormat:@"%@%d",@"NESTED_MIDDLE_INCREMENT_",index];
    JsonDivView* nestedDivView = (JsonDivView*)[JsonViewRenderHelper render:NESTEDTAG specifications:specifications];
    [controller.jsonView addSubviewToContentView:nestedDivView];
    
    [nestedDivView addOriginY: [nestedDivView sizeHeight] * index];
    
    // -------- Client
    
    // --- DATE
    NSString* deferedReturAttribute = [NSString stringWithFormat:@"%@.%@", NESTEDTAG, @"returnDate"];
    [controller.specifications[@"CLIENT"][@"COMS_DATE_PICKERS"] addObject:deferedReturAttribute];
    [controller.specifications[@"CLIENT"][@"COMS_DATE_PATTERNS"] setObject: deferedReturAttribute forKey:@"yyyy-MM-dd"];
    
    // --- IMAGE PICKER
    NSString* deferedImageAttribute = [NSString stringWithFormat:@"%@.%@", NESTEDTAG, @"BTN_Take_Return"];
    NSString* deferedImageViewAttribute = [NSString stringWithFormat:@"%@.%@", NESTEDTAG, @"IMG_Photo_Return"];
    [controller.specifications[@"IMAGES"][@"IMAGES_PREVIEWS"] setObject:@{} forKey:deferedImageViewAttribute ];
    [controller.specifications[@"IMAGES"][@"IMAGE_PICKER"] setObject: deferedImageViewAttribute forKey:deferedImageAttribute];
    
    
    NSString* returnDateKey = [NSString stringWithFormat:@"%@.%@", NESTEDTAG, @"returnDate"];
    [controller.specifications[@"IMAGES"][@"IMAGES_NAMES"] setObject:@{@"MAINNAME": @[@"orderNO", returnDateKey],
                                                                 @"SUF":@"ReturnProduct.png"} forKey:deferedImageViewAttribute  ];
    [controller.specifications[@"IMAGES"][@"IMAGES_DATAS"] setObject:@{} forKey:deferedImageViewAttribute  ];
    
    
    NSString* returnDateImageLoadKey = [NSString stringWithFormat:@"%@.%@", NESTEDTAG, @"IMG_Photo_Return"];
    [controller.specifications[@"IMAGES"][@"IMAGES_LOAD"] addObject:returnDateImageLoadKey];
    
    
    // ---------- Sever
    NSString* creatorButtonKey = [NESTEDTAG stringByAppendingFormat:@".%@",@"createUser"];
    
    [controller.specifications[@"SERVER"][@"SUBMIT_BUTTONS"] addObject:@{@"MODEL_SENDVIEW" : NESTEDTAG,
                                                                   @"MODEL_SENDORDER" : @"WHLendOutBill",
                                                                   
                                                                   creatorButtonKey: @{ @"MODEL_APPTO" : @"app1"},
                                                                   [NESTEDTAG stringByAppendingFormat:@".%@",@"app1"]: @{@"BUTTON_TYPE" : @(1),
                                                                                                                         @"MODEL_APPFROM" : @"app1",
                                                                                                                         @"MODEL_APPTO" : @"app2"},
                                                                   [NESTEDTAG stringByAppendingFormat:@".%@",@"app2"]: @{@"BUTTON_TYPE" : @(1),
                                                                                                                         @"MODEL_APPFROM" : @"app2",
                                                                                                                         @"MODEL_APPTO" : @"createUser"}
                                                                   
                                                                   }];
    
    
    
    JRButton* createBTN = ((JRButtonTextFieldView*)[nestedDivView getView:creatorButtonKey]).button;
    NormalButtonDidClickBlock previousAction = createBTN.didClikcButtonAction;
    createBTN.didClikcButtonAction = ^void(NormalButton* btn) {
        if (previousAction) {
            previousAction(btn);
        }
    };
    
    
    // refresh event
    [controller setupClientEvents];
    [controller setupServerEvents];
    
    
    if (index != 0) {
        [controller baseSuperViewMove:[nestedDivView sizeHeight]];
    }
}

#pragma mark -
#pragma mark - Request

-(RequestJsonModel*) assembleReadRequest:(NSDictionary*)objects
{
    NSString* orderNO = self.identification;
    RequestJsonModel* requestModel = [OrderJsonModelFactory factoryMultiJsonModels:@[ORDER_WHLendOutOrder, BILL_WHLendOutBill]
                                                                           objects:@[[RequestModelHelper getModelIdentities: orderNO], @{}]
                                                                              path:PATH_LOGIC_READ(self.department)];
    
    [requestModel.preconditions addObjectsFromArray: @[@{}, @{@"billNO": @"0-0-orderNO"}]];
    
    return requestModel;
}

-(NSMutableDictionary*) assembleSendObjects: (NSString*)divViewKey
{
    NSMutableDictionary* objects = [super assembleSendObjects: divViewKey];
    
    if ([divViewKey isEqualToString:@"NESTED_TOP"]) {
        JRTextView* remarkTxtView = ((JRLabelTextView*)[self.jsonView getView:@"NESTED_BOTTOM.remark"]).textView;
        [objects setObject:remarkTxtView.text forKey:@"remark"];
    }
    else {
        NSString* orderNO = self.valueObjects[@"orderNO"];
        [objects setObject:orderNO forKey:@"billNO"];
        [objects setObject:DATA.signedUserName forKey:@"createUser"];
    }
    
    return objects;
}


-(BOOL) validateSendObjects: (NSMutableDictionary*)objects order:(NSString*)order
{
    
    if (self.controlMode == JsonControllerModeCreate)
    {
        if (!isEmptyString(_productCodeTxtField.text)){
            
            JRTextField* lendAmountTxtField = ((JRLabelTextFieldView*)[self.jsonView getView:@"lendAmount"]).textField;
            float lendAmount = [lendAmountTxtField.text floatValue];
            if (lendAmount>_remainInventory) {
                [Utility showAlert: LOCALIZE_MESSAGE(@"LendAmountOutOfLimit")];
                return NO;
            }
        }
    }
    return [super validateSendObjects:objects order:order];
}

#pragma mark -
#pragma mark - Response

-(NSMutableDictionary*) assembleReadResponse: (ResponseJsonModel*)response
{
    
    NSArray* results = response.results;
    NSMutableDictionary* responseObject = [NSMutableDictionary dictionary];
    
    NSDictionary* orderObject = [[results firstObject] firstObject];
    NSArray* billArray = [results lastObject];
    
    [responseObject setObject:orderObject forKey:@"order"];
    [responseObject setObject:billArray forKey:@"bills"];
    
    NSMutableDictionary* resultsObj = [DictionaryHelper deepCopy: responseObject];
    self.valueObjects = resultsObj[@"order"];
    
//    DBLOG(@"resultsObj === %@", resultsObj);
    
    return resultsObj;
    
}

-(void) enableViewsWithReceiveObjects: (NSMutableDictionary*)objects
{
    NSMutableDictionary* orderObjdect = [objects objectForKey:@"order"];
    
    [self createBillViews:[objects objectForKey:@"bills"]];
    
    [super enableViewsWithReceiveObjects:orderObjdect];
    
    [self enableBillViews:orderObjdect];
    
}


-(void) translateReceiveObjects: (NSMutableDictionary*)objects
{
    NSMutableDictionary* orderObjdect = [objects objectForKey:@"order"];
    [super translateReceiveObjects: orderObjdect];
}

-(void) renderWithReceiveObjects: (NSMutableDictionary*)objects
{
    NSDictionary* orderObjdect = [objects objectForKey:@"order"];
    
    //    DBLOG(@"orderObjdect === %@",orderObjdect);
    
    JsonDivView* orderTopDivView = (JsonDivView*)[self.jsonView getView:@"NESTED_TOP"];
    [orderTopDivView setModel: orderObjdect];
    
    JsonDivView* orderBottomDivView = (JsonDivView*)[self.jsonView getView:@"NESTED_BOTTOM"];
    [orderBottomDivView setModel: orderObjdect];
    
    JRTextField* notReturnAmountTxtField = ((JRLabelTextFieldView*)[self.jsonView getView:@"NESTED_BOTTOM.notReturnAmount"]).textField;
    
    float lendAmount = [[orderObjdect objectForKey:@"lendAmount"] floatValue];
    notReturnAmountTxtField.text = [[NSNumber numberWithFloat:lendAmount] stringValue];
    
    NSArray* bills = [objects objectForKey:@"bills"];
    
    for (int j = 0; j<[bills count]; ++j) {
        
        NSString* NestedBillTag = [NSString stringWithFormat:@"%@%d",@"NESTED_MIDDLE_INCREMENT_",j];
        JsonDivView* billDivView = (JsonDivView*)[self.jsonView getView:NestedBillTag];
        
        NSDictionary* billObjdect = bills[j];
        NSMutableDictionary* billMutObject = [DictionaryHelper deepCopy: billObjdect];
        [super translateReceiveObjects: billMutObject];
        [billDivView setModel: billMutObject];
        
        float returnAmount = [[billObjdect objectForKey:@"returnAmount"] floatValue];
        lendAmount = lendAmount - returnAmount;
    }
    
    notReturnAmountTxtField.text = [[NSNumber numberWithFloat:lendAmount] stringValue];
}



#pragma mark -
#pragma mark - Handle Bills
-(void)createBillViews:(NSArray *)bills
{
    int billCount = bills.count;
    int previousBillCount = self.incrementInt;
    int substract = billCount - previousBillCount;
    
    if (substract < 0) {
        for (int i = 0; i < abs(substract); i++) {
            [WHLendOutOrderController removerDeriveReturnViews: self index: previousBillCount - (i+1)];
            self.incrementInt -- ;
        }
    } else {
        
        for (int i = 0; i < substract; ++i) {
            [WHLendOutOrderController deriveReturnViews: self index: previousBillCount + i];
            self.incrementInt ++ ;
        }
    }
    
    if ([bills count] == 0) {
        [WHLendOutOrderController deriveReturnViews: self index: 0];
        self.incrementInt ++ ;
    }
}

-(void)enableBillViews:(NSMutableDictionary*)orderObjdect
{
    BOOL isOrderAllApproved = [JsonControllerHelper isAllApplied: self.order valueObjects:orderObjdect];
    
    JRButton* BTN_ReturnNumButton = (JRButton*)[self.jsonView getView:@"NESTED_BOTTOM.BTN_ReturnNum"];
    BTN_ReturnNumButton.enabled = isOrderAllApproved;
    
    if (isOrderAllApproved) {
        
        NSArray* bills = [orderObjdect objectForKey:@"bills"];
        
        NSDictionary* lastBillObject = [bills lastObject];
        NSString* apporovingLevel = PROPERTY_CREATEUSER;
        int billDivIndex = bills.count;
        
        if (lastBillObject != nil) {
            while (!OBJECT_EMPYT(lastBillObject[apporovingLevel])) {
                apporovingLevel = [JsonControllerHelper getNextAppLevel: apporovingLevel];
            }
            billDivIndex = bills.count - 1;
        }
        
        if (!lastBillObject[apporovingLevel]) {
            
            NSString* billDivViewKey = [NSString stringWithFormat:@"%@%d",@"NESTED_MIDDLE_INCREMENT_", billDivIndex];
            JsonDivView* billDivView = (JsonDivView*)[self.jsonView getView: billDivViewKey];
            
            JRButton* approvalingButton = ((JRButtonTextFieldView*)[billDivView getView: apporovingLevel]).button;
            
            if (!lastBillObject || [DATA.signedUserName isEqualToString: lastBillObject[PROPERTY_FORWARDUSER]]) {
                [JsonControllerHelper setUserInterfaceEnable: approvalingButton enable:YES];
            }
            
            
        }
    }

}


#pragma mark -
#pragma mark - Order Operation
-(void)baseSuperViewMove:(float)moveHeight
{
    CGRect bottomRect = _bottomView.frame;
    bottomRect.origin.y = bottomRect.origin.y + moveHeight;
    [_bottomView setFrame:bottomRect];
    
    
    CGRect bgRect = self.jsonView.contentView.frame;
    bgRect.size.height = bgRect.size.height + moveHeight;
    _backgroundView.frame = bgRect;
    
    self.jsonView.contentView.frame = bgRect;
    self.jsonView.contentSize = CGSizeMake(self.jsonView.bounds.size.width,bgRect.size.height);
    
    CGRect priorPageRect = _priorPageButton.frame;
    priorPageRect.origin.y = priorPageRect.origin.y + moveHeight;
    _priorPageButton.frame = priorPageRect;
    
    
    CGRect nextPageRect = _nextPageButton.frame;
    nextPageRect.origin.y = nextPageRect.origin.y + moveHeight;
    _nextPageButton.frame = nextPageRect;
    
}

typedef void (^Success)(BOOL);
-(void)constraint:(JRButtonTextFieldView*)constraintView complete:(Success)completeBlock
{
    
    JRTextField* txtField = constraintView.textField;
    BOOL success = !isEmptyString(txtField.text);
    completeBlock(success);
    
}

- (void)dealloc
{
    NSLog(@"LendOutOrder dealloc");
}

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
