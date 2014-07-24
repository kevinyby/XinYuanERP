//
//  ExportArrayDataSource.h
//  Photolib
//
//  Created by bravo on 14-6-20.
//  Copyright (c) 2014年 bravo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WDSearchTableView.h"

typedef void (^TableViewCellConfigureBlock)(id cell, id item);

@interface ExportArrayDataSource : NSObject<UITableViewDataSource>

//reference to target tableview
@property(nonatomic,strong) WDSearchTableView* target;

-(id) initWithItems:(NSArray*)aitems
     cellIdentifier:(NSString*)cellIndentifier
 configureCellBlock:(TableViewCellConfigureBlock)aConfigureBlock;

-(void) setObjects:(NSArray *)objects;

-(id) itemAtIndex:(NSIndexPath*)indexPath;

-(id) itemAtSearchResult:(NSIndexPath*)indexPath;

-(void) filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope;




@end
