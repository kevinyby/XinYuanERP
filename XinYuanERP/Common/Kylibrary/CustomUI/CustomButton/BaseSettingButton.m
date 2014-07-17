//
//  BaseSettingButton.m
//  XinYuanERP
//
//  Created by Xinyuan4 on 13-12-30.
//  Copyright (c) 2013年 Xinyuan4. All rights reserved.
//

#import "BaseSettingButton.h"

@implementation BaseSettingButton

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
    self = [super init];
    if (self) {
        
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
