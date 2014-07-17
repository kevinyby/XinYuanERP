//
//  BubbleMenu.h
//  bubbleMenu
//
//  Created by bravo on 14-4-18.
//  Copyright (c) 2014年 bravo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BubbleMenuItem.h"

@protocol BubbleMenuDelegate;


@interface BubbleMenu : UIView<BubbleMenuItemDelegate>{
    BubbleMenuItem* start;
    int _flag;
    NSTimer *_timer;
}

@property (nonatomic, copy) NSArray *menusArray;
@property (nonatomic, assign) BOOL expanding;
@property (nonatomic, assign) id<BubbleMenuDelegate> delegate;

-(id) initWithFrame:(CGRect)frame menus:(NSArray*)menus;

-(void) setTitle:(NSString*)str;

@end

@protocol BubbleMenuDelegate <NSObject>

-(void)bubbleMenu:(BubbleMenu*)menu didSelectAtIndex:(NSInteger)idx;

@end
