//
//  AlbumCell.m
//  XinYuanERP
//
//  Created by bravo on 13-10-28.
//  Copyright (c) 2013年 Xinyuan4. All rights reserved.
//

#import "AlbumCell.h"

@implementation AlbumCell
@synthesize image;
@synthesize label;
@synthesize albumID;

-(id) initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self){
        image = [[UIImageView alloc] initWithFrame:CGRectMake(20, 15, 55, 60)];
        image.layer.masksToBounds = YES;
        image.layer.cornerRadius = 5.0;
        label = [[UILabel alloc] initWithFrame:CGRectMake(0, 80, 80, 35)];
        label.textAlignment = NSTextAlignmentCenter;
//        label.backgroundColor = [UIColor darkGrayColor];
        label.textColor = [UIColor darkTextColor];
        self.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"album_frame.png"]];
        [self.backgroundView addSubview:image];
        [self.backgroundView addSubview:label];
    }
    return self;
}

@end
