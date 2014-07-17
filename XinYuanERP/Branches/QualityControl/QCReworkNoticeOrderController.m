//
//  QCReworkNoticeOrderController.m
//  XinYuanERP
//
//  Created by Xinyuan4 on 14-3-19.
//  Copyright (c) 2014年 Xinyuan4. All rights reserved.
//

#import "QCReworkNoticeOrderController.h"
#import "AppInterface.h"

@interface QCReworkNoticeOrderController ()

@end

@implementation QCReworkNoticeOrderController

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
	// Do any additional setup after loading the view.
    JsonView* jsonView = self.jsonView;
    
    __weak QCReworkNoticeOrderController* weakSelf = self;
    
    JRButton* app1Button = ((JRButtonTextFieldView*)[jsonView getView:@"NESTED_footer.app1"]).button;
    NormalButtonDidClickBlock preClick1Action = app1Button.didClikcButtonAction;
    app1Button.didClikcButtonAction = ^void(JRButton* button){
        
        NSString* message = nil;
        // check values
        [JsonControllerHelper validateNotEmptyObjects: @[@"problemReview",@"IMG_Photo_After"] jsonView:weakSelf.jsonView message:&message];
        if (message) {
            [ACTION alertMessage: message];
            return;
        }
        
        preClick1Action(button); // call super/ old;
        
    };
    
    
    JRButton* app2Button = ((JRButtonTextFieldView*)[jsonView getView:@"NESTED_footer.app2"]).button;
    NormalButtonDidClickBlock preClick2Action = app2Button.didClikcButtonAction;
    app2Button.didClikcButtonAction = ^void(JRButton* button){
        
        NSString* message = nil;
        // check values
        [JsonControllerHelper validateNotEmptyObjects: @[@"fee"] jsonView:weakSelf.jsonView message:&message];
        if (message) {
            [ACTION alertMessage: message];
            return;
        }
        
        preClick2Action(button); // call super/ old;
        
    };
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
