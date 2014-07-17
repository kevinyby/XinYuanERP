//
//  AskPasswordPopup.h
//  XinYuanERP
//
//  Created by bravo on 13-10-29.
//  Copyright (c) 2013年 Xinyuan4. All rights reserved.
//

#import "PopupView.h"

@interface AskPasswordPopup : PopupView{
    UITextField* passwordBox;
}

@property(nonatomic,strong) NSString* password;

-(void) showTip:(NSString*)msg;

@end
