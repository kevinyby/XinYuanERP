//
//  WarehouseHelper.h
//  XinYuanERP
//
//  Created by Xinyuan4 on 14-6-18.
//  Copyright (c) 2014年 Xinyuan4. All rights reserved.
//

#import <Foundation/Foundation.h>

@class JRTextField;
@class JRButtonTextFieldView;
@interface WarehouseHelper : NSObject

+(void)popTableView:(JRTextField*)jrTextField settingModel:(NSString*)model;

+(void)constraint:(JRButtonTextFieldView*)constraintView condition:(JRButtonTextFieldView*)conditionView;

@end
