//
//  VehicleInfoOrderController.m
//  XinYuanERP
//
//  Created by bravo on 14-3-4.
//  Copyright (c) 2014年 Xinyuan4. All rights reserved.
//

#import "VehicleInfoOrderController.h"

@interface VehicleInfoOrderController ()

@end

@implementation VehicleInfoOrderController

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
    
    
    self.didShowTabView = ^void(int index, JsonDivView* tabView){
        if (index == 1){
            //vehicle dispatch
            
        }
        else if (index == 2){
            //refule
            
        }
        else if (index == 3){
            //maintance
            
        }
    };
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
