//
//  EditableCell.h
//  XinYuanERP
//
//  Created by bravo on 13-12-20.
//  Copyright (c) 2013年 Xinyuan4. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITableViewCell (ButtonCell)
/**
 *  Set visiablity for a specific view in contentView for tablecell
 *
 *  @param visiable visiable or not
 *  @param viewType kind of view
 */
-(void)setVisiable:(BOOL)visiable type:(id)viewType;

@end

@class EditableCell;
@protocol EditCellProtocol <NSObject>

@optional
-(void) editCell:(EditableCell*)cell didBeginEditingAtIndexPath:(NSIndexPath*)indexPath;
-(void) editCell:(EditableCell*)cell didEndEditingAtIndexPath:(NSIndexPath*)indexPath;
-(void) editCellDidPressReturnOnCell:(EditableCell*)cell;
-(void)adjustHeightForCell:(EditableCell*)cell;

@end

@interface EditableCell : UITableViewCell<UITextViewDelegate>

@property (nonatomic,strong) id<EditCellProtocol> delegate;
@property (nonatomic,strong) NSIndexPath* indexPath;
@property (nonatomic,strong) UITextView *input;

-(id)getContent;

@end

