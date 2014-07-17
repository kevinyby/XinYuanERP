//
//  InputValidator.h
//  XinYuanERP
//
//  Created by Xinyuan4 on 13-12-7.
//  Copyright (c) 2013年 Xinyuan4. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface InputValidator : NSObject

@property(strong)NSString* errorMsg;

- (BOOL)validateInput:(UITextField*)input;

@end
