//
//  UIFontDescriptor+Additional.m
//  Reader
//
//  Created by Xinyuan4 on 14-4-14.
//  Copyright (c) 2014年 Xinyuan4. All rights reserved.
//

#import "UIFontDescriptor+Additional.h"

@implementation UIFontDescriptor (Additional)

-(NSString *)tkd_textStyle
{
    return [self objectForKey:@"NSCTFontUIUsageAttribute"];
}

-(void)setTkd_textStyle:(NSString *)tkd_textStyle
{
    tkd_textStyle = tkd_textStyle;
}

+ (UIFontDescriptor *)tkd_preferredFontDescriptorWithTextStyle:(NSString *)aTextStyle scale:(CGFloat)aScale
{
    UIFontDescriptor *newBaseDescriptor = [self preferredFontDescriptorWithTextStyle:aTextStyle];
    
    return [newBaseDescriptor fontDescriptorWithSize:lrint([newBaseDescriptor pointSize] * aScale)];
}

@end
