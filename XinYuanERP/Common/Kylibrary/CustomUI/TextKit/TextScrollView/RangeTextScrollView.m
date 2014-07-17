//
//  RangeTextScrollView.m
//  XinYuanERP
//
//  Created by Xinyuan4 on 14-5-4.
//  Copyright (c) 2014年 Xinyuan4. All rights reserved.
//

#import "RangeTextScrollView.h"
#import "PlaceHolderTextView.h"

@implementation RangeTextScrollView

- (instancetype)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

-(void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    _deleteArray = [[NSMutableArray alloc] init];
}

#pragma mark -
#pragma mark - Handle Range

- (NSMutableArray*)changeRangeArray
{
    NSMutableArray* attributeArray = [NSMutableArray array];
    NSDictionary *attributeDict;
    NSRange effectiveRange = { 0, 0 };
    do {
        NSRange range;
        range = NSMakeRange (NSMaxRange(effectiveRange),[self.textStorage length] - NSMaxRange(effectiveRange));
        attributeDict = [self.textStorage attributesAtIndex: range.location
                                      longestEffectiveRange: &effectiveRange
                                                    inRange: range];
        if ([attributeDict count] == 2) {
            [attributeArray addObject:[NSValue valueWithRange:effectiveRange]];
        }
//            NSLog (@"Range: %@  Attributes: %@  Attributes Count: %d",
//                   NSStringFromRange(effectiveRange), attributeDict ,[attributeDict count]);
    } while (NSMaxRange(effectiveRange) < [self.textStorage length]);
    
    return attributeArray;
    
}

- (NSMutableArray*)deleteRangeArray
{
    NSMutableArray* mergeArray = ([self.deleteArray count] <= 1) ? [self.deleteArray mutableCopy] : [NSMutableArray array];

    int k = 0;
    for (int i = 0 ,j = 1; j < [self.deleteArray count]; ++i,++j) {
        NSRange rangePre = [[self.deleteArray objectAtIndex:i] rangeValue];
        NSRange rangeNext =[[self.deleteArray objectAtIndex:j] rangeValue];
        ++k;
        if (rangePre.location - rangeNext.location > 1) {
            [mergeArray addObject:[NSValue valueWithRange:NSMakeRange(rangePre.location, k)]];
            k = 0;
        }
        if (j == [self.deleteArray count] -1) {
            [mergeArray addObject:[NSValue valueWithRange:NSMakeRange(rangeNext.location, k+1)]];
        }
    }
    
    if ([self.deleteArray count]>1) {
        NSMutableArray* adjustArray = [NSMutableArray array];
        for (int last = [mergeArray count]-1; last >=0; --last) {
            NSRange lastRange = [[mergeArray objectAtIndex:last] rangeValue];
            for (int j = 0; j<last; j++) {
                NSRange range = [[mergeArray objectAtIndex:j] rangeValue];
                if (range.location > lastRange.location ) {
                    range.location = range.location - lastRange.length;
                    [mergeArray replaceObjectAtIndex:j withObject:[NSValue valueWithRange:range]];
                }
            }
            [adjustArray addObject:[NSValue valueWithRange:lastRange]];
            
        }
        [mergeArray removeAllObjects];
        [mergeArray addObjectsFromArray:adjustArray];
        
    }
    
    return mergeArray;
}


-(NSArray *)sortedRangeArray
{
    NSMutableArray* changeRange = [self changeRangeArray];
    NSMutableArray* deleteRange = [self deleteRangeArray];
    NSMutableArray* deleteSortedRange = [NSMutableArray array];
    for (id key in deleteRange) {
        NSRange range = [key rangeValue] ;
        range.length = 0 ;
        [deleteSortedRange addObject:[NSValue valueWithRange:range]];
    }
    NSMutableArray* allRangeArray = [NSMutableArray array];
    [allRangeArray addObjectsFromArray:changeRange];
    [allRangeArray addObjectsFromArray:deleteSortedRange];
    
    NSComparator cmptr = ^(id obj1, id obj2){
        if ([obj1 rangeValue].location > [obj2 rangeValue].location) {
            return (NSComparisonResult)NSOrderedDescending;
        }
        
        if ([obj1 rangeValue].location < [obj2 rangeValue].location) {
            return (NSComparisonResult)NSOrderedAscending;
        }
        return (NSComparisonResult)NSOrderedSame;
    };
    
    NSArray *sortedRangeArray = [allRangeArray sortedArrayUsingComparator:cmptr];
    
    return sortedRangeArray;
    
}

#pragma mark -
#pragma mark - Handle RegExp

- (NSString*)setRegExpTag
{

    NSArray* sortedRangeArray = [self changeRangeArray];
//    NSLog(@"sortedRangeArray====%@",sortedRangeArray);
    NSMutableString* textString = [self.textStorage mutableString];
    NSUInteger accumulate = 0;
    for (int i = 0; i < [sortedRangeArray count]; ++i) {
        NSRange range = [[sortedRangeArray objectAtIndex:i] rangeValue];
        
        [textString insertString:@"</>" atIndex:range.location + accumulate];
        accumulate += 3;
        [textString insertString:@"</>" atIndex:range.location + range.length + accumulate];
        accumulate += 3;

    }
    return textString;
}


- (NSString*)filterRegExpTag:(NSString*)string
{
    static NSRegularExpression *iExpression;
    iExpression = iExpression ?: [NSRegularExpression regularExpressionWithPattern:@"\\</>\\w+\\n*\\</>" options:0 error:NULL];
    
    NSMutableArray* rangeMutArray = [NSMutableArray array];
    [iExpression enumerateMatchesInString:string options:0 range:NSMakeRange(0, string.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        
        NSLog(@"NSStringFromRange(result.range) === %@",NSStringFromRange(result.range));
        NSLog(@"[self.string substringWithRange:result.range] === %@",[string substringWithRange:result.range]);
        [rangeMutArray addObject:[NSValue valueWithRange:result.range]];
    }];
    
    NSMutableString* mutString = [string mutableCopy];
    NSMutableArray* regExpMutArray = [NSMutableArray array];
    int accumalate = 0;
    int taglen = 3;
    for (int i = 0; i< [rangeMutArray count]; ++i) {
        NSRange range = [[rangeMutArray objectAtIndex:i] rangeValue];
        [regExpMutArray addObject:[NSValue valueWithRange:NSMakeRange(range.location + accumalate, range.length - taglen*2)]];
        [mutString deleteCharactersInRange:NSMakeRange(range.location + accumalate,taglen)];
        accumalate -= taglen;
        [mutString deleteCharactersInRange:NSMakeRange(range.location + accumalate + range.length - taglen,taglen)];
        accumalate -= taglen;
    }
    self.textStorage.regExpArray = regExpMutArray;
    return mutString;
}

#pragma mark -
#pragma mark - UITextView Delegate
-(void)textViewDidBeginEditing:(UITextView *)textView
{
    self.textStorage.dynamicUpdate = YES;
    [super textViewDidBeginEditing:textView];
}

-(void)textViewDidEndEditing:(UITextView *)textView
{
    self.textStorage.dynamicUpdate = NO;
    [super textViewDidEndEditing:textView];

}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if (range.length == 1) [self.deleteArray addObject:[NSValue valueWithRange:range]];//delete character

    return YES;
}


@end
