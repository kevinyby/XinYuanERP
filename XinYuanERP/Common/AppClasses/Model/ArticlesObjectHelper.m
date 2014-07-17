//
//  ArticlesObjectHelper.m
//  XinYuanERP
//
//  Created by Xinyuan4 on 14-7-12.
//  Copyright (c) 2014年 Xinyuan4. All rights reserved.
//

#import "ArticlesObjectHelper.h"
#import "Articles.h"
#import "CoreDataManager.h"

@implementation ArticlesObjectHelper

+ (void)insertManagedObject:(NSDictionary*)object
{
    Articles* newArticles = [NSEntityDescription insertNewObjectForEntityForName:ArticlesTable inManagedObjectContext:[self managedObjectContex]];
    newArticles.title = object[Article_Title];
    newArticles.articles = object[Article_Articles];
    newArticles.editor = object[Article_Editor];
    NSError *error;
    if(![[self managedObjectContex] save:&error])
    {
        NSLog(@"can not save：%@",[error localizedDescription]);
    }
}

+ (void)deleteManagedObject:(NSString*)editor
{
    NSEntityDescription *entity = [NSEntityDescription entityForName:ArticlesTable inManagedObjectContext:[self managedObjectContex]];
    
    NSFetchRequest *request = [self fetchRequest:[self managedObjectContex] predicate:editor];
    [request setIncludesPropertyValues:NO];
    [request setEntity:entity];
    NSError *error = nil;
    NSArray *fetchedObjects = [[self managedObjectContex] executeFetchRequest:request error:&error];
    if (!error && fetchedObjects && [fetchedObjects count])
    {
        for (NSManagedObject *obj in fetchedObjects)
        {
            [[self managedObjectContex] deleteObject:obj];
        }
        if (![[self managedObjectContex] save:&error])
        {
            NSLog(@"error:%@",error);
        }
    }
    
}

+ (void)updateManagedObject:(NSDictionary*)object
{
    NSFetchRequest * request =  [self fetchRequest:[self managedObjectContex] predicate:object[Article_Editor]];
    
    NSError* error = nil;
    NSArray* result = [[self managedObjectContex] executeFetchRequest:request error:&error];
    
    if ([result count] == 0 || result == nil) {
        
        [self insertManagedObject:object];
        
    }else{
        
        Articles* article = [result lastObject];
        article.title = object[Article_Title];
        article.articles = object[Article_Articles];
        article.editor = object[Article_Editor];
        
        if ([[self managedObjectContex] save:&error]) {
            NSLog(@"update success");
        }
        
    }
    
}

+ (NSArray*)fetchManagedObject:(NSString*)editor
{
    NSEntityDescription *entity = [NSEntityDescription entityForName:ArticlesTable inManagedObjectContext:[self managedObjectContex]];
    
    NSFetchRequest *request = [self fetchRequest:[self managedObjectContex] predicate:editor];
    [request setEntity:entity];
    NSError *error = nil;
    NSArray *fetchedObjects = [[self managedObjectContex] executeFetchRequest:request error:&error];
    if (error) {
         NSLog(@"fetchManagedObject error：%@",[error localizedDescription]);
    }
    return fetchedObjects;
}


+ (NSFetchRequest*)fetchRequest:(NSManagedObjectContext*)moc predicate:(NSString*)pred
{
    NSPredicate *predicate = [NSPredicate
                              predicateWithFormat:@"editor like[cd] %@",pred];
    
    NSFetchRequest * request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:ArticlesTable inManagedObjectContext:moc]];
    [request setPredicate:predicate];
    
    return request;
}

+(NSManagedObjectContext*)managedObjectContex
{
    return [[CoreDataManager sharedInstance] managedObjectContext];
}


@end
