//
//  PhotoCell.h
//  Photolib
//
//  Created by bravo on 14-6-10.
//  Copyright (c) 2014年 bravo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "itemCell.h"

@interface PhotoCell : itemCell
@property (weak, nonatomic) IBOutlet UIImageView *thumb;
@property (weak, nonatomic) IBOutlet UILabel *label;
@end
