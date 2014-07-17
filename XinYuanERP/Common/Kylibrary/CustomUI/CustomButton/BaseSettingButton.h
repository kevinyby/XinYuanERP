//
//  BaseSettingButton.h
//  XinYuanERP
//
//  Created by Xinyuan4 on 13-12-30.
//  Copyright (c) 2013年 Xinyuan4. All rights reserved.
//

#import "CustomButton.h"

@interface BaseSettingButton : CustomButton

@property(nonatomic,strong)NSString* tipMessage;

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

@end
