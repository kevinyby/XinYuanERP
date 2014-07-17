//
//  KeyBoardAnimation.m
//  XinYuanERP
//
//  Created by Xinyuan4 on 13-12-12.
//  Copyright (c) 2013年 Xinyuan4. All rights reserved.
//

#import "KeyBoardAnimation.h"

#define KeyBoardDuration 0.3

@implementation KeyBoardAnimation

+ (void)animationUp:(float)retainFloat inView:(UIView *)view
{
    float baseFloat=0;
    if (retainFloat < KeyBoardHeight) {
        
        baseFloat = -(KeyBoardHeight-retainFloat);
    }
    [UIView beginAnimations:@"showKeyboardAnimation" context:nil];
    [UIView setAnimationDuration:KeyBoardDuration];
    view.frame=CGRectMake(0, view.frame.origin.y + baseFloat, view.bounds.size.width, view.bounds.size.height);
    [UIView commitAnimations];
}

+ (void)animationDown:(float)retainFloat inView:(UIView *)view
{
    float baseFloat=0;
    if (retainFloat < KeyBoardHeight) {
        
        baseFloat = (KeyBoardHeight-retainFloat);
    }
    [UIView beginAnimations:@"showKeyboardAnimation" context:nil];
    [UIView setAnimationDuration:KeyBoardDuration];
    view.frame=CGRectMake(0, view.frame.origin.y + baseFloat, view.bounds.size.width, view.bounds.size.height);
    [UIView commitAnimations];
}


@end
