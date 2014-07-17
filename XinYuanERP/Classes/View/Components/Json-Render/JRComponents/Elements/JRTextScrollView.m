//
//  JRTextScrollView.m
//  XinYuanERP
//
//  Created by Xinyuan4 on 14-4-29.
//  Copyright (c) 2014年 Xinyuan4. All rights reserved.
//

#import "JRTextScrollView.h"
#import "AppInterface.h"

@implementation JRTextScrollView{
    NSString* _attribute ;
}

#pragma mark - JRComponentProtocal Methods

-(void) initializeComponents: (NSDictionary*)config
{
}

-(NSString*) attribute
{
    return _attribute;
}

-(void) setAttribute: (NSString*)attribute
{
    _attribute = attribute;
}


-(void) subRender: (NSDictionary*)dictionary {
    
    self.textView.font = [JsonViewHelper getFontWithConfig: dictionary];
}


-(id) getValue {
    return self.textView.text;
}

-(void) setValue: (id)value {
    self.textView.text = value;
}



@end
