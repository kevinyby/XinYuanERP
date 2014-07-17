//
//  BaseJRTableViewCell.m
//  XinYuanERP
//
//  Created by Xinyuan4 on 14-6-21.
//  Copyright (c) 2014年 Xinyuan4. All rights reserved.
//

#import "BaseJRTableViewCell.h"
#import "AppInterface.h"

@implementation BaseJRTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}


#pragma mark -
#pragma mark - Render
-(NSDictionary*)assembleCellSpecifications:(NSString*)order
{
    NSString* controllerSuffix = json_FILE_CONTROLLER_SUFIX;
    NSString* controllerFileName = [order stringByAppendingString:controllerSuffix];
    NSMutableDictionary* cellSpecifications = [DictionaryHelper deepCopy: [JsonFileManager getJsonFromFile: controllerFileName]];
    NSDictionary* specConfig = cellSpecifications[@"Specifications"];
    return specConfig;
}

-(void)renderCellSubView:(NSString*)order
{
    NSDictionary* specConfig = [self assembleCellSpecifications:order];
    for (int i = 0; i < self.contentView.subviews.count; i++) {
        NSArray* frame = [specConfig[@"TableCellElementsFrames"] safeObjectAtIndex: i];
        JRTextField* jrTxtField = (JRTextField*)[self.contentView.subviews objectAtIndex: i];
        [FrameHelper setComponentFrame: frame component:jrTxtField];
        // subRender
        if ([jrTxtField conformsToProtocol:@protocol(JRComponentProtocal)]) {
            [((id<JRComponentProtocal>)jrTxtField) subRender: [specConfig[@"TableCellElementsSubRenders"] safeObjectAtIndex: i]];
        }
        // attribute
        [jrTxtField setAttribute:[specConfig[@"TableCellElementsAttribute"] safeObjectAtIndex: i]];
    }
}


#pragma mark -
#pragma mark - Handle

-(void)setDatas:(NSMutableDictionary *)dic
{
    [ViewHelper iterateSubView: self.contentView class:[JRTextField class] handler:^BOOL(id subView) {
        JRTextField* tx = (JRTextField*)subView;
        id value = [dic objectForKey: tx.attribute];
        [tx setValue: value];
        return NO;
    }];
}

-(NSMutableDictionary*)getDatas
{
    NSMutableDictionary* values = [NSMutableDictionary dictionary];
    
    [ViewHelper iterateSubView: self.contentView class:[JRTextField class] handler:^BOOL(id subView) {
        JRTextField* tx = (JRTextField*)subView;
        id value = [tx getValue];
        NSString* key = tx.attribute;
        if (value && key) {
            [values setObject: value forKey:key];
        }
        return NO;
    }];
    
    return values;
    
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
