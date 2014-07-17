//
//  AppMathUtility.m
//  XinYuanERP
//
//  Created by Xinyuan4 on 14-6-27.
//  Copyright (c) 2014年 Xinyuan4. All rights reserved.
//

#import "AppMathUtility.h"

@implementation AppMathUtility

+ (NSString*)calculateMultiply:(id)multiplier,...
{
    float multiplyTotal = 1;
    va_list params;
    va_start(params, multiplier);
    id arg;
    if (multiplier) {
        id prev = multiplier;
        multiplyTotal = multiplyTotal*[prev floatValue];
        while ((arg=va_arg(params, id)))
        {
            if (arg) {
                multiplyTotal = multiplyTotal*[arg floatValue];
            }
        }
    }
    va_end(params);
    return [NSString stringWithFormat:@"%.2f",multiplyTotal];
}

+ (NSString*)calculateAddition:(id)addend,...
{
    float additionTotal = 0;
    va_list params;
    va_start(params, addend);
    id arg;
    if (addend) {
        id prev = addend;
        additionTotal = additionTotal+[prev floatValue];
        while ((arg=va_arg(params, id)))
        {
            if (arg) {
                additionTotal = additionTotal+[arg floatValue];
            }
        }
    }
    va_end(params);
    return [NSString stringWithFormat:@"%.2f",additionTotal];
}


+ (NSString*)calculateDivision:(NSString*)divisor dividend:(NSString*)dividend
{
    float divisorFloat = [divisor floatValue];
    float dividendFloat = [dividend floatValue];
    if (dividendFloat <= 0) return nil;
    return [NSString stringWithFormat:@"%.2f",divisorFloat/dividendFloat];
}

+ (NSString*)calculateSubtraction:(NSString*)subtrahend minuend:(NSString*)minuend
{
    float subtrahendFloat = [subtrahend floatValue];
    float minuendFloat = [minuend floatValue];
    return [[NSNumber numberWithFloat:(subtrahendFloat-minuendFloat)] stringValue];;
}

+ (NSString*)calculateRate:(NSString*)divisor dividend:(NSString*)dividend
{
    float divisorFloat = [divisor floatValue];
    float dividendFloat = [dividend floatValue];
    return [NSString stringWithFormat:@"%.2f%@",divisorFloat/dividendFloat*100,@"%"];
}

@end
