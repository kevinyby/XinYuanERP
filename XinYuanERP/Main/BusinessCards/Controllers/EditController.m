//
//  EditController.m
//  Photolib
//
//  Created by bravo on 14-7-1.
//  Copyright (c) 2014年 bravo. All rights reserved.
//

#import "EditController.h"

@interface EditController ()<UITextFieldDelegate>

@end

@implementation EditController
@synthesize theNewName,delegate;

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
    self.navigationItem.title = @"修改档名";
    UIBarButtonItem* doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneAction:)];
    self.navigationItem.rightBarButtonItems = @[doneButton];
    self.nameTextField.text = self.theNewName;
    self.nameTextField.delegate = self;
    [self.nameTextField becomeFirstResponder];
}

-(void) doneAction:(id)sender{
    if (self.nameTextField.text.length > 0){
        [self.delegate editController:self didConfirmWithName:self.nameTextField.text];
    }else{
        [self.delegate editController:self didConfirmWithName:self.theNewName];
    }
}

#pragma mark - textfiled delegate
-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    [self doneAction:nil];
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
