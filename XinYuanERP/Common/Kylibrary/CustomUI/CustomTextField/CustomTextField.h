//
//  CustomTextField.h
//  XinYuanERP
//
//  Created by Xinyuan4 on 13-12-7.
//  Copyright (c) 2013年 Xinyuan4. All rights reserved.
//

#import <UIKit/UIKit.h>

#define DATEFILTER   @"datefliter"
#define CURRENTDATEFILTER @"currentDateFliter"
#define CURRENTUSERFILTER @"currentUserFliter" 

@interface CustomTextField : UITextField

@property(nonatomic,strong)NSString* filterType;

- (id)initWithFont:(UIFont*)afont;


@end
