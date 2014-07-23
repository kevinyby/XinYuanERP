//
//  MAITreeController.m
//  XinYuanERP
//
//  Created by bravo on 14-2-14.
//  Copyright (c) 2014年 Xinyuan4. All rights reserved.
//

#import "BusinesscardsStarter.h"
#import "AppDelegate.h"


@interface BusinesscardsStarter ()

@end

@implementation BusinesscardsStarter

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
}

-(void) viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

-(NSUInteger) supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
