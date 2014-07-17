//
//  SharedPassOrderController.m
//  XinYuanERP
//
//  Created by bravo on 13-12-31.
//  Copyright (c) 2013年 Xinyuan4. All rights reserved.
//

#define prefix @"SharedPassBill"
#define LOCALIZE(value) LOCALIZE_CONNECT_KEYS(prefix,value)

#import "SharedPassOrderController.h"

@interface SharedPassOrderController (){
    JRHeaderTableView *table;
}

@end

@implementation SharedPassOrderController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupTable];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

}

-(void) setupTable{
    table = (JRHeaderTableView*)[self.jsonView getView:@"table"];
    table.headers = [LocalizeHelper localize:@[LOCALIZE(@"object"),LOCALIZE(@"quantity"),LOCALIZE(@"unit"),LOCALIZE(@"remark")]]; //@[LOCALIZE_KEY(LOCALIZE(@"object")),LOCALIZE_KEY(LOCALIZE(@"quantity")), LOCALIZE_KEY(LOCALIZE(@"unit")),LOCALIZE_KEY(LOCALIZE(@"remark"))];
    
//    table.cellButtons = @[LOCALIZE_KEY(LOCALIZE(@"shot"))];
}

@end
