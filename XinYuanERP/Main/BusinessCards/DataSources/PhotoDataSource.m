//
//  PhotoDataSource.m
//  Photolib
//
//  Created by bravo on 14-6-14.
//  Copyright (c) 2014年 bravo. All rights reserved.
//

#import "PhotoDataSource.h"

@interface PhotoDataSource()

@property (nonatomic,strong) NSArray* photoArray;

@end

@implementation PhotoDataSource

-(id) initWithItems:(NSArray*)photos{
    self = [super init];
    if (self){
        self.photoArray = [NSArray arrayWithArray:photos];
    }
    return self;
}

-(void) updateItems:(NSArray *)items{
    self.photoArray = items;
}

#pragma mark - MWDataSource
-(NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser{
    return self.photoArray.count;
}

-(id<MWPhoto>) photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index{
    return [self.photoArray objectAtIndex:index];
}

@end
