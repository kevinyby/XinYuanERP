//
//  Articles.h
//  XinYuanERP
//
//  Created by Xinyuan4 on 14-7-12.
//  Copyright (c) 2014年 Xinyuan4. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Articles : NSManagedObject

@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * articles;
@property (nonatomic, retain) NSString * editor;


@end
