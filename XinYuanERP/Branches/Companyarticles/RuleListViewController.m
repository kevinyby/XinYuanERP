//
//  RuleListViewController.m
//  XinYuanERP
//
//  Created by Xinyuan4 on 13-9-7.
//  Copyright (c) 2013年 Xinyuan4. All rights reserved.
//

#import "RuleListViewController.h"
#import "AppInterface.h"


@interface RuleListViewController ()

@end

@implementation RuleListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    
}

- (void)viewDidLoad
{
    // hello world
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.view.backgroundColor=[UIColor whiteColor];
    
    self.baseTableView.delegate=self;
    self.baseTableView.dataSource=self;
 
    
    ruleDataSource=[[NSMutableArray alloc]initWithObjects:@"公司简介", @"厂规",@"加班管理办法", @"请假管理办法",@"宿舍管理办法",nil];
    
    rightItem =[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addAction:)];
    self.navigationItem.rightBarButtonItem=rightItem;
    
   

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Action
-(void)addAction:(id)sender
{
    AddRuleViewController* aRuleVC=[[AddRuleViewController alloc]init];
    [self.navigationController pushViewController:aRuleVC animated:YES];
    
    
}


#pragma mark - UITableViewDelegate & UITableViewDataSource
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (IS_IPHONE) {
        return 30;
    }else{
        return 60;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return [ruleDataSource count];
    
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    int row=indexPath.row;
    
    [[cell textLabel]setText:[NSString stringWithFormat:@"%@",[ruleDataSource objectAtIndex:row]]];
    
    return cell;

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"docPlist" ofType:@"plist"];
    NSMutableDictionary* dicplist=[[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
    int row=[indexPath row];
    NSString* contentValue=[dicplist objectForKey:[NSString stringWithFormat:@"%d",row]];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:contentValue ofType:@"doc"];
    NSURL *url = [NSURL fileURLWithPath:path];
    RuleDetailViewController* aKC =[[RuleDetailViewController  alloc]initWithURL:url];
    [self.navigationController pushViewController:aKC animated:YES];
    
//    KCFileVC* aKC=[[KCFileVC alloc]initWithURL:url];
//    [self.navigationController presentModalViewController:aKC animated:YES];
//    
//    KCWebVC* aKC=[[KCWebVC alloc]initWithURL:url];
//    [self.navigationController pushViewController:aKC animated:YES];
//    
}

@end
