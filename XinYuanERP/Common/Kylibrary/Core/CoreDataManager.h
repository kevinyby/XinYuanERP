//
//  CoreDataManager.h
//  XinYuanERP
//
//  Created by Xinyuan4 on 14-7-12.
//  Copyright (c) 2014年 Xinyuan4. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CoreDataManager : NSObject

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

+ (instancetype)sharedInstance;

- (void)saveContext;

@end
