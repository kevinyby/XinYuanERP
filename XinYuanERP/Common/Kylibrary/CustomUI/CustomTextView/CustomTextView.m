//
//  CustomTextView.m
//  XinYuanERP
//
//  Created by Xinyuan4 on 13-12-30.
//  Copyright (c) 2014年 Xinyuan4. All rights reserved.
//

#import "CustomTextView.h"
#import "AppInterface.h"

@implementation CustomTextView

- (id)init
{
    self = [super init];
    if (self) {
        [self setToolBar];
    }
    return self;
}

- (void)setToolBar
{
    if (IS_IPHONE) {
        UIToolbar * topView = [[UIToolbar alloc] init];
        [topView setBarStyle:UIBarStyleBlackTranslucent];
        [topView sizeToFit];
        UIBarButtonItem * btnSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        UIBarButtonItem * doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissKeyboard)];
        NSArray * buttonsArray = [NSArray arrayWithObjects:btnSpace, doneButton, nil];
        [topView setItems:buttonsArray];
        [self setInputAccessoryView:topView];
    }
}

- (void)dismissKeyboard
{
    [self resignFirstResponder];
}


@end
