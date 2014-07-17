//
//  OrderUtility.m
//  XinYuanERP
//
//  Copyright (c) 2014年 Xinyuan4. All rights reserved.
//

#import "OrderUtility.h"
#import "AppInterface.h"

@implementation OrderUtility

+ (float)localizeStrCompareCNStr:(NSString*)Ostring category:(NSString*)category fontSize:(CGFloat)size
{
    NSString* localizeString = LOCALIZE_KEY(Ostring);
    CGSize localizeStringSize = [localizeString sizeWithFont:[UIFont fontWithName:@"Arial" size:[FrameTranslater convertFontSize:size]]];
    
    NSString* localizeCNString = [CategoriesLocalizer getCategoriesLocalized:Ostring kind:nil category:category language:LANGUAGE_zh_CN];
//    NSString* localizeCNString = [CategoriesLocalizer getLocalized:Ostring category:category language:LANGUAGE_zh_CN];
    CGSize localizeCNStringSize = [localizeCNString sizeWithFont:[UIFont fontWithName:@"Arial" size:[FrameTranslater convertFontSize:size]]];
    
    float gap = 0;
    if (localizeStringSize.width>localizeCNStringSize.width) {
        gap = localizeStringSize.width - localizeCNStringSize.width;
    }
    return gap;
}

+ (NSString*)applyListTypeMediator:(NSString*)applyType
{
    if ([applyType isEqualToString:PROPERTY_CREATEUSER]) return levelApp1;
    else if ([applyType isEqualToString:levelApp1]) return levelApp2;
    else if ([applyType isEqualToString:levelApp2]) return levelApp3;
    else if ([applyType isEqualToString:levelApp3]) return levelApp4;
    else if ([applyType isEqualToString:BILL_CREATEUSER]) return levelApp1;
    return nil;
}

+ (NSData*)imageDataCompress:(UIImage*)image
{
   return [self imageTransformData:image compressSize:0.3];
}

+ (NSData*)imageTransformData:(UIImage*)image compressSize:(float)size
{
    UIImage* fixImage = [UIImage fixOrientation:image];
    NSData* imageData=UIImageJPEGRepresentation(fixImage, size);
    return imageData;
}


+ (void)tapGestureAdd:(UIView*)view inClass:(id)viewClass forAction:(SEL)classAction
{
    CGRect rect = view.frame;
    UIView* tapView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, rect.size.width, rect.size.height)];
    tapView.backgroundColor = [UIColor clearColor];
    [view addSubview:tapView];
    
    UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:viewClass action:classAction];
    [tapView addGestureRecognizer:tapGesture];
    
    tapView = nil;
    
}

+ (NSMutableArray*)localizeArray:(NSArray*)array withOrder:(NSString*)order
{
    NSMutableArray* localizeArray = [NSMutableArray array];
    for (int i = 0; i < [array count]; i++) {
        NSString* localizeString = LOCALIZE_KEY(LOCALIZE_CONNECT_KEYS(order, [array objectAtIndex:i]));
        [localizeArray addObject:localizeString];
    }
    return localizeArray;
}







@end
