//
//  UIApplication+WindowOverlay.m
//  XinYuanERP
//
//  Copyright (c) 2013年 Xinyuan4. All rights reserved.
//
#import "UIApplication+WindowOverlay.h"

@implementation UIApplication (WindowOverlay)

-(UIView *)baseWindowView{
    if (self.keyWindow.subviews.count > 0){
        return [self.keyWindow.subviews objectAtIndex:0];
    }
    return nil;
}

-(void)addWindowOverlay:(UIView *)view{
    [self.baseWindowView addSubview:view];
}

@end
