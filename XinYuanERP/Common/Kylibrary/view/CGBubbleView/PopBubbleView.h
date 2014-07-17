//
//  PopBubbleView.h
//  XinYuanERP
//
//  Created by Xinyuan4 on 14-6-18.
//  Copyright (c) 2014年 Xinyuan4. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PopBubbleView : NSObject

+ (void)popCustomBubbleView:(UIView*)view keys:(NSArray*)array selectedBlock:(void(^)(NSInteger selectedIndex, NSString* selectedValue))doneBlock;

+ (void)popTableBubbleView:(UIView*)view title:(NSString*)title dataSource:(NSArray*)source selectedBlock:(void(^)(NSInteger selectedIndex, NSString* selectedValue))doneBlock;


@end
