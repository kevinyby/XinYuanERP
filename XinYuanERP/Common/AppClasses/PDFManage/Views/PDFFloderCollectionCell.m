//
//  PDFFloderCollectionCell.m
//  XinYuanERP
//
//  Created by Xinyuan4 on 14-7-26.
//  Copyright (c) 2014年 Xinyuan4. All rights reserved.
//

#import "PDFFloderCollectionCell.h"
#import "UILabel+UILabelAdditions.h"


@implementation PDFFloderCollectionCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        _label = [[UILabel alloc] init];
        [_label setFrame:CGRectMake(5, 5, 60, 50)];
        _label.font = [UIFont systemFontOfSize:12];
//        _label.text = @"文件夹";
        [self addSubview:_label];
        
        UITapGestureRecognizer* tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap)];
        tapRecognizer.numberOfTapsRequired = 2;
        tapRecognizer.numberOfTouchesRequired = 1;
        [self addGestureRecognizer:tapRecognizer];
        
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

-(void)setTextString:(NSString*)str
{
    _label.text = str;
    [_label resizeHeight];
    
}

-(void)doubleTap
{
    if (self.tapBlock) {
        self.tapBlock(self);
    }
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
