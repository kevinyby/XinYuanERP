//
//  itemCell.m
//  Photolib
//
//  Created by bravo on 14-6-16.
//  Copyright (c) 2014年 bravo. All rights reserved.
//

#import "itemCell.h"

@interface itemCell()

@end

@implementation itemCell{
    UITapGestureRecognizer* tapRecognizer;
    UIView* selectionCover;
    UIImageView* selectionIcon;
}

-(id) initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self){
        [self initialize];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
    }
    return self;
}

-(void) initialize{
    self.userInteractionEnabled = YES;
    tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
    tapRecognizer.numberOfTapsRequired = 2;
    tapRecognizer.numberOfTouchesRequired = 1;
    [self addGestureRecognizer:tapRecognizer];
    
    selectionCover = [[UIView alloc] initWithFrame:self.bounds];
    selectionCover.tag = 1000;
    selectionCover.backgroundColor = [UIColor whiteColor];
    selectionCover.alpha = 0.5f;
    selectionIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"selectionIcon.png"]];
    selectionIcon.frame = CGRectMake(self.bounds.size.width-25, 5, 20, 20);
}

-(void) configreCell:(Card *)data{
    
}

-(void) doubleTap:(id)sender{
    NSLog(@"tap X2!");
    [_browserController changeSelection:NO onCell:self];
    [_browserController enterCell:self];
}

-(void) setSelected:(BOOL)selected{
    [super setSelected:selected];
    [self toggleSelectionView:selected];
}

-(void) toggleSelectionView:(BOOL)selected{
    if (selected){
        [self addSubview:selectionCover];
        [self addSubview:selectionIcon];
    }else{
        [selectionCover removeFromSuperview];
        [selectionIcon removeFromSuperview];
    }
}


@end
