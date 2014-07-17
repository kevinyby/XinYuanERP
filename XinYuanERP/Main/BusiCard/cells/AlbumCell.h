//
//  AlbumCell.h
//  XinYuanERP
//
//  Created by bravo on 13-10-28.
//  Copyright (c) 2013年 Xinyuan4. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AlbumCell : UICollectionViewCell

@property(nonatomic,strong) UIImageView* image;
@property(nonatomic,strong) UILabel* label;
@property(nonatomic,assign) int albumID;
@end
