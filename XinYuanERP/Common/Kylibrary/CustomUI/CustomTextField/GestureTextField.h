//
//  GestureTextField.h
//  XinYuanERP
//
//  Created by Xinyuan4 on 14-4-10.
//  Copyright (c) 2014年 Xinyuan4. All rights reserved.
//

#import "CustomTextField.h"

@class GestureTextField;
typedef void(^GestureTapAction)(GestureTextField* textField);

@interface GestureTextField : CustomTextField

@property (nonatomic, copy) GestureTapAction textFieldTapAction;

@end
