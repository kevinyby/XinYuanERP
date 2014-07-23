//
//  ArrayDataSource.h
//  Photolib
//
//  Created by bravo on 14-6-9.
//  Copyright (c) 2014年 bravo. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef void (^CollectionViewCellConfigureBlock)(id cell, id item);

@interface DictionaryDataSource : NSObject<UICollectionViewDataSource>

-(id) initWithItems:(NSDictionary*)anItems
     cellIdentifier:(NSArray*)cellIdentifilers
 configureCellBlock:(CollectionViewCellConfigureBlock)aConfigureBlock;

-(void) updateItems:(NSDictionary*)anItems;

-(id) itemAtIndex:(NSIndexPath*)indexPath;

@end
