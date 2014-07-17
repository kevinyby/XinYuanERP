//
//  TextStorage.m
//  Reader
//
//  Created by Xinyuan4 on 14-4-14.
//  Copyright (c) 2014年 Xinyuan4. All rights reserved.
//

#import "TextStorage.h"

@interface TextStorage ()

@end

@implementation TextStorage

// initial
-(id)init
{
    self = [super init];
    if (self) {
        _storingText = [[NSMutableAttributedString alloc] init];
    }
    return self;
}

-(NSString *)string
{
    return [_storingText string];
}

// 获取指定范围内的文字属性
-(NSDictionary *)attributesAtIndex:(NSUInteger)location effectiveRange:(NSRangePointer)range
{
    return [_storingText attributesAtIndex:location effectiveRange:range];
}

// Must override NSMutableAttributedString primitive method
// 设置指定范围内的文字属性
-(void)setAttributes:(NSDictionary *)attrs range:(NSRange)range
{
    [self beginEditing];
    [_storingText setAttributes:attrs range:range];
    [self edited:NSTextStorageEditedAttributes range:range changeInLength:0];
    [self endEditing];
}

// 修改指定范围内的文字
-(void)replaceCharactersInRange:(NSRange)range withString:(NSString *)str
{
    [self beginEditing];
    [_storingText replaceCharactersInRange:range withString:str];
    [self edited:NSTextStorageEditedAttributes | NSTextStorageEditedCharacters range:range changeInLength:str.length - range.length];
    [self endEditing];

}

- (void)processEditing
{
    if (self.dynamicUpdate && self.editTextStatus) {
        
        NSDictionary *attrsDic = @{NSForegroundColorAttributeName: [UIColor redColor]};
        [_storingText setAttributes:attrsDic range:self.editedRange];
        
    }else if (self.regExp){
        
        if ([_regExpArray count]!=0) {
            for (id object in _regExpArray) {
                NSRange range = [object rangeValue];
                [self addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:range];
            }
        }
    }
    
    [super processEditing];
    
}

-(void)setRegExpArray:(NSMutableArray *)regExpArray
{
    if (!_regExpArray) {
        _regExpArray = [NSMutableArray array];
    }
    [_regExpArray addObjectsFromArray:regExpArray];
}


@end
