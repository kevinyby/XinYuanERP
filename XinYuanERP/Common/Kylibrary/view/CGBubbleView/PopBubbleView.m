//
//  PopBubbleView.m
//  XinYuanERP
//
//  Created by Xinyuan4 on 14-6-18.
//  Copyright (c) 2014年 Xinyuan4. All rights reserved.
//

#import "PopBubbleView.h"
#import "AppInterface.h"

@interface PopBubbleView()<CustomTableViewDelegate>

@end

@implementation PopBubbleView

void(^bubbleSelectedBlock)(NSInteger selectedIndex, NSString* selectedValue ) = nil;

+ (void)popCustomBubbleView:(UIView*)view keys:(NSArray*)array selectedBlock:(void(^)(NSInteger selectedIndex, NSString* selectedValue))doneBlock
{
    CGFloat bgHeight = 50*[array count];
    UIView* backgroundView = [[UIView alloc]init];
    [backgroundView setFrame:CGRectMake(0, 0, 100, bgHeight)];
    
    CMPopTipView* BubbleView = [[CMPopTipView alloc] initWithCustomView:backgroundView];
    BubbleView.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.3];
    
    BubbleView.animation = arc4random() % 2;
    [BubbleView presentPointingAtView:view inView:[ViewHelper getTopView] animated:YES];
    
    bubbleSelectedBlock = nil;
    bubbleSelectedBlock = doneBlock;
    
    JRTextFieldDidClickAction jrTxtFieldAction = ^void(JRTextField* jrTxtField){
        NSInteger selectIndex = jrTxtField.tag;
        NSString* selectedVal = [array objectAtIndex:selectIndex];
        if (bubbleSelectedBlock) bubbleSelectedBlock(selectIndex, selectedVal);
        bubbleSelectedBlock = nil;
        [BubbleView dismissAnimated:YES];
    };
    
    CGFloat subViewY = 5;
    for (int i = 0; i < [array count]; ++i) {
        JRTextField* txtField = [[JRTextField alloc]initWithFrame:CGRectMake(5, subViewY, 90, 40)];
        txtField.text = [array objectAtIndex:i];
        txtField.tag = i;
        [backgroundView addSubview:txtField];
        txtField.textFieldDidClickAction = jrTxtFieldAction;
        subViewY = subViewY + 50;
    }
    
}

+ (void)popTableBubbleView:(UIView*)view title:(NSString*)title dataSource:(NSArray*)source selectedBlock:(void(^)(NSInteger selectedIndex, NSString* selectedValue))doneBlock
{
    
    bubbleSelectedBlock = nil;
    bubbleSelectedBlock = doneBlock;
    
    UIView* backgroudView = [[UIView alloc] init];
    [backgroudView setFrame:[FrameTranslater convertCanvasRect:CGRectMake(0, 0, 200, 220)]];
    backgroudView.layer.borderWidth = 1.0f;
    backgroudView.layer.cornerRadius = 10.0f;
    backgroudView.clipsToBounds = TRUE;
    backgroudView.backgroundColor = [UIColor clearColor];
    
    UIView* titleView = [[UIView alloc] init];
    [titleView setFrame:[FrameTranslater convertCanvasRect:CGRectMake(0, 0, 200, 50)]];
    titleView.backgroundColor = [UIColor colorWithRed:38.0f/255.0f green:195.0f/255.0f blue:253.0f/255.0f alpha:1.0f];
    [backgroudView addSubview:titleView];
    
    UILabel* titleLabel = [[UILabel alloc] init];
    titleLabel.text = title;
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.font = TRANSLATEFONT(18);
    CGSize titleSize = [titleLabel.text sizeWithFont:[UIFont fontWithName:@"Arial" size:18]
                             constrainedToSize:CGSizeMake(MAXFLOAT, 30)];
    [FrameHelper setFrame:CGRectMake((200-titleSize.width)/2, 10, 80, 30) view:titleLabel];
    [titleView addSubview:titleLabel];
    
    TableViewCellBlock configureBlock = ^(UITableViewCell *cell , NSString* str) {
        cell.textLabel.text = str;
        cell.textLabel.font = TRANSLATEFONT(16);
        cell.backgroundColor = [UIColor clearColor];
    };
    TableViewCellHeightBlock heightBlock = ^CGFloat(){
        if (IS_IPHONE) return 25.0f;
        return 50.0f;
    };
    TableViewSelectCellBlock selectCellBlock = ^(NSIndexPath* index){
        NSInteger row = index.row;
        NSString* selectString = [source objectAtIndex:row];
        [AnimationView dismissAnimationView];
        if (bubbleSelectedBlock) {
            bubbleSelectedBlock(row,selectString);
        }
        bubbleSelectedBlock = nil;
    };
    CustomTableView* tableView = [[CustomTableView alloc]initWithDataSource:source CellBlock:configureBlock];
//    tableView.layer.borderWidth = 1.0f;
//    tableView.layer.cornerRadius = 10.0f;
//    tableView.clipsToBounds = TRUE;
    tableView.backgroundColor = [UIColor whiteColor];
    tableView.cellHeightBlock = heightBlock;
    tableView.cellSelectedBlock = selectCellBlock;
//    CGRect rect = [FrameTranslater convertCanvasRect:CGRectMake(0, 0, 200, 200)];
    CGRect tableRect = [FrameTranslater convertCanvasRect:CGRectMake(0, 50, 200, 170)];
    [tableView setFrame:tableRect];
    [backgroudView addSubview:tableView];
    
    [AnimationView presentAnimationView:backgroudView completion:nil];
    
//    [AnimationView presentAnimationView:tableView completion:nil];

}



@end
