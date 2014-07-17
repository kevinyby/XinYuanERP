//
//  BubbleMenu.m
//  bubbleMenu
//
//  Created by bravo on 14-4-18.
//  Copyright (c) 2014年 bravo. All rights reserved.
//

#import "BubbleMenu.h"

#define RADIUS 80.0f
#define STARTPOINT CGPointMake(self.bounds.size.width/2, 140)
#define TIMEOFFSET 0.036f

@interface BubbleMenu()

-(void) _expand;
-(void) _close;
-(CAAnimationGroup*)_blowupAnimationAtPoint:(CGPoint)p;
-(CAAnimationGroup*)_shrinkAnimationAtPoint:(CGPoint)p;
@end

@implementation BubbleMenu

-(id) initWithFrame:(CGRect)frame menus:(NSArray *)menus{
    if (self = [super initWithFrame:frame]){
        self.menusArray = [menus copy];
        
        int count = self.menusArray.count;
        for (int i=1; i < count+1; i++){
            BubbleMenuItem* item = [self.menusArray objectAtIndex:i-1];
            item.tag = 1000 + i-1;
            item.position = CGPointMake(STARTPOINT.x + RADIUS * cosf(i * M_PI / (count + 1)), STARTPOINT.y - RADIUS * sinf(i * M_PI / (count + 1)));
            item.delegate = self;
            item.center = item.position;
            item.alpha = 0.0f;
            [self addSubview:item];
        }
        
        start = [[BubbleMenuItem alloc] initWithImage:[UIImage imageNamed:@"bubbleMain.png"] title:@"Start" highlightedImage:[UIImage imageNamed:@"bubbleMain_highlighted.png"] contentImage:nil hightedContentImage:nil];
        start.titleLabel.frame = CGRectMake(start.titleLabel.frame.origin.x, start.titleLabel.frame.origin.y - 20, start.titleLabel.bounds.size.width, start.titleLabel.bounds.size.height);
        start.delegate = self;
        start.center = STARTPOINT;
        [self addSubview:start];
    }
    return self;
}

-(void)setTitle:(NSString *)str{
    start.titleLabel.text = str;
}

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
//    self.expanding = !self.expanding;
//    if (!_timer){
//        _flag = self.expanding ? 0 : 5;
//        SEL selector = self.expanding ? @selector(_expand) : @selector(_close);
//        _timer = [NSTimer scheduledTimerWithTimeInterval:TIMEOFFSET target:self selector:selector userInfo:nil repeats:YES];
//    }
}

#pragma mark - BubbleItem Delegate
-(void)bubbleMenuItemTouchesBegan:(BubbleMenuItem *)item{
    NSLog(@"hahaha");
    if (item == start){
        self.expanding = !self.expanding;
        if (!_timer){
            _flag = self.expanding ? 0 : 5;
            SEL selector = self.expanding ? @selector(_expand) : @selector(_close);
            _timer = [NSTimer scheduledTimerWithTimeInterval:TIMEOFFSET target:self selector:selector userInfo:nil repeats:YES];
        }
    }
}

-(void)bubbleMenuItemTouchesEnd:(BubbleMenuItem *)item{
    if (item == start){
        return;
    }
    CAAnimationGroup* blowup = [self _blowupAnimationAtPoint:item.center];
    [item.layer addAnimation:blowup forKey:@"blowup"];
    item.center = start.center;
    
    for (int i=0; i < [self.menusArray count]; i++){
        BubbleMenuItem* otherItem = [self.menusArray objectAtIndex:i];
        CAAnimationGroup* shrink = [self _shrinkAnimationAtPoint:item.center];
        if (otherItem.tag == item.tag){
            continue;
        }
        [otherItem.layer addAnimation:shrink forKey:@"shrink"];
//        otherItem.center = start.center;
        otherItem.alpha = 0.0f;
    }
    self.expanding = NO;
    if ([self.delegate respondsToSelector:@selector(bubbleMenu:didSelectAtIndex:)]){
        [self.delegate bubbleMenu:self didSelectAtIndex:item.tag - 1000];
    }
}


