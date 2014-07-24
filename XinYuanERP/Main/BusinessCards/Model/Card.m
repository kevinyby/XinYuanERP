//
//  Card.m
//  Photolib
//
//  Created by bravo on 14-6-9.
//  Copyright (c) 2014年 bravo. All rights reserved.
//

#import "Card.h"

@implementation Card
@synthesize path, photo, thumb, name, isAlbum, password, thumb_path, date;

-(id)initWithPath:(NSURL*)apath thumb:(UIImage*)athumb thumbPath:(NSURL*)thumbPath name:(NSString*)aname password:(NSString*)apassword album:(BOOL)album{
    self= [super init];
    if (self){
        if ([apath isKindOfClass:[NSString class]]){
            //watch out for chinese problem
            NSString* validPath = [((NSString*)apath) stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            self.path = [NSURL URLWithString:validPath];
        }else{
            self.path = apath;
        }
        if ([thumbPath isKindOfClass:[NSString class]]){
            NSString* validPath = [((NSString*)thumbPath) stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            self.thumb_path = [NSURL URLWithString:validPath];
        }else{
            self.thumb_path = thumbPath;
        }
        
        self.thumb = athumb;
        self.isAlbum = album;
        self.name = aname;
        self.password = apassword;
        if (!self.isAlbum && self.path){
            self.photo = [MWPhoto photoWithURL:self.path];
        }
    }
    return self;
}

-(NSDictionary*) photoToDictionary{
    NSMutableDictionary* result = [[NSMutableDictionary alloc] init];
    [result setObject:self.name forKey:@"name"];
    [result setObject:[self.name description] forKey:@"date"];
    return result;
}

-(NSString*) localizedTitle{
    return self.name;
}

@end
