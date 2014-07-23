//
//  EditController.h
//  Photolib
//
//  Created by bravo on 14-7-1.
//  Copyright (c) 2014年 bravo. All rights reserved.
//

#import <UIKit/UIKit.h>
@class EditController;
@protocol EditControllerDelegate <NSObject>

//Note: for now the edit controller is simply for editting file name (folder name/picture name)
// In the future, we may need to edit more attrubute eg. password, thumbnial etc. so you may
// want to modify this protocol later on.
-(void) editController:(EditController*)controller didConfirmWithName:(NSString*)name;

@end

@interface EditController : UITableViewController

@property (nonatomic,strong) NSString* theNewName;
@property (nonatomic,strong) id<EditControllerDelegate> delegate;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;

@end
