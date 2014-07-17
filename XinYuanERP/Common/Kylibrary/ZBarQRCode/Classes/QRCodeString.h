/*
  字符串转成二维码
 */
#import <Foundation/Foundation.h>

@interface QRCodeString : NSObject

+(UIImage*)QRCodeFromString:(NSString *)string sizeWidth:(int)width;

+(UIImage*)QRCodeFrom:(NSArray *)strings keys:(NSArray*)keys sizeWidth:(int)width;

@end
