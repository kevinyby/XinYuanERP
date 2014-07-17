//
//  SecurityPatrolOrderViewController.h
//  XinYuanERP
//
//  Created by bravo on 14-01-16.
//  Copyright (c) 2013年 Xinyuan4. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppInterface.h"

@class PhotoPickerViewController;
@protocol OrdersNoticeDelegate;
@interface SecurityVisitorOrderController : JsonController{
    
}

@property(nonatomic,strong)PhotoPickerViewController *imagePicker;

@end
