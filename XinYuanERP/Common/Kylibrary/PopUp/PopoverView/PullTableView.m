//
//  PullTableView.m
//  XinYuanERP
//
//  Created by Xinyuan4 on 13-11-5.
//  Copyright (c) 2013年 Xinyuan4. All rights reserved.
//

#import "PullTableView.h"

@interface PullTableView ()

@end

@implementation PullTableView

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
         _dataSource = [[NSMutableArray alloc]init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
   
    return [self.dataSource count];
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell =  [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    if(cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    int row = [indexPath row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@",[self.dataSource objectAtIndex:row]];
    
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    int row = [indexPath row];
    NSLog(@"row=====%d",row);
    
    if (self.delegate&&[self.delegate respondsToSelector:@selector(pullTableView:didSelectedCell:)]) {
        [self.delegate pullTableView:self didSelectedCell:(NSString *)[self.dataSource objectAtIndex:indexPath.row]];
    }
    
    if (self.delegate&&[self.delegate respondsToSelector:@selector(pullTableView:didSelectedCellIndex:)]) {
        [self.delegate pullTableView:self didSelectedCellIndex:(int)indexPath.row];
    }
}

@end
