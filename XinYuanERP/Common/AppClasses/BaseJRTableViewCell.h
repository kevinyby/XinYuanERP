//
//  BaseJRTableViewCell.h
//  XinYuanERP
//
//  Created by Xinyuan4 on 14-6-21.
//  Copyright (c) 2014年 Xinyuan4. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BaseJRTableViewCell;
typedef void(^DidEndEditNewCellAction) (BaseJRTableViewCell* cell);

@interface BaseJRTableViewCell : UITableViewCell

@property (copy) DidEndEditNewCellAction didEndEditNewCellAction;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier ;


-(void) setDatas: (NSMutableDictionary*)array;

-(NSMutableDictionary*)getDatas;


-(NSDictionary*)assembleCellSpecifications:(NSString*)order;

-(void)renderCellSubView:(NSString*)order;

@end
