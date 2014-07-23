//
//  Card.h
//  Photolib
//
//  Created by bravo on 14-6-9.
//  Copyright (c) 2014年 bravo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MWPhoto.h"

@interface Card : NSObject

@property(nonatomic,strong)NSURL* path;
@property(nonatomic,strong)MWPhoto* photo;
@property(nonatomic,strong)UIImage* thumb;
@property(nonatomic,strong)NSURL* thumb_path;
@property(nonatomic,strong)NSString* name;
@property(nonatomic,strong)NSString* password;
@property(nonatomic,assign)BOOL isAlbum;
@property(nonatomic,strong) NSDate* date;

-(id)initWithPath:(NSURL*)path thumb:(UIImage*)image thumbPath:(NSURL*)thumbPath name:(NSString*)name password:(NSString*)apassword album:(BOOL)album;

-(NSDictionary*) photoToDictionary;

-(NSString*) localizedTitle;

@end
