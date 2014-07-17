//
//  UIButton+UIButtonAdditions.m
//  XinYuanERP
//
//  Copyright (c) 2013年 Xinyuan4. All rights reserved.
//

#import "UIButton+UIButtonAdditions.h"

@implementation UIButton (UIButtonAdditions)

-(id)initBackgroundColor:(UIColor*)aBgColor
                   title:(NSString*)aTitle
              titleColor:(UIColor*)aColor
                  target:(id)aTarget
                  action:(SEL)aAction
{
    if (self=[self init]) {
		self.backgroundColor = aColor == nil ? [UIColor clearColor]:aBgColor;
        [self setTitle:aTitle forState:UIControlStateNormal];
        [self setTitleColor:aColor == nil ? [UIColor whiteColor]:aColor forState:UIControlStateNormal];
        [self setTitleColor:aColor == nil ? [UIColor whiteColor]:aColor forState:UIControlStateSelected];
        [self setTitleColor:aColor == nil ? [UIColor whiteColor]:aColor forState:UIControlStateSelected];
		[self addTarget:aTarget action:aAction forControlEvents:UIControlEventTouchUpInside];
        
	}
	return self;
}


-(id)initBackgroundImage:(UIImage*)aImage
                   title:(NSString*)aTitle
                    font:(UIFont*)aFont
              titleColor:(UIColor*)aColor
               highColor:(UIColor*)aHighColor
                  target:(id)aTarget
                  action:(SEL)aAction{
	
	if (self=[self init]) {
		self.backgroundColor = [UIColor clearColor];
		[self setBackgroundImage:aImage forState:UIControlStateNormal];
		[self setBackgroundImage:aImage forState:UIControlStateHighlighted];
		[self setBackgroundImage:aImage forState:UIControlStateSelected];
        [self setTitle:aTitle forState:UIControlStateNormal];
        [self.titleLabel setFont:aFont == nil ? [UIFont fontWithName:@"Arial" size:20]:aFont];
        [self setTitleColor:aColor forState:UIControlStateNormal];
        [self setTitleColor:aHighColor forState:UIControlStateSelected];
        [self setTitleColor:aHighColor forState:UIControlStateSelected];
		[self addTarget:aTarget action:aAction forControlEvents:UIControlEventTouchUpInside];
        
	}
	return self;
}


-(id)initBackgroundImage:(UIImage*)aImage
                   title:(NSString*)aTitle
                    font:(UIFont*)aFont
              titleColor:(UIColor*)aColor
               highColor:(UIColor*)aHighColor
{
    if (self=[self init]) {
		self.backgroundColor = [UIColor clearColor];
		[self setBackgroundImage:aImage forState:UIControlStateNormal];
		[self setBackgroundImage:aImage forState:UIControlStateHighlighted];
		[self setBackgroundImage:aImage forState:UIControlStateSelected];
        [self setTitle:aTitle forState:UIControlStateNormal];
        [self.titleLabel setFont:aFont == nil ? [UIFont fontWithName:@"Arial" size:20]:aFont];
        [self setTitleColor:aColor forState:UIControlStateNormal];
        [self setTitleColor:aHighColor forState:UIControlStateSelected];
        [self setTitleColor:aHighColor forState:UIControlStateSelected];
        
	}
	return self;

}

-(id)initWithImage:(UIImage*)aImage
        focusImage:(UIImage*)aFocusImage
            target:(id)aTarget
            action:(SEL)aAction{
	
	if (self=[self init]) {
		self.backgroundColor = [UIColor clearColor];
		[self setImage:aImage forState:UIControlStateNormal];
		[self setImage:aFocusImage forState:UIControlStateHighlighted];
		[self setImage:aFocusImage forState:UIControlStateSelected];
		[self addTarget:aTarget action:aAction forControlEvents:UIControlEventTouchUpInside];
	}
	return self;
}


-(id)initWithBgImage:(UIImage*)aBGgImage
        bgFocusImage:(UIImage*)aBgFocusImage
		       image:(UIImage*)aImage
	      focusImage:(UIImage*)aFocusImage
		      target:(id)aTarget
		      action:(SEL)aAction
{
	
	if (self=[self init]) {
		
		[self setBackgroundImage:aBGgImage forState:UIControlStateNormal];
		[self setBackgroundImage:aBgFocusImage forState:UIControlStateHighlighted];
		[self setBackgroundImage:aBgFocusImage forState:UIControlStateSelected];
		[self setImage:aImage forState:UIControlStateNormal];
		[self setImage:aFocusImage forState:UIControlStateHighlighted];
		[self setImage:aFocusImage forState:UIControlStateSelected];
		[self addTarget:aTarget action:aAction forControlEvents:UIControlEventTouchUpInside];
	}
	return self;
}



-(id)initWithBgImage:(UIImage*)aBGgImage
        bgFocusImage:(UIImage*)aBgFocusImage
		       image:(UIImage*)aImage
	      focusImage:(UIImage*)aFocusImage
		       title:(NSString*)aText
		        font:(UIFont*)aFont
		       color:(UIColor*)aColor
	       highColor:(UIColor*)aHighColor
		      target:(id)aTarget
		      action:(SEL)aAction
{
	
	if (self=[self init]) {
		
		[self setBackgroundImage:aBGgImage forState:UIControlStateNormal];
		[self setBackgroundImage:aBgFocusImage forState:UIControlStateHighlighted];
		[self setBackgroundImage:aBgFocusImage forState:UIControlStateSelected];
		[self setImage:aImage forState:UIControlStateNormal];
		[self setImage:aFocusImage forState:UIControlStateHighlighted];
		[self setImage:aFocusImage forState:UIControlStateSelected];
		[self setTitle:aText forState:UIControlStateNormal];
		[self.titleLabel setFont:aFont];
		[self setTitleColor:aColor forState:UIControlStateNormal];
		[self setTitleColor:aHighColor forState:UIControlStateHighlighted];
		[self setTitleColor:aHighColor forState:UIControlStateSelected];
		[self addTarget:aTarget action:aAction forControlEvents:UIControlEventTouchUpInside];
	}
	return self;
}


@end
