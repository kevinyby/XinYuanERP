//
//  PasswordController.h
//  Photolib
//
//  Created by bravo on 14-7-12.
//  Copyright (c) 2014年 bravo. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^DONEPASSWORDCALLBACK)(NSString* password);

@interface PasswordController : UITableViewController

@property(nonatomic,strong) DONEPASSWORDCALLBACK donePassword;
@property(nonatomic,strong) NSString* title;

@end
