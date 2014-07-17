//
//  UILabel+UILabelAdditions.m
//  XinYuanERP
//
//  Copyright (c) 2013年 Xinyuan4. All rights reserved.
//

#import "UILabel+UILabelAdditions.h"
#import "UIView+UIViewAdditions.h"

@implementation UILabel (UILabelAdditions)
-(id)initFrame:(CGRect)frame
		  font:(CGFloat)aFont
	 textColor:(UIColor*)aColor
hightTextColor:(UIColor*)aHightTextColor
	 alignment:(UITextAlignment)aAlignment
		  text:(NSString*)aText
  resizeHeight:(BOOL)isResizeHeight{
	
	if (self=[self initWithFrame:frame]) {
		
		self.font = [UIFont systemFontOfSize:aFont];
		self.textColor = aColor;
		self.backgroundColor = [UIColor clearColor];
		self.highlightedTextColor = aHightTextColor;
		self.textAlignment = aAlignment;
		self.text = aText;
		
		if (isResizeHeight) {
			//**** 动态设定高度 ****
			[self setNumberOfLines:0];
			CGSize maxSize=self.frame.size;
			maxSize.height=100000;
			CGSize autoResize = [self.text sizeWithFont: self.font
									  constrainedToSize: maxSize
										  lineBreakMode: NSLineBreakByWordWrapping];
			if(autoResize.height>self.frame.size.height){
				[self setFrame:CGRectMake(frame.origin.x, frame.origin.y,
										  frame.size.width, (int)autoResize.height)];
			}
		}
		
	}
	
	
	return self;
}


-(id)initWithfontName:(NSString*)aFontName
             fontSize:(CGFloat)aFontSize
            textColor:(UIColor*)aColor
       hightTextColor:(UIColor*)aHightTextColor
            alignment:(UITextAlignment)aAlignment
                 text:(NSString*)aText{
	
	if (self=[self init]) {
		
		self.font = [UIFont fontWithName:aFontName size:aFontSize];
		self.textColor = aColor;
		self.backgroundColor = [UIColor clearColor];
		self.highlightedTextColor = aHightTextColor;
		self.textAlignment = aAlignment;
		self.text = aText;
		
	}
	
	
	return self;
}

-(void)resizeHeight{
	//**** 动态设定高度 ****
	[self setNumberOfLines:0];
	CGSize maxSize=self.frame.size;
	maxSize.height=100000;
	CGSize autoResize = [self.text sizeWithFont: self.font
							  constrainedToSize: maxSize
								  lineBreakMode: NSLineBreakByWordWrapping];
	if(autoResize.height>self.height){
		[self setHeight:autoResize.height];
	}
}

-(void)resizeWidth{
	
    CGSize titleSize = [self.text sizeWithFont:self.font
                             constrainedToSize:CGSizeMake(MAXFLOAT, self.frame.size.height)];
    [self setWidth:titleSize.width];
    
    
}


@end
