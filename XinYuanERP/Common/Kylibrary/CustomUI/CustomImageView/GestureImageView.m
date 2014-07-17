//
//  GestureImageView.m
//  XinYuanERP
//
//  Created by Xinyuan4 on 13-12-23.
//  Copyright (c) 2014年 Xinyuan4. All rights reserved.
//

#import "GestureImageView.h"
#import "BrowseImageView.h"

@implementation GestureImageView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
         [self setTapGesture];
    }
    return self;
}

- (id)initWithTag:(NSInteger)tag
{
    self = [super initWithTag:tag];
    if (self) {
       
        [self setTapGesture];
    }
    return self;
}

-(void)setTapGesture
{
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    [self addGestureRecognizer:tapGesture];
}

-(void)handleTapGesture:(UITapGestureRecognizer*)sender {
    if (!self.image)return;
    [BrowseImageView browseImage:self];
}



@end
