//
//  KATransition.h
//  XinYuanERP
//
//  Created by Xinyuan4 on 13-12-12.
//  Copyright (c) 2013年 Xinyuan4. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 typedef NS_ENUM(NSInteger, UIViewAnimationTransition) {
 UIViewAnimationTransitionNone,
 UIViewAnimationTransitionFlipFromLeft,
 UIViewAnimationTransitionFlipFromRight,
 UIViewAnimationTransitionCurlUp,
 UIViewAnimationTransitionCurlDown,
 };
 */

@interface KATransition : NSObject

@property(strong,nonatomic)UIView* transitionView;

- (id)initWithView:(UIView*)aView;

- (void)runTransition:(UIViewAnimationTransition)aKATransition;

+ (void)runTransition:(UIViewAnimationTransition)aKATransition forView:(UIView*)aView;

@end
