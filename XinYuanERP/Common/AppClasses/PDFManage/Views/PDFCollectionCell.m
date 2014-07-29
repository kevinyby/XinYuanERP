//
//  PDFCollectionCell.m
//  XinYuanERP
//
//  Created by Xinyuan4 on 14-7-25.
//  Copyright (c) 2014年 Xinyuan4. All rights reserved.
//

#import "PDFCollectionCell.h"
#import "UILabel+UILabelAdditions.h"


@implementation PDFCollectionCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        _label = [[UILabel alloc] init];
        [_label setFrame:CGRectMake(5, 5, 60, 50)];
        _label.font = [UIFont systemFontOfSize:12];
//        _label.text = @"PDF";
        [self addSubview:_label];
        
        _selectedIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"selectionIcon.png"]];
        _selectedIcon.frame = CGRectMake(self.bounds.size.width-25, 5, 20, 20);
        [self addSubview:_selectedIcon];
        [_selectedIcon setHidden:YES];
        
        UITapGestureRecognizer* tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
        tapRecognizer.numberOfTapsRequired = 1;
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

- (void)setIsSelected:(BOOL)isSelected
{
    _isSelected = isSelected;
    _isSelected ? [self.selectedIcon setHidden:NO] : [self.selectedIcon setHidden:YES];
    
}

-(void)singleTap:(id)sender
{
    _isSelected = !_isSelected;
    [self setIsSelected:_isSelected];
    
    if (self.tapBlock) {
        self.tapBlock(self);
    }
}


@end
