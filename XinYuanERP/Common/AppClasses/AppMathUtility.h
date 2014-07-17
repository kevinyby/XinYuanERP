//
//  AppMathUtility.h
//  XinYuanERP
//
//  Created by Xinyuan4 on 14-6-27.
//  Copyright (c) 2014年 Xinyuan4. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AppMathUtility : NSObject

+ (NSString*)calculateMultiply:(id)multiplier,...;

+ (NSString*)calculateAddition:(id)addend,...;

+ (NSString*)calculateDivision:(NSString*)divisor dividend:(NSString*)dividend;

+ (NSString*)calculateSubtraction:(NSString*)subtrahend minuend:(NSString*)minuend;

+ (NSString*)calculateRate:(NSString*)divisor dividend:(NSString*)dividend;


@end
