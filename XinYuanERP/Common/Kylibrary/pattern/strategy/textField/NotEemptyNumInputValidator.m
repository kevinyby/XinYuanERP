//
//  NotEemptyNumInputValidator.m
//  XinYuanERP
//
//  Created by Xinyuan4 on 13-12-30.
//  Copyright (c) 2013年 Xinyuan4. All rights reserved.
//

#import "NotEemptyNumInputValidator.h"
#import "AppInterface.h"



@implementation NotEemptyNumInputValidator

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
   
    NSString* iTest = input.text;
    NSScanner* scan = [NSScanner scannerWithString:iTest];
    float val;
    return[scan scanFloat:&val] && [scan isAtEnd];
    
//    NSCharacterSet *cs = [[NSCharacterSet characterSetWithCharactersInString:NUMBERS] invertedSet];
//    NSString *filtered = [[string componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
//    BOOL basicTest = [string isEqualToString:filtered];
//    if (basicTest) {
//        return YES;
//    }
//    return NO;
}


- (void)setErrorMsg:(NSString *)errorMsg
{
    errorMsg = [errorMsg stringByReplacingOccurrencesOfString:@"：" withString:@""];
    NSString* localizeErrorMsg = LOCALIZE_MESSAGE_FORMAT(MESSAGE_ValueNotEmptyAndBeNumber, errorMsg);
    super.errorMsg = localizeErrorMsg;
}




@end
