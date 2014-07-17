//
//  RuleListViewController.h
//  XinYuanERP
//
//  Created by Xinyuan4 on 13-9-7.
//  Copyright (c) 2013年 Xinyuan4. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ListTableViewController.h"

@interface RuleListViewController : ListTableViewController<UITableViewDelegate,UITableViewDataSource>
{
//    UITableView* ruleTable;
    NSMutableArray* ruleDataSource;
    UIBarButtonItem* rightItem;
}


@end
