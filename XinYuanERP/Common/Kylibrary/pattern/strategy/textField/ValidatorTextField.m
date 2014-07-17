//
//  ValidatorTextField.m
//  XinYuanERP
//
//  Created by Xinyuan4 on 13-12-20.
//  Copyright (c) 2013年 Xinyuan4. All rights reserved.
//

#import "ValidatorTextField.h"
#import "InputValidator.h"
#import "Utility.h"

@implementation ValidatorTextField

- (id)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

-(BOOL)textFieldValidate
{
    BOOL result = [self.inputValidator validateInput:self];
    if (!result) {
        [Utility showAlert:self.inputValidator.errorMsg];
    }
    return result;
}

@end
