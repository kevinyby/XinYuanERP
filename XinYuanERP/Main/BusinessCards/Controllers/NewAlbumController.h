//
//  newAlbumController.h
//  Photolib
//
//  Created by bravo on 14-6-18.
//  Copyright (c) 2014年 bravo. All rights reserved.
//

#import <UIKit/UIKit.h>
@class NewAlbumController;
@protocol NewAlbumDelegate <NSObject>
-(void) newAlbumControllerDidCancle:(NewAlbumController*)controller;
-(void) newAlbumController:(NewAlbumController*)controller didDoneWithName:(NSString*)name passwd:(NSString*)passwd;
@end

@interface NewAlbumController : UITableViewController
@property(nonatomic,weak) id<NewAlbumDelegate>delegate;
@property (weak, nonatomic) IBOutlet UITextField *nameInput;
@property (weak, nonatomic) IBOutlet UITextField *pwdInput;

- (IBAction)cancel:(id)sender;
- (IBAction)done:(id)sender;

@end
