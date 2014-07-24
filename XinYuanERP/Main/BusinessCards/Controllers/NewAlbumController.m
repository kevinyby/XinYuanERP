//
//  newAlbumController.m
//  Photolib
//
//  Created by bravo on 14-6-18.
//  Copyright (c) 2014年 bravo. All rights reserved.
//

#import "NewAlbumController.h"

@interface NewAlbumController ()<UITextFieldDelegate>

@end

@implementation NewAlbumController

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
    self.nameInput.delegate = self;
    self.pwdInput.delegate = self;
    [super viewDidLoad];
    [self.nameInput becomeFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0){
        [self.nameInput becomeFirstResponder];
    }else{
        [self.pwdInput becomeFirstResponder];
    }
}

#pragma mark - UITextField delegate
-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    if (textField == self.nameInput){
        [self.nameInput resignFirstResponder];
    }else{
        [self done:nil];
    }
    return YES;
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

- (IBAction)cancel:(id)sender {
    if (self.delegate && [self.delegate conformsToProtocol:@protocol(NewAlbumDelegate)]){
        [self.delegate newAlbumControllerDidCancle:self];
    }
}

- (IBAction)done:(id)sender {
    if (self.nameInput.text.length < 1) return;
    NSString* pwd = nil;
    if (self.pwdInput.text.length > 0) pwd = self.pwdInput.text;
    if (self.delegate && [self.delegate conformsToProtocol:@protocol(NewAlbumDelegate)]){
        [self.delegate newAlbumController:self didDoneWithName:self.nameInput.text passwd:pwd];
    }
}
@end
