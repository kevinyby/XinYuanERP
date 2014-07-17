//
//  CustomLabel.m
//  XinYuanERP
//
//  Created by Xinyuan4 on 13-12-20.
//  Copyright (c) 2013年 Xinyuan4. All rights reserved.
//

#import "CustomLabel.h"
#import "FrameTranslater.h"
#import "UILabel+UILabelAdditions.h"
@implementation CustomLabel

- (id)initWithText:(NSString*)aText
{
    self = [super init];
    if (self) {
        self.font = [UIFont fontWithName:@"Arial" size:20];
		self.textColor = [UIColor blackColor];
		self.backgroundColor = [UIColor clearColor];
		self.highlightedTextColor = [UIColor blackColor];
		self.textAlignment = UITextAlignmentCenter;
		self.text = aText;
        [self resizeWidth];
    }
    return self;
}

- (id)initWithText:(NSString*)aText Font:(UIFont*)font Color:(UIColor*)textColor
{
    self = [super init];
    if (self) {
        self.font = font;
		self.textColor = textColor;
		self.highlightedTextColor = textColor;
		self.backgroundColor = [UIColor clearColor];
		self.textAlignment = UITextAlignmentCenter;
		self.text = aText;
        [self resizeWidth];
    }
    return self;
}

@end
