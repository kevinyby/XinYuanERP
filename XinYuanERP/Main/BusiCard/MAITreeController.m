//
//  MAITreeController.m
//  XinYuanERP
//
//  Created by bravo on 14-2-14.
//  Copyright (c) 2014年 Xinyuan4. All rights reserved.
//

#import "MAITreeController.h"

@interface MAITreeController ()

@end

@implementation MAITreeController

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
	self.navigationBar.hidden = YES;
}

-(NSUInteger) supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
