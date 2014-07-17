//
//  CGBubbleView.h
//  XinYuanERP
//
//  Created by Xinyuan4 on 14-1-19.
//  Copyright (c) 2014年 Xinyuan4. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
	CGBubbleViewUp,
	CGBubbleViewDown,
	CGBubbleViewRight,
	CGBubbleViewLeft
}CGBubbleViewDirection;

@interface CGBubbleView : UIView

@property (nonatomic, assign) CGBubbleViewDirection	direction;

- (id)initWithFrame:(CGRect)frame bubbleDirection:(CGBubbleViewDirection)dir;


@end
