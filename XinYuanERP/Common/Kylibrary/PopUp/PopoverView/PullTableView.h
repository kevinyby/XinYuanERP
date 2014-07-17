//
//  PullTableView.h
//  XinYuanERP
//
//  Created by Xinyuan4 on 13-11-5.
//  Copyright (c) 2013年 Xinyuan4. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PullTableView;
@protocol PullTableViewDelegate <NSObject>

@required
- (void)pullTableView:(PullTableView *)aView didSelectedCell:(NSString *)cellStr;

@optional
- (void)pullTableView:(PullTableView *)aView didSelectedCellIndex:(int )cellIndex;

@end


@interface PullTableView : UITableViewController

@property(nonatomic,strong)NSMutableArray* dataSource;
@property (weak, nonatomic) id<PullTableViewDelegate> delegate;

@end
