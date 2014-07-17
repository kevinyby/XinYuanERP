//
//  ApplyOrderButton.m
//  XinYuanERP
//
//  Created by Xinyuan4 on 13-12-30.
//  Copyright (c) 2013年 Xinyuan4. All rights reserved.
//

#import "ApplyOrderButton.h"
#import "AppInterface.h"

@implementation ApplyOrderButton

-(id)initBackgroundImage:(UIImage*)aImage
                   title:(NSString*)aTitle
                    font:(UIFont*)aFont
              titleColor:(UIColor*)aColor
               highColor:(UIColor*)aHighColor
                  target:(id)aTarget
                  action:(SEL)aAction
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
		[self setBackgroundImage:aImage forState:UIControlStateNormal];
		[self setBackgroundImage:aImage forState:UIControlStateHighlighted];
		[self setBackgroundImage:aImage forState:UIControlStateSelected];
        [self setTitle:aTitle forState:UIControlStateNormal];
        [self.titleLabel setFont:aFont];
        [self setTitleColor:aColor forState:UIControlStateNormal];
        [self setTitleColor:aHighColor forState:UIControlStateSelected];
        [self setTitleColor:aHighColor forState:UIControlStateSelected];
		[self addTarget:aTarget action:aAction forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

+(NSArray*)arrayFromApplyType:(ApplyOrderButton*)btn FromDic:(NSDictionary*)dic
{
    if (isEmptyString(btn.applyListType)) {
        return nil;
    }
    return [[dic objectForKey:btn.applyListType]firstObject];
}

@end
