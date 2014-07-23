//
//  WDSearchTableView.m
//  Photolib
//
//  Created by bravo on 14-6-24.
//  Copyright (c) 2014年 bravo. All rights reserved.
//

#import "WDSearchTableView.h"
#import "ExportArrayDataSource.h"
#import "Card.h"

@interface WDSearchTableView ()<UISearchBarDelegate,UISearchDisplayDelegate>

@end    

@implementation WDSearchTableView
@synthesize delegate;
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(id) initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self){
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

#pragma mark - search display
- (void) searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller{
    [UIView beginAnimations:@"hide" context:nil];
    [UIView setAnimationDuration:0.3];
    self.navigationController.navigationBarHidden = YES;
    [UIView commitAnimations];
}

- (void) searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller{
    self.navigationController.navigationBarHidden = NO;
}

-(ExportArrayDataSource*) dataSource{
    return self.tableView.dataSource;
}

#pragma mark - Tableview delegate

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 65;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    Card* selectedItem;
    if (tableView == self.searchDisplayController.searchResultsTableView){
        NSLog(@"searched: %d",indexPath.row);
        selectedItem = [[self dataSource] itemAtSearchResult:indexPath];
    }else{
        NSLog(@"normal: %@", indexPath);
        selectedItem = [[self dataSource] itemAtIndex:indexPath];
    }
    
    if ([self.delegate respondsToSelector:@selector(wdsearchview:didSelectWithItem:)]){
        [self.delegate wdsearchview:self didSelectWithItem:selectedItem];
    }
}

#pragma mark -
#pragma mark - UISearchDisplayController Delegate Methods
-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    [[self dataSource] filterContentForSearchText:searchString scope:nil];
    return YES;
}

//-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption {
//    // 当用户改变搜索范围时，让列表的数据来源重新加载数据
//    [self filterContentForSearchText:self.searchDisplayController.searchBar.text scope:nil];
//
//    return YES;
//}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark -

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
