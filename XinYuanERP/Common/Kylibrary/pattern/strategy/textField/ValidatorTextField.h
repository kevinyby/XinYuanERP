//
//  ValidatorTextField.h
//  XinYuanERP
//
//  Created by Xinyuan4 on 13-12-20.
//  Copyright (c) 2013年 Xinyuan4. All rights reserved.
//

#import "CustomTextField.h"

#define NumericValidator     @"NumericInputValidator"
#define NotEmptyValidator    @"NotEmptyInputValidator"
#define NotEmptyNumValidator @"NotEemptyNumInputValidator"


@class InputValidator;
@interface ValidatorTextField : CustomTextField

@property(nonatomic,strong)InputValidator* inputValidator;
//@property(nonatomic,strong)NSString* errorMsg;

- (BOOL) textFieldValidate;

@end
