//
//  ApplyOrderButton.h
//  XinYuanERP
//
//  Created by Xinyuan4 on 13-12-30.
//  Copyright (c) 2013年 Xinyuan4. All rights reserved.
//

#import "CustomButton.h"

@interface ApplyOrderButton : CustomButton

@property(nonatomic,strong)NSString* applyType;

@property(nonatomic,strong)NSString* applyMethodType;

@property(nonatomic,strong)NSString* applyListType;

@property(nonatomic,strong)NSString* applyOrder;

-(id)initBackgroundImage:(UIImage*)aImage
                   title:(NSString*)aTitle
                    font:(UIFont*)aFont
              titleColor:(UIColor*)aColor
               highColor:(UIColor*)aHighColor
                  target:(id)aTarget
                  action:(SEL)aAction;


+(NSArray*)arrayFromApplyType:(ApplyOrderButton*)btn FromDic:(NSDictionary*)dic;

@end
