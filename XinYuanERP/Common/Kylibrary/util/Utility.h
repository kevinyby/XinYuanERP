//
//  Utility.h
//  XinYuanERP
//
//  Created by Xinyuan4 on 13-9-23.
//  Copyright (c) 2013年 Xinyuan4. All rights reserved.
//

#import <Foundation/Foundation.h>


#define DATE_ZEROTIME_FORMAT @"yyyy-MM-dd 00:00:00"
#define DATE_MONTHDAY_FORMAT @"MM-dd HH:mm:ss"
#define DATE_NOTBAR_FORMAT   @"yyyyMMdd"

@interface Utility : NSObject

+ (void)showAlert:(NSString*)aText;

+ (NSDate *)dateFromString:(NSString *)dateString;

+ (NSDate *)dateAddOneDay:(NSDate *)nowDate;

+ (NSString *)stringFromDate:(NSDate *)date;

+ (NSString *)stringFromDestString:(NSString *)destString;

+ (NSString *)stringfrom:(NSString *)fromString format:(NSString *)fromFormat;

+ (NSString *)stringFromDate:(NSDate *)date withFormat:(NSString*)format;

+ (NSString*)stringfromDateFormatToZeroTime:(NSString*)sourceString;

+ (NSString*)stringfromZeroTimeToDateFormat:(NSString*)sourceString;

+ (NSString*)stringfromZeroTimeToNotBarDateFormat:(NSString*)sourceString;


+ (NSMutableArray*)arrCastMutArr:(NSArray*)arr;

+ (NSMutableDictionary*)dictionaryFromArray:(NSArray*)array;

+ (NSMutableArray*)fliterNullArray:(NSArray*)array;

+ (NSMutableDictionary*) changeKeys: (NSDictionary*)dictionary exceptkeys:(NSArray*)excepts tails:(NSArray*)tails;
// 判断只能是英文或数字
+ (BOOL) checkDigitAndAlphabetFormat:(NSString*)string;

// 根据key来分割
+ (NSArray *)splitStr:(NSString *)srcString andKey:(NSString *)key;

// 判断只能为数字
+ (BOOL)checkNumFormat:(NSString*)iTest;

// 判读字符串为空
+ (BOOL)isBlankString:(NSString *)string;

+ (void)parent:(UIView*)parentView add:(UIView *)subView rect:(CGRect)subRect;


+ (NSMutableArray*)arrayGetSubDictionary:(NSArray*)objs keys:(NSArray*)kys;

+ (NSMutableArray*)arraySetSubDictionary:(NSArray*)objs keys:(NSArray*)kys;

+ (NSMutableDictionary*)jsonfliterNmuber:(NSDictionary*)dic;

+ (NSString*)criterialDateToNextDate: (NSDate*)date;




@end
