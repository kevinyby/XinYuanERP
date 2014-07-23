//
//  SearchPhotosViewController.h
//  Photolib
//
//  Created by bravo on 14-6-28.
//  Copyright (c) 2014年 bravo. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SearchPhotosViewController;
@protocol SearchPhotosDelegate <NSObject>

-(void) searchPhotoController:(SearchPhotosViewController*)controller didSelectItem:(id)item;
-(void) searchPhotoController:(SearchPhotosViewController*)controller dismissedWithJumpPath:(NSString*)path;

@end

@interface SearchPhotosViewController : UIViewController
@property(nonatomic,strong) id<SearchPhotosDelegate> delegate;
@end
