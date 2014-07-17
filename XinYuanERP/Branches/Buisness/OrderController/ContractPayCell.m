//
//  ContractPayCell.m
//  XinYuanERP
//
//  Created by Xinyuan4 on 14-6-21.
//  Copyright (c) 2014年 Xinyuan4. All rights reserved.
//

#import "ContractPayCell.h"
#import "AppInterface.h"

@interface ContractPayCell() <UITextFieldDelegate>

@end

@implementation ContractPayCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        _installmentTxtField = [[JRTextField alloc] init];
        
        _willPayDateTxtField = [[JRTextField alloc] init];
        
        _payRateTxtField = [[JRTextField alloc] init];
        
        _payAmountTxtField = [[JRTextField alloc] init];
        
                
        [self.contentView addSubview:_installmentTxtField];
        [self.contentView addSubview:_willPayDateTxtField];
        [self.contentView addSubview:_payRateTxtField];
        [self.contentView addSubview:_payAmountTxtField];
        
        self.backgroundColor = [UIColor clearColor];
        
        [super renderCellSubView:@"Contract"];
        
        
    }
    return self;
}

-(void)setTextFieldDelegate:(id)textFieldDelegate
{
    _payAmountTxtField.inputValidator = [[NumericInputValidator alloc]init];
    _payAmountTxtField.inputValidator.errorMsg = LOCALIZE_KEY(LOCALIZE_CONNECT_KEYS(@"Contract", _payAmountTxtField.attribute));
    _payAmountTxtField.delegate = textFieldDelegate;
    
    _payRateTxtField.enabled = NO;
    
    _installmentTxtField.delegate = textFieldDelegate;
    
    _willPayDateTxtField.textFieldDidClickAction = ^void(JRTextField* jrTextField){
        [ActionSheetDatePicker showPickerWithTitle: @"" datePickerMode:UIDatePickerModeDate selectedDate:[NSDate date] target:textFieldDelegate action:@selector(dateWasSelected:element:) origin:jrTextField];
    };
    
}



@end
