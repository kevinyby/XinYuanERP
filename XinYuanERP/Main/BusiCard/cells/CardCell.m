//
//  CardCell.m
//  XinYuanERP
//
//  Created by bravo on 13-11-1.
//  Copyright (c) 2013年 Xinyuan4. All rights reserved.
//

#import "CardCell.h"

@implementation CardCell
@synthesize image;
@synthesize title;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        image = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 80, 80)];
        title = [[UILabel alloc] initWithFrame:CGRectMake(0, 70, 80, 40)];
        title.textAlignment = NSTextAlignmentCenter;
//        title.backgroundColor = [UIColor darkGrayColor];
        title.textColor = [UIColor darkTextColor];
        self.backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 80, 80)];
    
        [self.backgroundView addSubview:image];
        [self.backgroundView addSubview:title];
        
    }
    return self;
}

@end
