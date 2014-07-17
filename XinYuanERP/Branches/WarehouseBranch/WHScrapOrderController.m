//
//  WHScrapOrderController.m
//  XinYuanERP
//
//  Created by Xinyuan4 on 13-12-18.
//  Copyright (c) 2013年 Xinyuan4. All rights reserved.
//

#import "WHScrapOrderController.h"
#import "AppInterface.h"

@interface WHScrapOrderController ()


@end

@implementation WHScrapOrderController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    JRTextField* productCodeTxtField = ((JRLabelTextFieldView*)[self.jsonView getView:@"productCode"]).textField;
    JRTextField* productNameTxtField = ((JRLabelTextFieldView*)[self.jsonView getView:@"productName"]).textField;
    __weak JRTextField* weakProductCodeTxtField = productCodeTxtField;
    productCodeTxtField.textFieldDidClickAction = ^void(JRTextField* jrTextField) {
        
        NSArray* needFields = @[@"productCode",@"productName",@"productCategory"];
        PickerModelTableView* pickView = [PickerModelTableView getPickerModelView:MODEL_WHInventory fields:needFields criterias:@{@"and": [NSMutableDictionary dictionaryWithDictionary:@{@"productCategory": @"EQ<>设备"}]}];
        pickView.titleHeaderViewDidSelectAction = ^void(JRTitleHeaderTableView* headerTableView, NSIndexPath* indexPath, TableViewBase* tableView){
            
            NSArray* array = [tableView realContentForIndexPath: indexPath];
            weakProductCodeTxtField.text = [array objectAtIndex:1];
            productNameTxtField.text = [array objectAtIndex:2];
            
            [AnimationView dismissAnimationView];
        };
        
        [AnimationView presentAnimationView:pickView completion:nil];
    };
    
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
