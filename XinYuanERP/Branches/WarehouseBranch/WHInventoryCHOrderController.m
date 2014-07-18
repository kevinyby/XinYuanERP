//
//  WHInventoryCHOrderController.m
//  XinYuanERP
//
//  Created by Xinyuan4 on 14-3-15.
//  Copyright (c) 2014年 Xinyuan4. All rights reserved.
//

#import "WHInventoryCHOrderController.h"
#import "AppInterface.h"

#import "UIViewController+CWPopup.h"
#import "PopPDFViewController.h"
#import "PopBubbleView.h"

@interface WHInventoryCHOrderController ()
{
     NSMutableArray* _selectedPDFArray;
}

@property(nonatomic,strong)NSString* WHInventoryNo;

@end

@implementation WHInventoryCHOrderController

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
    JsonView* jsonView = self.jsonView;
    
    [ViewHelper iterateSubView: jsonView.contentView class:[JRTextField class] handler:^BOOL(id subView) {
        JRTextField* tx = (JRTextField*)subView;
        tx.backgroundColor = [UIColor clearColor];
        return NO;
    }];
    
    JRTextField* productCodeTxtField = ((JRLabelTextFieldView*)[jsonView getView:@"productCode_O"]).textField;
    
    JsonDivView* bodyDivView = (JsonDivView*)[jsonView getView:@"NESTED_LEFT"];
    
    productCodeTxtField.textFieldDidClickAction = ^void(JRTextField* jrTextField) {
        
        NSArray* needFields = @[@"productCode", @"productName", @"productCategory"];
        PickerModelTableView* pickView = [PickerModelTableView popupWithRequestModel:MODEL_WHInventory fields:needFields willDimissBlock:nil];
        pickView.titleHeaderViewDidSelectAction = ^void(JRTitleHeaderTableView* headerTableView, NSIndexPath* indexPath){
            FilterTableView* filterTableView = (FilterTableView*)headerTableView.tableView.tableView;
            NSIndexPath* realIndexPath = [filterTableView getRealIndexPathInFilterMode: indexPath];
            id idetification = [[filterTableView realContentForIndexPath: realIndexPath] firstObject];
            NSDictionary* objects = @{PROPERTY_IDENTIFIER: idetification};
            
            [VIEW.progress show];
            [AppServerRequester readModel: MODEL_WHInventory department:DEPARTMENT_WAREHOUSE objects:objects completeHandler:^(ResponseJsonModel *data, NSError *error) {
                NSArray* objects = data.results;
                NSDictionary* ckkcObjects = [[objects firstObject] firstObject];
                NSDictionary* model = [DictionaryHelper tailKeys: ckkcObjects with:@"_O" excepts:nil];
                NSMutableDictionary* mutModel = [DictionaryHelper deepCopy:model];
                [mutModel setObject:model[@"basicUnit_O"] forKey:@"oneUnit_O"];
                // Automatic fill the textfield .
                
                [bodyDivView clearModel];
                [bodyDivView setModel: mutModel];
                [VIEW.progress hide];
                
            }];
             [PickerModelTableView dismiss];
        };
        
    };
    
    JRButton* app4Button = ((JRButtonTextFieldView*)[jsonView getView:@"NESTED_footer.app4"]).button;
    NormalButtonDidClickBlock preClickAction = app4Button.didClikcButtonAction;
    app4Button.didClikcButtonAction = ^void(JRButton* button){
        
        preClickAction(button); // call super/ old;
        
        JRImageView* QRCodeImageView= (JRImageView*)[jsonView getView:@"IMG_QRCode"];
        NSData* QRData=UIImagePNGRepresentation(QRCodeImageView.image);
        NSString* path = [NSString stringWithFormat:@"%@/%@/%@/%@",DEPARTMENT_WAREHOUSE,MODEL_WHInventory,self.WHInventoryNo,@"QRCode.png"];
        __block NSError* errorOccur = nil;
        [AppServerRequester saveImages: @[QRData] paths:@[path] completeHandler:^(id identification, ResponseJsonModel *data, NSError *error, BOOL isFinish) {
            if (error) errorOccur = error;
            if (isFinish) {
                if (errorOccur) {
                    
                    [PopupViewHelper popAlert:@"Failed" message:@"Image Upload Failed ." style:0 actionBlock:^(UIView *popView, NSInteger index) {
                        [VIEW.navigator popViewControllerAnimated: YES];
                    } dismissBlock:nil buttons:LOCALIZE_KEY(@"OK"), nil];
                    
                }
            }
        }];
    };
    

    
    JRTextField* productDescTxtField = (JRTextField*)[jsonView getView:@"productDescPDF_N"];
    productDescTxtField.textFieldDidClickAction = ^void(JRTextField* jrTextField) {
        if (self.controlMode == JsonControllerModeCreate) {
            
            PopPDFViewController* popView = [[PopPDFViewController alloc] init];
            popView.title = LOCALIZE_KEY(LOCALIZE_CONNECT_KEYS(MODEL_WHInventory,@"productDesc"));
            popView.pathArray = @[@{@"PATH":PRODUCTPDF_PREFIXPATH}];
            popView.selectedMarks = _selectedPDFArray;
            popView.selectBlock = ^(NSMutableArray* selectArray){
                _selectedPDFArray = selectArray;
                jrTextField.text = [_selectedPDFArray componentsJoinedByString:KEY_COMMA];
                [self dismissPopupViewControllerAnimated:YES completion:^{}];
            };
            [self presentPopupViewController:popView animated:YES completion:nil];
            
        }
        else if(self.controlMode == JsonControllerModeRead){
            
            if (isEmptyString(jrTextField.text)) return;
            [PopBubbleView popTableBubbleView:jrTextField title:LOCALIZE_KEY(LOCALIZE_CONNECT_KEYS(MODEL_WHInventory,@"productDesc")) dataSource:_selectedPDFArray selectedBlock:^(NSInteger selectedIndex, NSString *selectedValue) {
                WebViewController* web = [[WebViewController alloc]initWithUrlString:PRODUCTPDF_PATH(selectedValue)];
                [self presentModalViewController:web animated:YES];
                
            }];
        }
    };
    
}

#pragma mark -
#pragma mark - Response
-(void) translateReceiveObjects: (NSMutableDictionary*)objects
{
    [super translateReceiveObjects:objects];
    
    NSArray* array = @[@"totalAmount_N",@"lendAmount_N",@"amount_N",@"priceBasicUnit_N"];
    for (int i = 0; i < array.count; i++) {
        NSString* key = array[i];
        NSNumber* number = objects[key];
        float value = [number floatValue];
        if (value == -1) {
            [objects setObject:@"" forKey:key];
        }
    }
    [objects setObject:objects[@"basicUnit_O"] forKey:@"oneUnit_O"];
    [objects setObject:objects[@"basicUnit_N"] forKey:@"oneUnit_N"];
    
}

#pragma mark -
#pragma mark - Request
-(RequestJsonModel*) assembleReadRequest:(NSDictionary*)objects
{
    RequestJsonModel* requestModel = [RequestJsonModel getJsonModel];
    requestModel.path = PATH_LOGIC_READ(self.department);
    [requestModel addModels: self.order, MODEL_WHInventory, nil];
    [requestModel addObjects: objects, @{}, nil];
    [requestModel.fields addObjectsFromArray:@[@[],@[@"orderNO"]]];
    [requestModel.preconditions addObjectsFromArray: @[@{}, @{@"productCode": @"0-0-productCode_O"}]];
    return requestModel;
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
