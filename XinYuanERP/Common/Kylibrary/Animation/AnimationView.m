//
//  AnimationView.m
//  XinYuanERP
//
//  Created by Xinyuan4 on 14-3-25.
//  Copyright (c) 2014年 Xinyuan4. All rights reserved.
//

#import "AnimationView.h"
#import "AppInterface.h"

#define ANIMATION_TIME 0.5f

@implementation AnimationView

static NSMutableArray* views = nil;


+ (void)presentAnimationView:(UIView *)viewToPresent completion:(void (^)(void))completion {
    
    
    UIControl* overlayView = [[UIControl alloc] initWithFrame:[UIScreen mainScreen].bounds];
    CGRect newRect = overlayView.frame;
    newRect.origin.x = overlayView.frame.origin.y;
    newRect.origin.y = overlayView.frame.origin.x;
    newRect.size.width = overlayView.frame.size.height;
    newRect.size.height = overlayView.frame.size.width;
    overlayView.frame = newRect;
    
    [overlayView addTarget:self
                    action:@selector(dismissAnimationView)
          forControlEvents:UIControlEventTouchUpInside];
    
    CGRect finalFrame = viewToPresent.frame;
    finalFrame.origin.x = (newRect.size.width - finalFrame.size.width)/2;
    finalFrame.origin.y = (newRect.size.height - finalFrame.size.height)/2;
    
    if (views) {
        [views removeAllObjects];
        views =nil;
    }
    views = [NSMutableArray array];
    [views addObject: overlayView];
    [views addObject:viewToPresent];
    
    
    //        UIView* window = [UIApplication sharedApplication].baseWindowView;//when use ActionSheet , the top view of the window will be nil;
    UIView* rootView = VIEW.navigator.view;
    [rootView addSubview:overlayView];
    
    CGRect initialFrame = CGRectMake(finalFrame.origin.x, newRect.size.height + viewToPresent.frame.size.height/2, finalFrame.size.width, finalFrame.size.height);
    viewToPresent.frame = initialFrame;
    [overlayView addSubview: viewToPresent];
    
    
    overlayView.backgroundColor = [UIColor clearColor];
    [UIView animateWithDuration:ANIMATION_TIME delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        overlayView.backgroundColor = [UIColor colorWithRed:0.16 green:0.17 blue:0.21 alpha:0.5];
        viewToPresent.frame = finalFrame;
        
    } completion:^(BOOL finished) {
        
        [completion invoke];
    }];
    
    
}

+ (void)dismissAnimationView{
    
    UIControl* popOverlayView = [views firstObject];
    UIView* popView = [views lastObject];
    
    CGRect initialFrame = popView.frame;
    [UIView animateWithDuration:ANIMATION_TIME delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        popView.frame = CGRectMake(initialFrame.origin.x, popOverlayView.frame.size.height + initialFrame.size.height/2, initialFrame.size.width, initialFrame.size.height);
        
        popOverlayView.alpha = 0.0f;
    } completion:^(BOOL finished) {
        
        [popView removeFromSuperview];
        [popOverlayView removeFromSuperview];
        
    }];
    
}



@end
