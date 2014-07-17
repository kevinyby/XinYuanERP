//
//  KYSubZoomView.m
//  XinYuanERP
//
//  Created by Xinyuan4 on 14-1-2.
//  Copyright (c) 2014年 Xinyuan4. All rights reserved.
//

#import "KYSubZoomView.h"

@implementation KYSubZoomView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
         self.delegate=self;
        [self setScrollEnabled:YES];
    }
    return self;
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
    [self setScrollEnabled:YES];
}




@end
