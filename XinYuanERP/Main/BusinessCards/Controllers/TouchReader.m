//
//  TouchReader.m
//  Photolib
//
//  Created by bravo on 14-7-16.
//  Copyright (c) 2014年 bravo. All rights reserved.
//

#import "TouchReader.h"

@implementation TouchReader
@synthesize touchTimer;

-(void) touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event{
    self.touchTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(addLoop) userInfo:nil repeats:NO];
    self.backgroundColor = [UIColor redColor];
    if (loop == nil){
        loop = [[MagnifierView alloc] initWithFrame:CGRectMake(0,0,118,118)];
        loop.viewToMagnify = self;
    }
    
    UITouch *touch = [touches anyObject];
    loop.touchPoint = [touch locationInView:self];
    [loop setNeedsDisplay];
}

-(void) touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event{
    [self handleAction:touches];
}


-(void) touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event{
    [self.touchTimer invalidate];
    self.touchTimer = nil;
    [loop removeFromSuperview];
    self.backgroundColor = [UIColor clearColor];
}

-(void) addLoop{
    [self.superview addSubview:loop];
}

-(void) handleAction:(id)timerObj{
    NSSet* touches = timerObj;
    UITouch* touch = [touches anyObject];
    loop.touchPoint = [touch locationInView:self];
    [loop setNeedsDisplay];
}


@end
