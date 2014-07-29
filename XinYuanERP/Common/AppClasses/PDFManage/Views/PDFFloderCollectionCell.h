//
//  PDFFloderCollectionCell.h
//  XinYuanERP
//
//  Created by Xinyuan4 on 14-7-26.
//  Copyright (c) 2014年 Xinyuan4. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PDFFloderCollectionCell;
typedef void (^DoubleTapPDFFloderCellBlock)(PDFFloderCollectionCell* cell);

@interface PDFFloderCollectionCell : UICollectionViewCell

@property(nonatomic, copy) DoubleTapPDFFloderCellBlock tapBlock;

@property(nonatomic, strong) NSDictionary* floderSource;

@property(nonatomic, strong) UILabel* label;

-(void)setTextString:(NSString*)str;

@end
