//
//  WHPurchaseStorageCell.m
//  XinYuanERP
//
//  Created by Xinyuan4 on 14-6-25.
//  Copyright (c) 2014年 Xinyuan4. All rights reserved.
//

#import "WHPurchaseStorageCell.h"
#import "AppInterface.h"


@interface WHPurchaseStorageCell()<UITextFieldDelegate>

@property(nonatomic, strong) JRTextField* codeTxtField;
@property(nonatomic, strong) JRTextField* nameTxtField;
@property(nonatomic, strong) JRTextField* qcTxtField;
@property(nonatomic, strong) JRTextField* numTxtField;
@property(nonatomic, strong) JRTextField* unitTxtField;
@property(nonatomic, strong) JRTextField* unitPriceTxtField;
@property(nonatomic, strong) JRTextField* subTotalTxtField;

@property(nonatomic, strong) JRTextField* storageNumTxtField;
@property(nonatomic, strong) JRTextField* storageUnitTxtField;
@property(nonatomic, strong) JRTextField* storageUnitPriceTxtField;
@property(nonatomic, strong) JRTextField* storageSubTotalTxtField;


@end


@implementation WHPurchaseStorageCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        _codeTxtField  = [[JRTextField alloc] init];
        
        _nameTxtField  = [[JRTextField alloc] init];
        
        _qcTxtField    = [[JRTextField alloc] init];
        
        _numTxtField   = [[JRTextField alloc] init];
        
        _unitTxtField  = [[JRTextField alloc] init];
        
        _unitPriceTxtField = [[JRTextField alloc] init];
        
        _subTotalTxtField  = [[JRTextField alloc] init];
        
        _storageNumTxtField  = [[JRTextField alloc] init];
        
        _storageUnitTxtField = [[JRTextField alloc] init];
        
        _storageUnitPriceTxtField = [[JRTextField alloc] init];
        
        _storageSubTotalTxtField  = [[JRTextField alloc] init];
        
        
        [self.contentView addSubview:_codeTxtField];
        [self.contentView addSubview:_nameTxtField];
        [self.contentView addSubview:_qcTxtField];
        [self.contentView addSubview:_numTxtField];
        [self.contentView addSubview:_unitTxtField];
        [self.contentView addSubview:_unitPriceTxtField];
        [self.contentView addSubview:_subTotalTxtField];
        [self.contentView addSubview:_storageNumTxtField];
        [self.contentView addSubview:_storageUnitTxtField];
        [self.contentView addSubview:_storageUnitPriceTxtField];
        [self.contentView addSubview:_storageSubTotalTxtField];
        
        self.backgroundColor = [UIColor clearColor];
        
        [super renderCellSubView:@"WHPurchaseOrder"];
        
        [self setValidatorTextField];
        
    }
    return self;
}

-(void)setValidatorTextField
{
    _numTxtField.inputValidator = [[NumericInputValidator alloc]init];
    _numTxtField.inputValidator.errorMsg = LOCALIZE_KEY(LOCALIZE_CONNECT_KEYS(@"WHPurchaseOrder", _numTxtField.attribute));
    
    _unitPriceTxtField.inputValidator = [[NumericInputValidator alloc]init];
    _unitPriceTxtField.inputValidator.errorMsg = LOCALIZE_KEY(LOCALIZE_CONNECT_KEYS(@"WHPurchaseOrder", _unitPriceTxtField.attribute));
    
    _storageNumTxtField.inputValidator = [[NumericInputValidator alloc]init];
    _storageNumTxtField.inputValidator.errorMsg = LOCALIZE_KEY(LOCALIZE_CONNECT_KEYS(@"WHPurchaseOrder", _storageNumTxtField.attribute));
    
    _storageUnitPriceTxtField.inputValidator = [[NumericInputValidator alloc]init];
    _storageUnitPriceTxtField.inputValidator.errorMsg = LOCALIZE_KEY(LOCALIZE_CONNECT_KEYS(@"WHPurchaseOrder", _storageUnitPriceTxtField.attribute));
    
    _numTxtField.delegate = self;
    _unitPriceTxtField.delegate = self;
    _storageNumTxtField.delegate = self;
    _storageUnitPriceTxtField.delegate = self;
    _subTotalTxtField.userInteractionEnabled = NO;
    _storageSubTotalTxtField.userInteractionEnabled = NO;
}

#pragma mark -
#pragma mark - UITextField Delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{

    JRTextField* valTxtFld = (JRTextField*)textField;
    if (valTxtFld.inputValidator && ![valTxtFld textFieldValidate]) {
        valTxtFld.text = @"";
         return;
    }

    
    if (textField == _unitPriceTxtField) {
        if (isEmptyString(_numTxtField.text)&&isEmptyString(_unitPriceTxtField.text)) {
            return;
        }
        _subTotalTxtField.text = [AppMathUtility calculateMultiply:_numTxtField.text,_unitPriceTxtField.text,nil];
    }
    
    if (textField == _storageUnitPriceTxtField) {
        if (isEmptyString(_storageNumTxtField.text)&&isEmptyString(_storageUnitPriceTxtField.text)) {
            return;
        }
       _storageSubTotalTxtField.text= [AppMathUtility calculateMultiply:_storageNumTxtField.text,_storageUnitPriceTxtField.text,nil];
        
        if (self.didEndEditNewCellAction) self.didEndEditNewCellAction(self);
    }
    
    
}


@end
