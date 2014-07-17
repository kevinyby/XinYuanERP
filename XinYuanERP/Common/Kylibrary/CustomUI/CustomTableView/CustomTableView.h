//
//  CustomTableView.h
//  XinYuanERP
//
//  Created by Xinyuan4 on 13-12-17.
//  Copyright (c) 2013年 Xinyuan4. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomDataSource.h"


typedef CGFloat (^TableViewCellHeightBlock)();
typedef void (^TableViewSelectCellBlock)(NSIndexPath *indexPath);


@protocol CustomTableViewDelegate;
@interface CustomTableView : UITableView <UITableViewDelegate>

@property (nonatomic, strong)CustomDataSource *arrayDataSource;

@property (nonatomic, copy)TableViewCellHeightBlock cellHeightBlock;

@property (nonatomic, copy)TableViewSelectCellBlock cellSelectedBlock;

@property (nonatomic, assign)id<CustomTableViewDelegate> tableViewDelegate;


@property (nonatomic, weak) UIScrollView* outScrollView;//外部传进来的ScrollView


- (id)initWithDataSource:(NSArray*)array CellBlock:(TableViewCellBlock)cellBlock;


@end


@protocol CustomTableViewDelegate <NSObject>

@optional
- (void)tableViewDidSelectedIndexPath:(NSIndexPath *)indexPath;

@end