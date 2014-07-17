//
//  CoreDataManager.m
//  XinYuanERP
//
//  Created by Xinyuan4 on 14-7-12.
//  Copyright (c) 2014年 Xinyuan4. All rights reserved.
//

#import "CoreDataManager.h"


@implementation CoreDataManager

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

+(instancetype)sharedInstance
{
    static CoreDataManager* sharedCoreDataManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedCoreDataManager = [[CoreDataManager alloc] init];
    });
    return sharedCoreDataManager;
}

#pragma mark -
#pragma mark - Core Data Stack
-(NSManagedObjectContext*)managedObjectContext
{
    if (_managedObjectContext!=nil) {
        return _managedObjectContext;
    }
    
    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    if (self.persistentStoreCoordinator) {
        [_managedObjectContext setPersistentStoreCoordinator:self.persistentStoreCoordinator];
    }
    
    return _managedObjectContext;
}

-(NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel!=nil) {
        return _managedObjectModel;
    }
    NSURL* modelURL = [[NSBundle mainBundle] URLForResource:@"Models" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

-(NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator!=nil) {
        return _persistentStoreCoordinator;
    }
    
    NSString* storeType = NSSQLiteStoreType;
    NSString* storeName = @"Models.sqlite";
    NSError* error = NULL;
    NSURL* storeURL = [NSURL fileURLWithPath:[[self applicationDocumentsDirectory] stringByAppendingPathComponent:storeName]];
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];
    [_persistentStoreCoordinator addPersistentStoreWithType:storeType configuration:nil URL:storeURL options:nil error:&error];
    if (error) {
        NSLog(@"Error : %@\n", [error localizedDescription]);
        NSAssert1(YES, @"Failed to create store %@ with NSSQLiteStoreType", [storeURL path]);
    }
    
    
    return _persistentStoreCoordinator;
}

#pragma mark -
#pragma mark Application's Documents Directory

- (NSString *)applicationDocumentsDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return basePath;
}


#pragma mark -
#pragma mark - Save Context

-(void)saveContext
{
    NSError* error = NULL;
    NSManagedObjectContext* managedObjectContext = self.managedObjectContext;
    if (managedObjectContext && [managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
        NSLog(@"Error %@,%@",error,[error localizedDescription]);
        abort();
    }
    
}

@end
