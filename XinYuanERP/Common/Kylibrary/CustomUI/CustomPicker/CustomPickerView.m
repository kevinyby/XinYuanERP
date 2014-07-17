//
//  CustomPickerView.m
//  XinYuanERP
//
//  Created by Xinyuan4 on 14-1-22.
//  Copyright (c) 2014年 Xinyuan4. All rights reserved.
//

#import "CustomPickerView.h"
#import "AbstractActionSheetPicker.h"
#import "LocalizeHelper.h"

@interface CustomPickerView()<UIPickerViewDelegate, UIPickerViewDataSource>

@property(nonatomic, strong) id pickerDataSource;

@property(nonatomic, assign) NSInteger rows;

@end


@implementation CustomPickerView


#pragma mark - Block Action

void(^currentDoneBlock)(id sender, unsigned int selectedIndex, NSString* selectedValue ) = nil;

+(id) popupPicker: (id)sender keys:(NSArray*)keys doneBlock:(void(^)(id sender, unsigned int selectedIndex, NSString* selectedVisualValue ))doneBlock
{
    currentDoneBlock = doneBlock;
    return [CustomPickerView showCustomPickerWithTitle:@"" pickerDataSource:[LocalizeHelper localize: keys] target:self successAction:@selector(pickerWasSelected:element:) cancelAction:nil origin:sender];
}
+(void)pickerWasSelected:(NSString *)selectedVal element:(id)element
{
    CustomPickerView* picker = [element firstObject];
    id sender = [element lastObject];
    int selectIndex = picker.selectedOneIndex;
    if (currentDoneBlock) currentDoneBlock(sender, selectIndex, selectedVal);
    currentDoneBlock = nil;
}

void(^selectedBlock)(NSInteger selectedIndex, NSString* selectedValue ) = nil;

+ (id)showPicker:(id)sender title:(NSString *)title pickerDataSource:(id)dataSource doneBlock:(void(^)(NSInteger selectedIndex, NSString* selectedValue))doneBlock
{
    selectedBlock = doneBlock;
    return [CustomPickerView showCustomPickerWithTitle:title pickerDataSource:dataSource target:self successAction:@selector(pickerSelectedValue:element:) cancelAction:nil origin:sender];
}
+(void)pickerSelectedValue:(NSString *)selectedVal element:(id)element
{
    CustomPickerView* picker = [element firstObject];
    int selectIndex = picker.selectedOneIndex;
    if (selectedBlock) selectedBlock(selectIndex, selectedVal);
    selectedBlock = nil;
}


#pragma mark - Target Action

+ (id)showCustomPickerWithTitle:(NSString *)title pickerDataSource:(id)dataSource target:(id)target successAction:(SEL)successAction cancelAction:(SEL)cancelAction origin:(id)origin {
    CustomPickerView *picker = [[CustomPickerView alloc] initWithTitle:title pickerDataSource:dataSource target:target successAction:successAction cancelAction:cancelAction origin:origin];
    [picker showActionSheetPicker];
    return picker;
}


- (id)initWithTitle:(NSString *)title pickerDataSource:(id)dataSource target:(id)target successAction:(SEL)successAction cancelAction:(SEL)cancelAction origin:(id)origin {
    self = [super initWithTarget:target successAction:successAction cancelAction:cancelAction origin:origin];
    if (self) {
        self.rows = [self getRows:dataSource];
        self.title = title;
        self.pickerDataSource = dataSource;
    }
    return self;
}

- (UIView *)configuredPickerView {
    if (!self.pickerDataSource) return nil;
    CGRect pickerFrame = CGRectMake(0, 40, self.viewSize.width, 216);
    UIPickerView *stringPicker = [[UIPickerView alloc] initWithFrame:pickerFrame];
    stringPicker.delegate = self;
    stringPicker.dataSource = self;
    stringPicker.showsSelectionIndicator = YES;
    
    self.pickerView = stringPicker;
    return stringPicker;
}

#pragma mark -
#pragma mark - NotifyTarget
- (void)notifyTarget:(id)target didSucceedWithAction:(SEL)successAction origin:(id)origin {
    if (target && [target respondsToSelector:successAction]) {
        NSString* pickerString = nil;
        if (self.rows == 1) {
            NSArray* pickerSource = (NSArray*)self.pickerDataSource;
            if (pickerSource.count) pickerString = [pickerSource objectAtIndex:self.selectedOneIndex];
        }else{
            NSDictionary* dictionary = (NSDictionary*)self.pickerDataSource;
            NSString* key = [[dictionary allKeys]objectAtIndex:self.selectedOneIndex];
            NSString* val = [(NSArray*)[dictionary objectForKey:key] count] == 0 ? @" ": [[dictionary objectForKey:key] objectAtIndex:self.selectedTwoIndex];
            pickerString = [NSString stringWithFormat:@"%@,%@",key,val];
        }
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [target performSelector:successAction withObject:pickerString withObject:@[self, origin]];
#pragma clang diagnostic pop
        
    }
    
}

- (void)notifyTarget:(id)target didCancelWithAction:(SEL)cancelAction origin:(id)origin {
    if (target && cancelAction && [target respondsToSelector:cancelAction]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [target performSelector:cancelAction withObject:@[self, origin]];
#pragma clang diagnostic pop
    }
}


#pragma mark -
#pragma mark - UIPickerViewDelegate / DataSource
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
    if (self.rows == 1) {
        
        self.selectedOneIndex = row;
        
    }
    else{
        if (component == 0) {
            self.selectedOneIndex = row;
            [pickerView reloadComponent:1];
        }
        if (component == 1) {
            self.selectedTwoIndex = row;
        }
    }
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return self.rows;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    NSArray *keyArray = [self getCurrentComponentKey:component];
    return keyArray ? [keyArray count] : 0;
    
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    NSArray *keyArray = [self getCurrentComponentKey:component];
    return keyArray ? [keyArray objectAtIndex:(NSUInteger) row] : @"";
}


#pragma mark -
- (NSInteger)getRows:(id)obj {
    
    if ([obj isKindOfClass:[NSArray class]] || [obj isKindOfClass:[NSMutableArray class]]) return 1;
    
    if ([obj isKindOfClass:[NSDictionary class]] || [obj isKindOfClass:[NSMutableDictionary class]]) return 2;
    
    return 1;
}

- (id)getCurrentComponentKey:(NSInteger)component {
    
    if (self.rows == 1) {
        return self.pickerDataSource;
    }else{
        NSDictionary* dictionary = (NSDictionary*)self.pickerDataSource;
        if (component == 0) {
            return [dictionary allKeys];
        }else if (component == 1){
            return [dictionary objectForKey:[[dictionary allKeys] objectAtIndex:self.selectedOneIndex]];
        }
    }
    return nil;
}


@end
