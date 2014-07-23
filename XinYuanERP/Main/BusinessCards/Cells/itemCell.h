//
//  itemCell.h
//  Photolib
//
//  Created by bravo on 14-6-16.
//  Copyright (c) 2014年 bravo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Card.h"
#import "BrowserViewCotroller.h"
#import "UIImageView+WebCache.h"

@interface itemCell : UICollectionViewCell
@property(nonatomic,weak) BrowserViewCotroller* browserController;
@property(nonatomic) NSUInteger index;

-(void) configreCell:(Card *)data;

@end
