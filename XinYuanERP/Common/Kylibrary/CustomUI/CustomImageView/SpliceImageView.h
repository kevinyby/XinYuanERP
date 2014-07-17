//
//  SpliceImageView.h
//  XinYuanERP
//
//  Created by Xinyuan4 on 14-1-25.
//  Copyright (c) 2014年 Xinyuan4. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SpliceImageView : UIView

@property(nonatomic,assign)UIImage* topImage;
@property(nonatomic,assign)UIImage* midImage;
@property(nonatomic,assign)UIImage* bottomImage;

@property(nonatomic,strong)UIImageView* topImageView;
@property(nonatomic,strong)UIImageView* midImageView;
@property(nonatomic,strong)UIImageView* bottomImageView;

@property(nonatomic,assign)BOOL ishightLevel;

@end
