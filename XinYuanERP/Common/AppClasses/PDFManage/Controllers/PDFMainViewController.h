//
//  PDFMainViewController.h
//  XinYuanERP
//
//  Created by Xinyuan4 on 14-7-24.
//  Copyright (c) 2014年 Xinyuan4. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RotateViewController.h"

typedef void (^PDFSelectValueBlock)(NSMutableArray* selectArray);

@interface PDFMainViewController : RotateViewController<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

@property(nonatomic,strong)UICollectionView* collectionView;

@property(nonatomic,strong)NSMutableArray* PDFSelectArray;

@property(nonatomic,copy)PDFSelectValueBlock selectBlock;


@end
