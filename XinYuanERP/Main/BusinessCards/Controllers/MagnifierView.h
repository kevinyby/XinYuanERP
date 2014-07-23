//
//  MagnifierView.h
//  Photolib
//
//  Created by bravo on 14-7-16.
//  Copyright (c) 2014年 bravo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MagnifierView : UIView{
    UIView* viewToMagnify;
    CGPoint touchPoint;
}

@property (nonatomic, retain) UIView* viewToMagnify;
@property (assign) CGPoint touchPoint;

@end
