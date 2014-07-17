
#import "QRCodeString.h"
#import "QRCodeGenerator.h"
#import "Utility.h"
#import "CategoriesLocalizer.h"
#import "FrameTranslater.h"

@implementation QRCodeString

+(UIImage*)QRCodeFromString:(NSString *)string sizeWidth:(int)width
{
    return [QRCodeGenerator qrImageForString:string imageSize:width];
}


+(UIImage*)QRCodeFrom:(NSArray *)strings keys:(NSArray*)keys sizeWidth:(int)width
{
    NSString* QRCodeStr = @"";
    for (int i = 0; i < strings.count; i++) {
        NSString* subStr = strings[i];
        if (subStr == nil || [subStr isEqualToString:@""]) {
            NSString* alertKey = keys[i];
            NSString* message = LOCALIZE_MESSAGE_FORMAT(@"CREATEQRCODE", LOCALIZE_KEY(alertKey));
            [Utility showAlert:message];
            return nil;
        }
        QRCodeStr = [QRCodeStr stringByAppendingFormat: @"\n%@", subStr];

    }
    return [QRCodeString QRCodeFromString:QRCodeStr sizeWidth:[FrameTranslater convertCanvasWidth:width]];
    
}


@end
