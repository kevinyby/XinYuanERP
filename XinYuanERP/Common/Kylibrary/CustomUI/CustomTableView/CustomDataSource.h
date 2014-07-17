//
//  CustomDataSource.h
//  XinYuanERP
//
//  Created by Xinyuan4 on 13-12-17.
//  Copyright (c) 2013年 Xinyuan4. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^TableViewCellBlock)(id cell, id item);

@interface CustomDataSource : NSObject <UITableViewDataSource>

@property (nonatomic, weak) UIScrollView* outScrollView;//外部传进来的ScrollView

- (id)initWithItems:(NSArray *)anItems
     cellIdentifier:(NSString *)aCellIdentifier
          cellBlock:(TableViewCellBlock)aCellBlock;

- (id)itemAtIndexPath:(NSIndexPath *)indexPath;


@end
