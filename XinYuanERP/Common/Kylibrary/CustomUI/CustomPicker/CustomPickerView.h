//
//  CustomPickerView.h
//  XinYuanERP
//
//  Created by Xinyuan4 on 14-1-22.
//  Copyright (c) 2014年 Xinyuan4. All rights reserved.
//

#import "AbstractActionSheetPicker.h"

@interface CustomPickerView : AbstractActionSheetPicker

@property(nonatomic, assign) NSInteger selectedOneIndex;
@property(nonatomic, assign) NSInteger selectedTwoIndex;

+(id) popupPicker: (id)sender keys:(NSArray*)keys doneBlock:(void(^)(id sender, unsigned int selectedIndex, NSString* selectedVisualValue ))doneBlock;

+ (id)showPicker:(id)sender title:(NSString *)title pickerDataSource:(id)dataSource doneBlock:(void(^)(NSInteger selectedIndex, NSString* selectedValue))doneBlock;

+ (id)showCustomPickerWithTitle:(NSString *)title pickerDataSource:(id)dataSource target:(id)target successAction:(SEL)successAction cancelAction:(SEL)cancelAction origin:(id)origin;

- (id)initWithTitle:(NSString *)title pickerDataSource:(id)dataSource target:(id)target successAction:(SEL)successAction cancelAction:(SEL)cancelAction origin:(id)origin ;

@end
