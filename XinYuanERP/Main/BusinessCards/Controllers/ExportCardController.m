//
//  ImportCardController.m
//  Photolib
//
//  Created by bravo on 14-6-20.
//  Copyright (c) 2014年 bravo. All rights reserved.
//

#import "ExportCardController.h"
#import "ExportArrayDataSource.h"
#import "WDSearchTableView.h"
#import "Card.h"
#import "AppDelegate.h"
#import "MBProgressHUD.h"

@interface ExportCardController ()<WDSearchTableViewDelegate>

@property(nonatomic,strong) ExportArrayDataSource* dataSource;
@property(nonatomic,weak) WDSearchTableView* searchTable;

@end

@implementation ExportCardController
@synthesize delegate;
@synthesize moves;

-(id) initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self){
        
    }
    return self;
}

-(void) setDataSourceObj:(id)obj{
    self.dataSource = obj;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)cancleAction:(id)sender {
    [self.delegate exportCardControllerDidCancle:self];
}

- (IBAction)doneAction:(id)sender {
}

#pragma mark - WDSearchTableView Delegate
-(void) wdsearchview:(WDSearchTableView *)searchview didSelectWithItem:(id)item{
    [self.delegate exportCardController:self didExportToItem:item];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"ExportEmbed"]){
        WDSearchTableView* searchController = segue.destinationViewController;
        searchController.delegate = self;
        NSAssert(self.dataSource != nil, @"search table datasource cannot be nil");
        searchController.tableView.dataSource = self.dataSource;
        self.dataSource.target = searchController;
        searchController.searchDisplayController.searchResultsDataSource = self.dataSource;
    }
}


@end
