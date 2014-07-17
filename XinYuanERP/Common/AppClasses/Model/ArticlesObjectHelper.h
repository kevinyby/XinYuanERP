//
//  ArticlesObjectHelper.h
//  XinYuanERP
//
//  Created by Xinyuan4 on 14-7-12.
//  Copyright (c) 2014年 Xinyuan4. All rights reserved.
//

#import <Foundation/Foundation.h>

#define ArticlesTable    @"Articles"
#define Article_Title    @"title"
#define Article_Articles @"articles"
#define Article_Editor   @"editor"

@class Articles;

@interface ArticlesObjectHelper : NSObject

+ (void)insertManagedObject:(NSDictionary*)object;


+ (void)deleteManagedObject:(NSString*)editor;


+ (void)updateManagedObject:(NSDictionary*)object;


+ (NSArray*)fetchManagedObject:(NSString*)editor;


@end
