//
//  Utility.m
//  XinYuanERP
//
//  Created by Xinyuan4 on 13-9-23.
//  Copyright (c) 2013年 Xinyuan4. All rights reserved.
//

#import "Utility.h"
#import "AppInterface.h"

#define NUMBERS @"0123456789\n"

@implementation Utility

+ (void)showAlert:(NSString*)aText
{
	[UIAlertView alertViewWithTitle:aText message:nil cancelButtonTitle:LOCALIZE_KEY(@"OK")];
}

+ (NSDate *)dateFromString:(NSString *)dateString{
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat: DATE_PATTERN];
    
    NSDate *destDate= [dateFormatter dateFromString:dateString];
   
    return destDate;
    
}


+ (NSString *)stringFromDate:(NSDate *)date{
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat:DATE_TIME_PATTERN];
    
    NSString *destDateString = [dateFormatter stringFromDate:date];
    
    return destDateString;
}

+ (NSString *)stringFromDate:(NSDate *)date withFormat:(NSString*)format
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat:format];
    
    NSString *destDateString = [dateFormatter stringFromDate:date];
    
    return destDateString;
}

+(NSString*)stringFromDestString:(NSString *)destString{
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat:DATE_TIME_PATTERN];
    
    NSDate *destDate= [dateFormatter dateFromString:destString];
    
    [dateFormatter setDateFormat: DATE_PATTERN];
    
    NSString *destDateString = [dateFormatter stringFromDate:destDate];
    
    return destDateString;
}


+ (NSString*)stringfromDateFormatToZeroTime:(NSString*)sourceString
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:DATE_PATTERN];
    NSDate *destDate = [dateFormatter dateFromString:sourceString];
    [dateFormatter setDateFormat: DATE_ZEROTIME_FORMAT];
    NSString *destDateString = [dateFormatter stringFromDate:destDate];
    return destDateString;
}

+ (NSString*)stringfromZeroTimeToDateFormat:(NSString*)sourceString
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:DATE_ZEROTIME_FORMAT];
    NSDate *destDate = [dateFormatter dateFromString:sourceString];
    [dateFormatter setDateFormat: DATE_PATTERN];
    NSString *destDateString = [dateFormatter stringFromDate:destDate];
    return destDateString;
}

+ (NSString*)stringfromZeroTimeToNotBarDateFormat:(NSString*)sourceString
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:DATE_ZEROTIME_FORMAT];
    NSDate *destDate = [dateFormatter dateFromString:sourceString];
    [dateFormatter setDateFormat: DATE_NOTBAR_FORMAT];
    NSString *destDateString = [dateFormatter stringFromDate:destDate];
    return destDateString;
}

+(NSString*)stringfrom:(NSString *)fromString format:(NSString *)fromFormat
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat:DATE_TIME_PATTERN];
    
    NSDate *destDate= [dateFormatter dateFromString:fromString];
    
    [dateFormatter setDateFormat: fromFormat];
    
    NSString *destDateString = [dateFormatter stringFromDate:destDate];
    
    return destDateString;
}


+ (NSDate *)dateAddOneDay:(NSDate *)nowDate
{
    NSTimeInterval secondsPerDay = 24 * 60 * 60;
    NSDate *today = [[NSDate alloc] init];
    NSDate *tomorrow = [today dateByAddingTimeInterval: secondsPerDay];
    return tomorrow;
}

