
#import <UIKit/UIKit.h>

@interface UILabel (UILabelAdditions)

-(id)initFrame:(CGRect)frame
		  font:(CGFloat)aFont
	 textColor:(UIColor*)aColor
hightTextColor:(UIColor*)aHightTextColor
	 alignment:(UITextAlignment)aAlignment
		  text:(NSString*)aText
  resizeHeight:(BOOL)isResizeHeight;

-(id)initWithfontName:(NSString*)aFontName
             fontSize:(CGFloat)aFontSize
            textColor:(UIColor*)aColor
       hightTextColor:(UIColor*)aHightTextColor
            alignment:(UITextAlignment)aAlignment
                 text:(NSString*)aText;

-(void)resizeHeight;
-(void)resizeWidth;

@end
