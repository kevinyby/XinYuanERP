//
//  AnimationView.h
//  XinYuanERP
//
//  Created by Xinyuan4 on 14-3-25.
//  Copyright (c) 2014年 Xinyuan4. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AnimationView : NSObject

+ (void)presentAnimationView:(UIView *)viewToPresent completion:(void (^)(void))completion;
+ (void)dismissAnimationView;

@end
