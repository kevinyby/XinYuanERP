//
//  PopPDFViewController.h
//  XinYuanERP
//
//  Created by Xinyuan4 on 14-6-24.
//  Copyright (c) 2014年 Xinyuan4. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PopPDFTableViewCell : UITableViewCell

@property(nonatomic,strong)UIImageView* checkImageView;
@property (nonatomic, assign) BOOL isSelected;


@end


typedef void (^PopViewSelectValueBlock)(NSMutableArray* selectArray);

@interface PopPDFViewController : UIViewController

@property(nonatomic,copy)PopViewSelectValueBlock selectBlock;
@property(nonatomic,strong)NSMutableArray* selectedMarks;
@property(nonatomic,copy)NSString* title;
@property(nonatomic,strong)NSArray* pathArray;


@end
