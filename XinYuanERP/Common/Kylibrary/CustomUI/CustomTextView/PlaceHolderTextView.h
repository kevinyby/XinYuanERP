//
//  PlaceHolderTextView.h
//  XinYuanERP
//
//  Created by Xinyuan4 on 14-7-14.
//  Copyright (c) 2014年 Xinyuan4. All rights reserved.
//

#import "CustomTextView.h"

@interface PlaceHolderTextView : CustomTextView

@property (nonatomic, copy) NSString *placeholder;

@property (nonatomic, strong) UIColor *placeholderColor;

@property (nonatomic, strong) UILabel *placeHolderLabel;

-(void)textChanged:(NSNotification*)notification;

-(void)setPlaceholderSetting;

@end
