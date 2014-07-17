//
//  PageViewController.m
//  XinYuanERP
//
//  Created by Xinyuan4 on 14-4-21.
//  Copyright (c) 2014年 Xinyuan4. All rights reserved.
//

#import "PageViewController.h"
#import "AppInterface.h"

@interface PageViewController ()

@end

@implementation PageViewController

- (id)init
{
    self = [super init];
    if (self) {
        
        CGRect rect = self.view.bounds;
        rect.size.width = rect.size.width/2;
        rect.size.height = rect.size.height - [FrameTranslater convertCanvasHeight:40];
        
        _currentPageView = [[PageView alloc] initWithFrame:rect];
        [self.view addSubview:_currentPageView];
        self.currentPageView.clipsToBounds = YES;
        
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIColor* backgroundColor = [UIColor colorWithRed:247.0f/255.0f green:247.0f/255.0f blue:247.0f/255.0f alpha:0.8f];
    self.view.backgroundColor = backgroundColor;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
