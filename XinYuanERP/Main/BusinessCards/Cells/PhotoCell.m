//
//  PhotoCell.m
//  Photolib
//
//  Created by bravo on 14-6-10.
//  Copyright (c) 2014年 bravo. All rights reserved.
//

#import "PhotoCell.h"

@implementation PhotoCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void) configreCell:(Card *)data{
    [self.thumb setImageWithURL:data.thumb_path placeholderImage:nil];
    [self.label setText:data.name];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
