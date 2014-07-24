//
//  PasswordController.m
//  Photolib
//
//  Created by bravo on 14-7-12.
//  Copyright (c) 2014年 bravo. All rights reserved.
//

#import "PasswordController.h"

@interface PasswordController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *input;

@end

@implementation PasswordController
@synthesize donePassword;
@synthesize title;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIBarButtonItem* doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneAction:)];
    self.navigationItem.rightBarButtonItem =  doneButton;
    self.navigationItem.title = self.title?self.title:@"加密的相册";
    
    [self.input becomeFirstResponder];
    self.input.delegate = self;
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    [self doneAction:nil];
    return YES;
}

-(void) doneAction:(id)sender{
    donePassword(self.input.text);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
