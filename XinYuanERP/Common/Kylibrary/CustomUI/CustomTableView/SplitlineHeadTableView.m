//
//  SplitlineHeadTableView.m
//  XinYuanERP
//
//  Created by Xinyuan4 on 14-2-9.
//  Copyright (c) 2014年 Xinyuan4. All rights reserved.
//

#import "SplitlineHeadTableView.h"
#import "AppInterface.h"


@implementation SplitlineHeadTableView


-(void)setSplitlineXcoordinates:(NSArray *)splitlineXcoordinates
{
    int count = splitlineXcoordinates.count;
    for (int i = 0; i < count; i++) {
        
        float splitX = [[splitlineXcoordinates objectAtIndex:i]floatValue];
        
//        DBLOG(@"self.height======%f",self.height);
//        DBLOG(@" self.originHeight======%f", self.originHeight);
        
        SpliceImageView* spliceView = [[SpliceImageView alloc]init];
        spliceView.topImage = IMAGEINIT(@"WHPurchase_线顶部.png");
        spliceView.midImage = IMAGEINIT(@"WHPurchase_线中部.png");
        spliceView.bottomImage = IMAGEINIT(@"WHPurchase_线底部.png");
     
        
        spliceView.frame = CGRectMake([FrameTranslater convertCanvasX:splitX], 0, [FrameTranslater convertCanvasWidth:4], self.frame.size.height);
        [self addSubview:spliceView];
        
        
//        [Utility parent:self add:spliceView rect:XYWH(splitX, 0, 4, self.originHeight)];
        
    }
    
}





@end
