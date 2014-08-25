//
//  CustomTextField.m
//  XinYuanERP
//
//  Created by Xinyuan4 on 13-12-7.
//  Copyright (c) 2013年 Xinyuan4. All rights reserved.
//

#import "CustomTextField.h"
#import "FrameTranslater.h"


@implementation CustomTextField

- (id)init
{
    self = [super init];
    if (self) {
#ifdef TMD_TEST
        self.backgroundColor = [UIColor lightGrayColor];
#else
        self.backgroundColor = [UIColor clearColor];
#endif
        self.borderStyle = UITextBorderStyleNone;
        self.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        self.adjustsFontSizeToFitWidth = YES;
        self.returnKeyType = UIReturnKeyDone;
        self.font = [UIFont fontWithName:@"Arial" size:[FrameTranslater convertFontSize:20]];

    }
    return self;
}

- (id)initWithFont:(UIFont*)afont
{
    self = [super init];
    if (self) {
#ifdef TMD_TEST
        self.backgroundColor = [UIColor lightGrayColor];
#else
        self.backgroundColor = [UIColor clearColor];
#endif
        self.borderStyle = UITextBorderStyleNone;
        self.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        self.adjustsFontSizeToFitWidth = YES;
        self.returnKeyType = UIReturnKeyDone;
        self.font = afont;
        
    }
    return self;
}



@end
