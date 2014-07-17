//
//  KeyBoardAnimation.h
//  XinYuanERP
//
//  Created by Xinyuan4 on 13-12-12.
//  Copyright (c) 2013年 Xinyuan4. All rights reserved.
//

#import <Foundation/Foundation.h>

#define KeyBoardHeight  (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? 162:352)

@interface KeyBoardAnimation : NSObject

+ (void)animationUp:(float)retainFloat inView:(UIView *)view;

+ (void)animationDown:(float)retainFloat inView:(UIView *)view;

@end
