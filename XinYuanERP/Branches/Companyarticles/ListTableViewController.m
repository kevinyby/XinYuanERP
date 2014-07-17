//
//  ListTableViewController.m
//  XinYuanERP
//
//  Created by Xinyuan4 on 13-9-9.
//  Copyright (c) 2013年 Xinyuan4. All rights reserved.
//

#import "ListTableViewController.h"
#import "AppInterface.h"

@interface ListTableViewController ()

@end

@implementation ListTableViewController

@synthesize baseTableView=_baseTableView;

- (void)dealloc
{
    _baseTableView.delegate=nil;
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
     self.navigationController.navigationBar.translucent = NO;
    [self renderByOrientation: self.interfaceOrientation];
}



- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.view.backgroundColor=[UIColor whiteColor];
    
    _baseTableView=[[UITableView alloc]init];
    _baseTableView.backgroundColor=[UIColor whiteColor];
    [self.view addSubview:_baseTableView];
    
   
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - About UIInterfaceOrientation

-(void)renderByOrientation:(UIInterfaceOrientation)interfaceOrientation {
    
    CGSize originScreenFrame= [[UIScreen mainScreen] bounds].size;
    float widthFloat=originScreenFrame.width;
    float heightFloat=originScreenFrame.height;
    
    CGRect canvas= CGRectMake(0, 0, widthFloat, heightFloat-20-44);
   
    
    _baseTableView.originFrame=[NSValue valueWithCGRect:canvas];
//    _baseTableView.rotateActualFrame=[NSValue valueWithCGRect:canvasRotate];
    
    [self render: interfaceOrientation];
    
}
-(void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    [self render: toInterfaceOrientation];
}

-(void) render: (UIInterfaceOrientation)interfaceOrientation {
    BOOL isPortrait = (interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown);
    if (isPortrait) {
        _baseTableView.frame=[_baseTableView.originFrame CGRectValue];
    }else{
//        _baseTableView.frame=[_baseTableView.rotateActualFrame CGRectValue];
    }
}

// for ios5.0 , 6.0 deprecated
-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return ((interfaceOrientation == UIInterfaceOrientationLandscapeLeft)||(interfaceOrientation == UIInterfaceOrientationLandscapeRight));
  
}

-(NSUInteger) supportedInterfaceOrientations
{

    return UIInterfaceOrientationMaskLandscape;
}

//for ios6.0 supported
-(BOOL) shouldAutorotate {
    return YES;
    
}
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationLandscapeLeft ;
}



@end
