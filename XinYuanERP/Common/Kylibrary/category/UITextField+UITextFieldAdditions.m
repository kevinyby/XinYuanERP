//
//  UITextField+UITextFieldAdditions.m
//  XinYuanERP
//
//  Copyright (c) 2013年 Xinyuan4. All rights reserved.
//

#import "UITextField+UITextFieldAdditions.h"
#import "FrameTranslater.h"

@implementation UITextField (UITextFieldAdditions)

-(id)initWithFontName:(NSString*)aFontName
             fontSize:(CGFloat)aFont
          borderStyle:(UITextBorderStyle)aStytle
    verticalAlignment:(UIControlContentVerticalAlignment)aAlignment
            translate:(BOOL)isTranslate
        adjustToWidth:(BOOL)isAdjust
{
    
    if (self=[self init]) {
        self.backgroundColor = [UIColor clearColor];
        self.borderStyle = aStytle;
        self.contentVerticalAlignment = aAlignment;
        self.adjustsFontSizeToFitWidth = isAdjust;
        self.font = [UIFont fontWithName:aFontName size:isTranslate?[FrameTranslater convertFontSize:aFont]:aFont];
        
    }
    return self;
}



@end
