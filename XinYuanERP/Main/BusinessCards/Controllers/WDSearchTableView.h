//
//  WDSearchTableView.h
//  Photolib
//
//  Created by bravo on 14-6-24.
//  Copyright (c) 2014年 bravo. All rights reserved.
//

#import <UIKit/UIKit.h>
@class WDSearchTableView;
@protocol WDSearchTableViewDelegate <NSObject>

-(void) wdsearchview:(WDSearchTableView*)searchview didSelectWithItem:(id)item;

@end

@interface WDSearchTableView : UITableViewController

@property(nonatomic,strong) id<WDSearchTableViewDelegate> delegate;
@end
