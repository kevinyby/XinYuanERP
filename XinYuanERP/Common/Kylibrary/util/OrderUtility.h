//
//  OrderUtility.h
//  XinYuanERP
//
//  Copyright (c) 2014年 Xinyuan4. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OrderUtility : NSObject

+ (float)localizeStrCompareCNStr:(NSString*)Ostring category:(NSString*)category fontSize:(CGFloat)size;

+ (NSString*)applyListTypeMediator:(NSString*)applyType;

+ (NSData*)imageDataCompress:(UIImage*)image;
+ (NSData*)imageTransformData:(UIImage*)image compressSize:(float)size;

+ (void)tapGestureAdd:(UIView*)view inClass:(id)viewClass forAction:(SEL)classAction;

+ (NSMutableArray*)localizeArray:(NSArray*)array withOrder:(NSString*)order;



@end
