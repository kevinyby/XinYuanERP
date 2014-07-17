//
//  BubbleMenuItem.h
//  bubbleMenu
//
//  Created by bravo on 14-4-18.
//  Copyright (c) 2014年 bravo. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BubbleMenuItemDelegate;

@interface BubbleMenuItem : UIImageView{
    UIImageView* contentImageView;
}

@property (nonatomic) CGPoint position;
@property (nonatomic,strong) NSString* title;
@property (nonatomic,strong) UILabel* titleLabel;
@property (nonatomic, assign) id<BubbleMenuItemDelegate> delegate;

-(id) initWithImage:(UIImage *)img
              title:(NSString*)tstr
   highlightedImage:(UIImage *)himg
       contentImage:(UIImage *)cimg
hightedContentImage:(UIImage *)hcimg;

@end

@protocol BubbleMenuItemDelegate <NSObject>

-(void) bubbleMenuItemTouchesBegan:(BubbleMenuItem *)item;
-(void) bubbleMenuItemTouchesEnd:(BubbleMenuItem *)item;

@end
