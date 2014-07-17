//
//  RotateViewController.m
//  XinYuanERP
//
//  Created by Xinyuan4 on 13-9-11.
//  Copyright (c) 2013年 Xinyuan4. All rights reserved.
//

#import "RotateViewController.h"
#import "AppInterface.h"

@interface RotateViewController ()

@end

@implementation RotateViewController


//隐藏状态栏
- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    float width=0;
    float height=0;
    
    float gap = 0;
    if (IOS_VERSION<7) gap = 20;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        if (IS_IPHONE_5) {
            width=LONG_IPHONE5;
            height=SHORT_IPHONE - gap;
            
        }else{
            width =LONG_IPHONE;
            height =SHORT_IPHONE - gap;
        }
    }
    else{
        width =LONG_IPAD;
        height =SHORT_IPAD - gap;
    }
    
    self.view.bounds=CGRectMake(0, 0,width,height);
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}

#pragma mark -
#pragma mark - UIInterfaceOrientation

// for ios5.0 , 6.0 deprecated
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return (toInterfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

- (NSUInteger) supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscape;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    
    return UIInterfaceOrientationLandscapeRight;
}

// for ios6.0 supported
- (BOOL) shouldAutorotate {
    return YES ;//YES;
}




@end
