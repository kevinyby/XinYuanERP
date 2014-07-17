//
//  UIFontDescriptor+Additional.h
//  Reader
//
//  Created by Xinyuan4 on 14-4-14.
//  Copyright (c) 2014年 Xinyuan4. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIFontDescriptor (Additional)

@property(nonatomic,strong)NSString* tkd_textStyle;

+ (UIFontDescriptor *)tkd_preferredFontDescriptorWithTextStyle:(NSString *)aTextStyle scale:(CGFloat)aScale;

@end
