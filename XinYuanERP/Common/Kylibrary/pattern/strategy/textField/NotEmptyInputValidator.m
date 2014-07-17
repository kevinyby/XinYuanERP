//
//  NotEmptyInputValidator.m
//  XinYuanERP
//
//  Created by Xinyuan4 on 13-12-7.
//  Copyright (c) 2013年 Xinyuan4. All rights reserved.
//

#import "NotEmptyInputValidator.h"
#import "AppInterface.h"

@implementation NotEmptyInputValidator

- (BOOL)validateInput:(UITextField*)input
{
    NSString* string = input.text;
    if (string == nil || string == NULL) {
        return NO;
    }
    if ([string isKindOfClass:[NSNull class]]) {
        return NO;
    }
    if ([[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length]==0) {
        return NO;
    }
    return YES;
}


- (void)setErrorMsg:(NSString *)errorMsg
{
   
    errorMsg = [errorMsg stringByReplacingOccurrencesOfString:@"：" withString:@""];
    NSString* localizeErrorMsg = LOCALIZE_MESSAGE_FORMAT(MESSAGE_ValueCannotEmpty, errorMsg);
    super.errorMsg = localizeErrorMsg;

}



@end
