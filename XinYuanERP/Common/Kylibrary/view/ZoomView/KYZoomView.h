//
//  KYZoomView.h
//  XinYuanERP
//
//  Created by Xinyuan4 on 13-10-29.
//  Copyright (c) 2013年 Xinyuan4. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZoomScrollView.h"

@interface KYZoomView : UIScrollView<UIScrollViewDelegate>
{
    CGFloat currentScale;//当前倍率
    CGFloat minScale;//最小倍率
    CGFloat maxScale;//最大倍率
}
@property(nonatomic,strong)UIImageView *contentImgView;


@end
