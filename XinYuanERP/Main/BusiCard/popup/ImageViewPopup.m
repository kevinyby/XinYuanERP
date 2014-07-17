//
//  ImageViewPopup.m
//  XinYuanERP
//
//  Created by bravo on 13-11-7.
//  Copyright (c) 2013年 Xinyuan4. All rights reserved.
//

#import "ImageViewPopup.h"

@interface ImageViewPopup(){
    UIImage* _image;
    UIImageView* imageView;
}
@property (nonatomic,strong) UIImage* image;
@end

@implementation ImageViewPopup
@dynamic image;

- (id)initWithContentSize:(CGRect)frame
{
    self = [super initWithContentSize:CGRectMake(0, 0, 640, 320)];
    if (self) {
        imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 200, 150)];
        imageView.backgroundColor = [UIColor blackColor];
        [content addSubview:imageView];
    }
    return self;
}

-(void) drawRect:(CGRect)rect{
    [imageView removeFromSuperview];
    imageView.image = _image;
    [content addSubview:imageView];
}

-(void) setImage:(UIImage *)image{
    _image = image;
    [self setNeedsDisplay];
}

-(UIImage*)image{
    return _image;
}

@end
