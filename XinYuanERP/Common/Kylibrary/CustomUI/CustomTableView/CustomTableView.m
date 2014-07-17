//
//  CustomTableView.m
//  XinYuanERP
//
//  Created by Xinyuan4 on 13-12-17.
//  Copyright (c) 2013年 Xinyuan4. All rights reserved.
//

#import "CustomTableView.h"
#import "AppConfig.h"

static NSString * const CellIdentifier = @"CellIdentifier";

@implementation CustomTableView

- (id)initWithDataSource:(NSMutableArray*)array CellBlock:(TableViewCellBlock)cellBlock
{
    self = [super init];
    if (self) {
        
        self.arrayDataSource = [[CustomDataSource alloc] initWithItems:array
                                                             cellIdentifier:CellIdentifier
                                                         cellBlock:cellBlock];
        self.dataSource = self.arrayDataSource;
        self.delegate = self;
        float version = [[[UIDevice currentDevice] systemVersion] floatValue];
        if (version >= 7.0) [self setSeparatorInset:UIEdgeInsetsZero];
        
    }
    return self;
}

#pragma mark -
#pragma mark - Set And Get
-(void)setOutScrollView:(UIScrollView *)outScrollView
{
    _outScrollView = outScrollView;
    self.arrayDataSource.outScrollView = outScrollView;
}


#pragma mark -
#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.cellHeightBlock) {
        return self.cellHeightBlock();
    }
    return 45.0f;
  
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.cellSelectedBlock) {
        self.cellSelectedBlock(indexPath);
    }
    
    if (self.tableViewDelegate &&
        [self.tableViewDelegate respondsToSelector:@selector(tableViewDidSelectedIndexPath:)]) {
        [self.tableViewDelegate tableViewDidSelectedIndexPath:indexPath];
    }
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if ([otherGestureRecognizer.view isKindOfClass:[UIScrollView class]])
    {
        if (self.outScrollView)
        {
             [self.outScrollView setScrollEnabled:NO];
        }
        
    }
    
    if ([gestureRecognizer.view isKindOfClass:[UITableView class]]) {}
    
    return YES;
}



@end
