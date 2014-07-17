//
//  ListTableViewController.h
//  XinYuanERP
//
//  Created by Xinyuan4 on 13-9-9.
//  Copyright (c) 2013年 Xinyuan4. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ListTableViewController : UIViewController
{
    UITableView* _baseTableView;
}

@property(strong,nonatomic)UITableView* baseTableView;

@end
