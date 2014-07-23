//
//  DataProvider.h
//  Photolib
//
//  Created by bravo on 14-6-11.
//  Copyright (c) 2014年 bravo. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef void (^createAlbumCallback)(NSError* error, id current_data);
typedef void (^deleteItemCallback)(NSError* error, id current_data);

@protocol DataProvider <NSObject>

-(void)initiateWithComplete:(void(^)(NSError* error))callback;

-(NSDictionary*)dataWithPath:(NSString*)path;

-(NSArray*)photosArray;
-(NSDictionary*) currentLevelData;

-(NSString*)rootPath;

-(NSArray*)getAlbums;

-(NSArray*)getPhotos;

-(BOOL) hasPhotoInPath:(NSString*)path;
-(id) getPhotoInPath:(NSString*)path;

-(BOOL) hasAlbumInPath:(NSString*)path;
-(id) getAlbumInPath:(NSString*)path;

-(void) removeItemWithNames:(NSArray*)names complete:(deleteItemCallback)callback;

-(void) createAlbumAtPath:(NSString*)path name:(NSString*)name passwd:(NSString*)passwd complete:(createAlbumCallback)callback;

-(void) replaceItemAtPath:(NSString*)path toNewPath:(NSString*)newPath withData:(NSDictionary*)newData complete:(void(^)(NSError* error))callback;

-(void) moveItemWithName:(NSArray*)names
                  toPath:(NSString*)path
                complete:(void (^)(NSError* error))callback;

-(void) addPhotoAtPath:(NSString*)path withData:(NSData*)imageData complete:(void (^)(NSError* error, UIImage* image))callback;

@end