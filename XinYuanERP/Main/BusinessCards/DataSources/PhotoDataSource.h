//
//  PhotoDataSource.h
//  Photolib
//
//  Created by bravo on 14-6-14.
//  Copyright (c) 2014年 bravo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MWPhotoBrowser.h"

@interface PhotoDataSource : NSObject<MWPhotoBrowserDelegate>

-(id) initWithItems:(NSArray*)photos;

-(void) updateItems:(NSArray*)items;

@end
