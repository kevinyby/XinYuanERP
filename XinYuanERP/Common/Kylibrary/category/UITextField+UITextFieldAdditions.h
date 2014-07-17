

#import <UIKit/UIKit.h>

@interface UITextField (UITextFieldAdditions)

-(id)initWithFontName:(NSString*)aFontName
             fontSize:(CGFloat)aFont
          borderStyle:(UITextBorderStyle)aStytle
    verticalAlignment:(UIControlContentVerticalAlignment)aAlignment
            translate:(BOOL)isTranslate
        adjustToWidth:(BOOL)isAdjust;

@end
