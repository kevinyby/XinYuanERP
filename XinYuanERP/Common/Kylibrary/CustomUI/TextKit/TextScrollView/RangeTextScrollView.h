//
//  RangeTextScrollView.h
//  XinYuanERP
//
//  Created by Xinyuan4 on 14-5-4.
//  Copyright (c) 2014年 Xinyuan4. All rights reserved.
//

#import "TextScrollView.h"

@interface RangeTextScrollView : TextScrollView

@property (nonatomic, strong) NSMutableArray* deleteArray;

- (NSMutableArray*)changeRangeArray;
- (NSMutableArray*)deleteRangeArray;
- (NSArray*)sortedRangeArray;
- (NSString*)setRegExpTag;
- (NSString*)filterRegExpTag:(NSString*)string;
@end
