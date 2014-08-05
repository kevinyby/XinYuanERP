//
//  WHPickingDetailsOrderController.m
//  XinYuanERP
//
//  Created by Xinyuan4 on 14-5-15.
//  Copyright (c) 2014年 Xinyuan4. All rights reserved.
//

#import "WHPickingDetailsOrderController.h"
#import "AppInterface.h"

#import "WHPickingDetailsCell.h"

@interface WHPickingDetailsOrderController ()
{
    JRRefreshTableView* _pickingDetailsTableView;
    NSMutableArray* _pickingDetailsContents;
}

@end

@implementation WHPickingDetailsOrderController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
     WHPickingDetailsOrderController* __weak weakSelf = self;
    __block WHPickingDetailsOrderController* blockSelf = self;
    
    
    _pickingDetailsContents = [[NSMutableArray alloc] init];
    _pickingDetailsTableView = (JRRefreshTableView*)[self.jsonView getView:@"TABLE_Bottom"];
    _pickingDetailsTableView.tableView.tableViewBaseNumberOfSectionsAction = ^NSInteger(TableViewBase* tableViewObje){
        return 1;
    };
    _pickingDetailsTableView.tableView.tableViewBaseNumberOfRowsInSectionAction = ^NSInteger(TableViewBase* tableViewObj, NSInteger section) {
        return weakSelf.controlMode == JsonControllerModeCreate ? blockSelf->_pickingDetailsContents.count + 1 : blockSelf->_pickingDetailsContents.count;
    };
    _pickingDetailsTableView.tableView.tableViewBaseCellForIndexPathAction = ^UITableViewCell*(TableViewBase* tableViewObj, NSIndexPath* indexPath, UITableViewCell* oldCell) {
        static NSString *cellIdentifier = @"Cell";
        WHPickingDetailsCell* cell = [tableViewObj dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            cell = [[WHPickingDetailsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            cell.didEndEditNewCellAction = ^void(BaseJRTableViewCell* cell){
                WHPickingDetailsCell* pickingDetailsCell = (WHPickingDetailsCell*)cell;
                NSIndexPath* indexPath = [tableViewObj indexPathForCell: pickingDetailsCell];
                int row = indexPath.row;
                if (row == blockSelf->_pickingDetailsContents.count) {
                    [blockSelf->_pickingDetailsContents addObject:[pickingDetailsCell getDatas]];
                } else {
                    [blockSelf->_pickingDetailsContents replaceObjectAtIndex:row withObject:[pickingDetailsCell getDatas]];
                }
                [tableViewObj reloadData];
                [tableViewObj scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
            };
        }
        [cell setDatas: [blockSelf->_pickingDetailsContents safeObjectAtIndex: indexPath.row]];
        return cell;
    };

}


#pragma mark - Request
-(NSMutableDictionary*) assembleSendObjects: (NSString*)divViewKey
{
    NSMutableDictionary* objects = [super assembleSendObjects: divViewKey];
    
    [objects setObject:_pickingDetailsContents forKey:@"WHPickingDetailsBills"];
    
    return objects;
}

#pragma mark -
#pragma mark - Response

-(void) renderWithReceiveObjects: (NSMutableDictionary*)objects
{
    
    DBLOG(@"objects == %@",objects );
    [self.jsonView setModel: objects];
    _pickingDetailsContents = [objects objectForKey:@"WHPickingDetailsBills"];
    [_pickingDetailsTableView reloadTableData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
