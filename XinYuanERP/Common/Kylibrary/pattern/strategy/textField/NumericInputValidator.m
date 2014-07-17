//
//  NumericInputValidator.m
//  XinYuanERP
//
//  Created by Xinyuan4 on 13-12-7.
//  Copyright (c) 2013年 Xinyuan4. All rights reserved.
//

#import "NumericInputValidator.h"
#import "AppInterface.h"

#define NUMBERS @"0123456789\n"

@implementation NumericInputValidator

- (BOOL)validateInput:(UITextField*)input
{
    NSString* iTest = input.text;
    NSScanner* scan = [NSScanner scannerWithString:iTest];
    float val;
    return[scan scanFloat:&val] && [scan isAtEnd];
//    NSCharacterSet *cs = [[NSCharacterSet characterSetWithCharactersInString:NUMBERS] invertedSet];
//    NSString *filtered = [[iTest componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
//    BOOL basicTest = [iTest isEqualToString:filtered];
//    if (basicTest) {
//        return YES;
//    }
//    return NO;
}

- (void)setErrorMsg:(NSString *)errorMsg
{
    errorMsg = [errorMsg stringByReplacingOccurrencesOfString:@"：" withString:@""];
    NSString* localizeErrorMsg = LOCALIZE_MESSAGE_FORMAT(MESSAGE_ValueOnlyBeNumber, errorMsg);
    super.errorMsg = localizeErrorMsg;
}

@end
