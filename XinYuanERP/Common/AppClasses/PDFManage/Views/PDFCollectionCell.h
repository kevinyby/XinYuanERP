//
//  PDFCollectionCell.h
//  XinYuanERP
//
//  Created by Xinyuan4 on 14-7-25.
//  Copyright (c) 2014年 Xinyuan4. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PDFCollectionCell;
typedef void (^SingleTapPDFCellBlock)(PDFCollectionCell* cell);

@interface PDFCollectionCell : UICollectionViewCell

@property(nonatomic, copy) SingleTapPDFCellBlock tapBlock;

@property(nonatomic, strong) UIImageView* selectedIcon;

@property(nonatomic, assign) BOOL isSelected;

@property(nonatomic, strong) UILabel* label;

-(void)setTextString:(NSString*)str;


@end
