//
//  CornerImageView.m
//  XinYuanERP
//
//  Created by Xinyuan4 on 13-12-23.
//  Copyright (c) 2014年 Xinyuan4. All rights reserved.
//

#import "CornerImageView.h"
#import "AppConfig.h"

@implementation CornerImageView


- (id)initWithTag:(NSInteger)tag
{
    self = [super init];
    if (self) {
        self.layer.cornerRadius = IS_IPHONE? 6.0f : 10.0f;
        self.clipsToBounds = TRUE;
        self.tag = tag;
#ifdef TMD_TEST
        self.backgroundColor = [UIColor lightGrayColor];
#else
        self.backgroundColor = [UIColor clearColor];
#endif
    }
    return self;
}


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.cornerRadius = IS_IPHONE? 6.0f : 10.0f;
        self.clipsToBounds = TRUE;
#ifdef TMD_TEST
        self.backgroundColor = [UIColor lightGrayColor];
#else
        self.backgroundColor = [UIColor clearColor];
#endif
    }
    return self;
}

@end
