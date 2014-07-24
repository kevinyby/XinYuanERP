//
//  MagnifierView.m
//  Photolib
//
//  Created by bravo on 14-7-16.
//  Copyright (c) 2014年 bravo. All rights reserved.
//

#import "MagnifierView.h"

@implementation MagnifierView
@synthesize viewToMagnify;
@dynamic touchPoint;

- (id)initWithFrame:(CGRect)frame
{
    return [self initWithFrame:frame radius:118];
}

-(id) initWithFrame:(CGRect)frame radius:(int)r{
    int radius = r;
    if ((self = [super initWithFrame:CGRectMake(0,0,radius, radius)])){
        self.layer.cornerRadius = radius / 2;
        self.layer.masksToBounds = YES;
    }
    return self;
}

-(void) setTouchPoint:(CGPoint)pt{
    touchPoint = pt;
    self.center = CGPointMake(pt.x, pt.y-66);
    NSLog(@"touch!");
}

-(CGPoint) getTouchPoint{
    return touchPoint;
}


- (void)drawRect:(CGRect)rect
{
    self.backgroundColor = [UIColor redColor];
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGRect bounds = self.bounds;
    CGImageRef mask = [UIImage imageNamed:@"loupe-mask@2x.png"].CGImage;
    UIImage *glass = [UIImage imageNamed:@"loupe-hi@2x.png"];
    
    CGContextSaveGState(context);
    CGContextClipToMask(context, bounds, mask);
    CGContextFillRect(context, bounds);
    CGContextScaleCTM(context, 1.2, 1.2);
    
    //draw subject view here
    CGContextTranslateCTM(context, 1*(self.frame.size.width*0.5), 1*(self.frame.size.height*0.5));
    CGContextTranslateCTM(context, -1*(touchPoint.x), -1*(touchPoint.y));
    [self.viewToMagnify.layer renderInContext:context];
    
    CGContextRestoreGState(context);
    [glass drawInRect:bounds];
}

@end
