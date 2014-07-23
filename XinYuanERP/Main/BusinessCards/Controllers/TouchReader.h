//
//  TouchReader.h
//  Photolib
//
//  Created by bravo on 14-7-16.
//  Copyright (c) 2014年 bravo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MagnifierView.h"

@interface TouchReader : UIView{
    NSTimer *touchTimer;
    MagnifierView* loop;
}

@property (nonatomic, retain) NSTimer* touchTimer;

-(void) addLoop;
-(void) handleAction:(id) timerObj;

@end
