//
//  CustomImageView.m
//  XinYuanERP
//
//  Created by Xinyuan4 on 13-12-22.
//  Copyright (c) 2014年 Xinyuan4. All rights reserved.
//

#import "CustomImageView.h"

@implementation CustomImageView

- (id)init
{
    self = [super init];
    if (self) {
        self.userInteractionEnabled = YES;
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = YES;
    }
    return self;
}

- (id)initWithImage:(UIImage *)image
{
    self = [super initWithImage:image];
    if (self) {
        self.userInteractionEnabled = YES;
    }
    return self;
}

- (id)initWithImage:(UIImage *)image WithTag:(NSInteger)tag
{
    self = [super initWithImage:image];
    if (self) {
        self.userInteractionEnabled = YES;
        self.tag = tag;
    }
    return self;
}

@end
