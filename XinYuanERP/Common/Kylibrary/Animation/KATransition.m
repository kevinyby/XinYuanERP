//
//  KATransition.m
//  XinYuanERP
//
//  Created by Xinyuan4 on 13-12-12.
//  Copyright (c) 2013年 Xinyuan4. All rights reserved.
//

#import "KATransition.h"

#define KATransitionDuration 0.7

@implementation KATransition

- (id)initWithView:(UIView*)aView{
    self = [super init];
    if (self) {
		self.transitionView = aView;
	}
	return self;
}

- (void)runTransition:(UIViewAnimationTransition)aKATransition{
    
    [UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:KATransitionDuration];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationRepeatAutoreverses:NO];
    [UIView setAnimationTransition:aKATransition forView:self.transitionView cache:YES];
	[UIView commitAnimations];
}

+ (void)runTransition:(UIViewAnimationTransition)aKATransition forView:(UIView*)aView
{
    [UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:KATransitionDuration];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationRepeatAutoreverses:NO];
    [UIView setAnimationTransition:aKATransition forView:aView cache:YES];
	[UIView commitAnimations];
}

@end
