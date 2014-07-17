//
//  TextBubbleView.m
//  XinYuanERP
//
//  Created by Xinyuan4 on 14-1-19.
//  Copyright (c) 2014年 Xinyuan4. All rights reserved.
//

#import "TextBubbleView.h"

#define ChangeHeight 10

#define TextOriginX  10
#define TextOriginY  10

#define TextSizeWidth  20
#define TextSizeHeight 20

@implementation TextBubbleView

- (id)initWithFrame:(CGRect)frame bubbleDirection:(CGBubbleViewDirection)dir
{
    self = [super initWithFrame:frame bubbleDirection:dir];
    if (self) {
        [self getTextView:frame];
    }
    return self;
}

-(void)getTextView:(CGRect)frame
{
    
    float x = TextOriginX;
    float y = TextOriginY;
    float width = frame.size.width - TextSizeWidth;
    float height = frame.size.height - TextSizeHeight;
    
    switch (self.direction) {
        case CGBubbleViewUp:
        {
            y = TextOriginY + ChangeHeight;
            height = height - ChangeHeight;
            break;
        }
        case CGBubbleViewDown:
        {
           height = height - ChangeHeight;
           break;
        }
        case CGBubbleViewLeft:
        {
            x = TextOriginX + ChangeHeight;
            width = width - ChangeHeight;
            break;
        }
        case CGBubbleViewRight:
        {
             width = width - ChangeHeight;
             break;
        }
        default:
            break;
    }
    
    CGRect textFrame = CGRectMake(x, y, width, height);
    
    _textView = [[UITextView alloc]initWithFrame:textFrame];
     self.textView.backgroundColor = [UIColor clearColor];
    [self addSubview: self.textView];
    
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
}


@end