//判读只能是英文或数字
+ (BOOL) checkDigitAndAlphabetFormat:(NSString*)string
{
	int charLength = [string length];
	int byteLength = [string lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
	if (charLength == byteLength)
	{
		NSString* minStr = @"a";
		NSString* maxStr = @"z";
		NSString* digitStr = @"0123456789";
		for (int i = 0; i < [string length]; i++) {
			NSString* tmp = [string substringWithRange:NSMakeRange(i, 1)];
			NSRange range = [digitStr rangeOfString:tmp];
			if (range.location == NSNotFound) {
				if ([tmp caseInsensitiveCompare:minStr] == NSOrderedAscending ||
					[tmp caseInsensitiveCompare:maxStr] == NSOrderedDescending) {//如果小于a,大于z
					return NO;
				}
			}
		}
		
		return YES;
	}
	else
	{//不允许汉字
		return NO;
	}
}


+(BOOL)checkNumFormat:(NSString*)iTest
{
    NSCharacterSet *cs = [[NSCharacterSet characterSetWithCharactersInString:NUMBERS] invertedSet];
    NSString *filtered = [[iTest componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
    BOOL basicTest = [iTest isEqualToString:filtered];
    if (basicTest) {
        return YES;
    }
    return NO;
}




+ (NSArray *) splitStr:(NSString *)srcString andKey:(NSString *)key {
	if (nil == srcString || [srcString length] == 0) {
		return nil;
	}
	if ([[srcString substringFromIndex:[srcString length]-1] isEqualToString:key]) {
		NSString *destString = [srcString stringByAppendingString:@" "];
		return [destString componentsSeparatedByString:key];
	}else {
		return [srcString componentsSeparatedByString:key];
	}
	
}

+(NSMutableArray*)arrCastMutArr:(NSArray*)arr
{
    NSMutableArray* mutArr = [[NSMutableArray alloc]init];
    for (int i = 0; i<[arr count]; i++) {
        [mutArr addObject:[arr objectAtIndex:i]];
    }
    return mutArr;
}

+ (NSMutableDictionary*)dictionaryFromArray:(NSArray*)array
{
    NSMutableDictionary* dictionary = [[NSMutableDictionary alloc]init];
    for (int i = 0; i<[array count]; i++) {
        if (i%2 == 0) {
            NSString* val = [array objectAtIndex:i];
            i++;
            NSString* key = [array objectAtIndex:i];
            [dictionary setObject:val forKey:key];
        }
    }
    return dictionary;
}

+ (BOOL) isBlankString:(NSString *)string {
    if (string == nil || string == NULL) {
        return YES;
    }
    if ([string isKindOfClass:[NSNull class]]) {
        return YES;
    }
    if ([[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length]==0) {
        return YES;
    }
    return NO;
}

+ (NSMutableArray*)fliterNullArray:(NSArray*)array{
    NSMutableArray* mutArray = [NSMutableArray array];
    for (int i = 0; i<[array  count]; i++) {
        NSString* val = [array objectAtIndex:i];
        if (isEmptyString(val)) {
            val = @"";
        }
        [mutArray addObject:val];
    }
    return mutArray;
}


+ (void)parent:(UIView*)parentView add:(UIView *)subView rect:(CGRect)subRect
{
    [FrameHelper setFrame:subRect view:subView];
    [parentView addSubview:subView];
    
}

+ (NSString*)criterialDateToNextDate: (NSDate*)date
{
    NSString* dateStr = [Utility stringFromDate:date withFormat:DATE_ZEROTIME_FORMAT];
    NSString* nextDateStr = [DateHelper stringFromDate:[DateHelper date: date addDay:1] pattern:DATE_ZEROTIME_FORMAT];
    NSString* factors = [NSString stringWithFormat:@"%@%@%@%@",CRITERIAL_BT,dateStr,CRITERIAL_BTAND,nextDateStr];
    return factors;
    
}

+ (NSMutableArray*)arraySetSubDictionary:(NSArray*)objs keys:(NSArray*)kys
{
    NSMutableArray* mutArr = [[NSMutableArray alloc]init];
    for (int i = 0; i<[objs count]; i++) {
        NSArray* arr = [objs objectAtIndex:i];
        NSMutableDictionary* mutDic = [NSMutableDictionary dictionary];
        for (int i = 0; i<[arr count]; i++) {
            if (!isEmptyString([arr objectAtIndex:i])) {
                [mutDic setObject:[arr objectAtIndex:i] forKey:[kys objectAtIndex:i]];
            }
        }
        [mutArr addObject:mutDic];
    }
    return mutArr;
}


+ (NSMutableArray*)arrayGetSubDictionary:(NSArray*)objs keys:(NSArray*)kys
{
    NSMutableArray* mutArray = [[NSMutableArray alloc]init];
    for (int i = 0; i<[objs count]; i++) {
        NSMutableArray* subMutArray = [[NSMutableArray alloc]init];
        NSDictionary* dic = [objs objectAtIndex:i];
        dic = [Utility jsonfliterNmuber:dic];
        for (int j = 0; j<[kys count]; j++) {
            
            if (!isEmptyString([dic objectForKey:[kys objectAtIndex:j]])) {
                [subMutArray addObject:[dic objectForKey:[kys objectAtIndex:j]]];
            }
            
        }
        [mutArray addObject:subMutArray];
    }
    
    return mutArray;
}

+ (NSMutableDictionary*)jsonfliterNmuber:(NSDictionary*)dic
{
    NSMutableDictionary* baseDic = [NSMutableDictionary dictionary];
    for (int j = 0; j< [[dic allKeys] count]; j++) {
        id val = [dic objectForKey:[[dic allKeys]objectAtIndex:j]];
        if ([val isKindOfClass:[NSNumber class]]) {
            [baseDic setObject:[val stringValue]forKey:[[dic allKeys]objectAtIndex:j]];
        }else{
            [baseDic setObject:val forKey:[[dic allKeys]objectAtIndex:j]];
        }
        
    }
    return baseDic;
}

+ (NSMutableDictionary*) changeKeys: (NSDictionary*)dictionary exceptkeys:(NSArray*)excepts tails:(NSArray*)tails
{
    NSMutableDictionary* result = [NSMutableDictionary dictionary];
    for (NSString* key in dictionary) {
        id value = [dictionary objectForKey: key];
        if (![excepts containsObject: key]) {
            for (NSString* tail in tails) {
                NSString* newKey =  [key stringByAppendingString:tail];
                [result setObject: value forKey: newKey];
            }
        }else{
            [result setObject: value forKey: key];
        }
    }
    return result;
}


@end
