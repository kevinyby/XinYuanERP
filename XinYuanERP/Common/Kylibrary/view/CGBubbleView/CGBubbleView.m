//
//  CGBubbleView.m
//  XinYuanERP
//
//  Created by Xinyuan4 on 14-1-19.
//  Copyright (c) 2014年 Xinyuan4. All rights reserved.
//

#import "CGBubbleView.h"
#import "CategoryAdditions.h"

#define Arror_height 10

@implementation CGBubbleView

- (id)initWithFrame:(CGRect)frame bubbleDirection:(CGBubbleViewDirection)dir
{
    self = [super initWithFrame:frame];
    if (self) {
        self.opaque = NO;
        self.direction = dir;
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    
    CGFloat radius = 10.0;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGFloat minx = CGRectGetMinX(rect), midx = CGRectGetMidX(rect), maxx = CGRectGetMaxX(rect);
    CGFloat miny = CGRectGetMinY(rect), midy = CGRectGetMidY(rect), maxy = CGRectGetMaxY(rect);
    
    switch (self.direction) {
        case CGBubbleViewUp:
        {
            miny = miny+Arror_height;
            CGContextMoveToPoint(context, midx-Arror_height, miny);
            CGContextAddLineToPoint(context,midx, miny-Arror_height);
            CGContextAddLineToPoint(context,midx+Arror_height, miny);
            
            CGContextAddArcToPoint(context, maxx, miny, maxx, maxy, radius);
            CGContextAddArcToPoint(context, maxx, maxy, minx, maxy, radius);
            CGContextAddArcToPoint(context, minx, maxy, minx, miny, radius);
            CGContextAddArcToPoint(context, minx, miny, midx, miny, radius);
            CGContextClosePath(context);
          
            break;
        }
        case CGBubbleViewDown:
        {
            maxy = maxy-Arror_height;
            CGContextMoveToPoint(context, midx+Arror_height, maxy);
            CGContextAddLineToPoint(context,midx, maxy+Arror_height);
            CGContextAddLineToPoint(context,midx-Arror_height, maxy);
            
            CGContextAddArcToPoint(context, minx, maxy, minx, miny, radius);
            CGContextAddArcToPoint(context, minx, miny, maxx, miny, radius);
            CGContextAddArcToPoint(context, maxx, miny, maxx, maxy, radius);
            CGContextAddArcToPoint(context, maxx, maxy, midx, maxy, radius);
            CGContextClosePath(context);
            
            break;

        }
        case CGBubbleViewLeft:
        {
            minx = minx+Arror_height;
            CGContextMoveToPoint(context, minx, midy + Arror_height);
            CGContextAddLineToPoint(context,minx-Arror_height, midy);
            CGContextAddLineToPoint(context,minx, midy-Arror_height);
            
            CGContextAddArcToPoint(context, minx, miny, maxx, miny, radius);
            CGContextAddArcToPoint(context, maxx, miny, maxx, maxy, radius);
            CGContextAddArcToPoint(context, maxx, maxy, minx, maxy, radius);
            CGContextAddArcToPoint(context, minx, maxy, minx, midy, radius);
            CGContextClosePath(context);
            break;

        }
        case CGBubbleViewRight:
        {
            
            maxx = maxx - Arror_height;
            CGContextMoveToPoint(context, maxx, midy - Arror_height);
            CGContextAddLineToPoint(context,maxx+Arror_height, midy);
            CGContextAddLineToPoint(context,maxx, midy+Arror_height);
            
            CGContextAddArcToPoint(context, maxx, maxy, minx, maxy, radius);
            CGContextAddArcToPoint(context, minx, maxy, minx, miny, radius);
            CGContextAddArcToPoint(context, minx, miny, maxx, miny, radius);
            CGContextAddArcToPoint(context, maxx, miny, maxx, midy, radius);
            CGContextClosePath(context);
            
          
            break;
        }
    }
    
    CGContextSetFillColorWithColor(context, [UIColor lightGrayColor].CGColor);
    CGContextFillPath(context);
    
}


@end
