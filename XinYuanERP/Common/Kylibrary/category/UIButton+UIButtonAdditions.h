
#import <UIKit/UIKit.h>

@interface UIButton (UIButtonAdditions)

-(id)initBackgroundColor:(UIColor*)aBgColor
                   title:(NSString*)aTitle
              titleColor:(UIColor*)aColor
                  target:(id)aTarget
                  action:(SEL)aAction;

-(id)initBackgroundImage:(UIImage*)aImage
                   title:(NSString*)aTitle
                    font:(UIFont*)aFont
              titleColor:(UIColor*)aColor
               highColor:(UIColor*)aHighColor
                  target:(id)aTarget
                  action:(SEL)aAction;

-(id)initWithImage:(UIImage*)aImage
        focusImage:(UIImage*)aFocusImage
            target:(id)aTarget
            action:(SEL)aAction;


-(id)initWithBgImage:(UIImage*)aBGgImage
        bgFocusImage:(UIImage*)aBgFocusImage
		       image:(UIImage*)aImage
	      focusImage:(UIImage*)aFocusImage
		      target:(id)aTarget
		      action:(SEL)aAction;


-(id)initWithBgImage:(UIImage*)aBGgImage
        bgFocusImage:(UIImage*)aBgFocusImage
		       image:(UIImage*)aImage
	      focusImage:(UIImage*)aFocusImage
		       title:(NSString*)aText
		        font:(UIFont*)aFont
		       color:(UIColor*)aColor
	       highColor:(UIColor*)aHighColor
		      target:(id)aTarget
		      action:(SEL)aAction;

-(id)initBackgroundImage:(UIImage*)aImage
                   title:(NSString*)aTitle
                    font:(UIFont*)aFont
              titleColor:(UIColor*)aColor
               highColor:(UIColor*)aHighColor;

@end
