 //
//  KYZoomView.m
//  XinYuanERP
//
//  Created by Xinyuan4 on 13-10-29.
//  Copyright (c) 2013年 Xinyuan4. All rights reserved.
//

#import "KYZoomView.h"
#import "AppInterface.h"

@implementation KYZoomView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        maxScale=3.0;
        minScale=1.0;
        currentScale=1.0;
        
        self.userInteractionEnabled=YES;
        self.maximumZoomScale=3.0;//最大倍率
        self.minimumZoomScale=1.0;//最小倍率
        self.decelerationRate=1.0;//减速倍率
        self.delegate=self;
        self.autoresizingMask =UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleHeight;
        
        _contentImgView = [[UIImageView alloc]init];
        self.contentImgView.userInteractionEnabled = YES;
        self.contentImgView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleHeight;
        self.contentImgView.frame=CGRectMake(0, 0, frame.size.width, frame.size.height);
        [self addSubview:self.contentImgView];
        
        [self setContentSize:CGSizeMake(frame.size.width, frame.size.height)];
        [self setScrollEnabled:NO];
        
//        if (IS_IPHONE) {
//            [self setContentSize:CGSizeMake(frame.size.width, frame.size.height)];
//            [self setScrollEnabled:YES];
//        }else{
//            [self setContentSize:CGSizeMake(frame.size.width, frame.size.height)];
//            [self setScrollEnabled:NO];
//        }
        
    }
    return self;
}

#pragma mark -
#pragma mark - Setter action

-(void)setMaxScale:(float)maxScaleValue
{
    maxScale=maxScaleValue;
    self.maximumZoomScale=maxScaleValue;
}

#pragma mark -
#pragma mark - UIScrollView delegate

-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.contentImgView;
}

-(void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale
{
    currentScale=scale;
    if (currentScale == minScale)
       [self setScrollEnabled:NO];
    else
       [self setScrollEnabled:YES];
}


@end