#pragma mark - event
-(CAAnimationGroup*)_blowupAnimationAtPoint:(CGPoint)p{
    CAKeyframeAnimation *positionAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    positionAnimation.values = [NSArray arrayWithObjects:[NSValue valueWithCGPoint:p], nil];
    positionAnimation.keyTimes = [NSArray arrayWithObjects: [NSNumber numberWithFloat:.3], nil];
    
    CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
    scaleAnimation.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(3, 3, 1)];
    
    CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    opacityAnimation.fromValue = [NSNumber numberWithFloat:1.0f];
    opacityAnimation.toValue  = [NSNumber numberWithFloat:0.0f];
    
    CAAnimationGroup *animationgroup = [CAAnimationGroup animation];
    animationgroup.animations = [NSArray arrayWithObjects:positionAnimation, scaleAnimation, opacityAnimation, nil];
    animationgroup.duration = 0.3f;
    animationgroup.fillMode = kCAFillModeForwards;
    
    return animationgroup;
}

- (CAAnimationGroup *)_shrinkAnimationAtPoint:(CGPoint)p
{
    CAKeyframeAnimation *positionAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    positionAnimation.values = [NSArray arrayWithObjects:[NSValue valueWithCGPoint:p], nil];
    positionAnimation.keyTimes = [NSArray arrayWithObjects: [NSNumber numberWithFloat:.3], nil];
    
    CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
    scaleAnimation.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(.01, .01, 1)];
    
    CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    opacityAnimation.fromValue = [NSNumber numberWithFloat:1.0f];
    opacityAnimation.toValue  = [NSNumber numberWithFloat:0.0f];
    
    CAAnimationGroup *animationgroup = [CAAnimationGroup animation];
    animationgroup.animations = [NSArray arrayWithObjects:scaleAnimation, opacityAnimation, nil];
    animationgroup.duration = 0.3f;
    animationgroup.fillMode = kCAFillModeForwards;
    
    return animationgroup;
}

-(void) _expand{
    if (_flag == self.menusArray.count){
        [_timer invalidate];
        _timer = nil;
        return;
    }
    
    int tag = 1000 + _flag;
    BubbleMenuItem *item = (BubbleMenuItem*)[self viewWithTag:tag];
    
    CAKeyframeAnimation *positionAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    positionAnimation.values = [NSArray arrayWithObjects:[NSValue valueWithCGPoint:item.position], nil];
    positionAnimation.keyTimes = [NSArray arrayWithObjects: [NSNumber numberWithFloat:.3], nil];
    
    CABasicAnimation* scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
    scaleAnimation.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(2, 2, 1)];
    scaleAnimation.autoreverses = YES;
    scaleAnimation.timingFunction = [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionEaseInEaseOut];
    scaleAnimation.duration = 0.2f;
    
    CABasicAnimation* opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    opacityAnimation.fromValue = [NSNumber numberWithFloat:0.0f];
    opacityAnimation.toValue = [NSNumber numberWithFloat:1.0f];
    
    
    CAAnimationGroup* animationgroup = [CAAnimationGroup animation];
    animationgroup.animations = [NSArray arrayWithObjects:positionAnimation,scaleAnimation,opacityAnimation, nil];
    animationgroup.duration = 0.5f;
    animationgroup.fillMode = kCAFillModeForwards;
    [item.layer addAnimation:animationgroup forKey:@"Expand"];
    item.center = item.position;
    item.alpha = 1.0f;
    _flag++;
}

-(void) _close{
    if (_flag == -1){
        [_timer invalidate];
        _timer = nil;
        return;
    }
    int tag = 1000 + _flag;
    BubbleMenuItem* item = (BubbleMenuItem*)[self viewWithTag:tag];
    CABasicAnimation* scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
    scaleAnimation.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(.01, .01, 1)];
    
    CABasicAnimation* opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    opacityAnimation.fromValue = [NSNumber numberWithFloat:1.0f];
    opacityAnimation.toValue = [NSNumber numberWithFloat:0.0f];
    
    CAAnimationGroup* animationgroup = [CAAnimationGroup animation];
    animationgroup.animations = [NSArray arrayWithObjects:scaleAnimation,opacityAnimation, nil];
    animationgroup.duration = 0.3f;
    animationgroup.fillMode = kCAFillModeForwards;

    [item.layer addAnimation:animationgroup forKey:@"Close"];
    item.alpha = 0.0f;
//    item.center = STARTPOINT;
    _flag--;
}

@end
