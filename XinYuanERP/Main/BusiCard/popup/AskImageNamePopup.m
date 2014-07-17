//
//  AskImageNamePopup.m
//  XinYuanERP
//
//  Created by bravo on 13-11-6.
//  Copyright (c) 2013年 Xinyuan4. All rights reserved.
//

#import "AskImageNamePopup.h"

@interface AskImageNamePopup(){
    UITextField* nameBox;
}

@end

@implementation AskImageNamePopup

- (id)initWithContentSize:(CGRect)frame
{
    self = [super initWithContentSize:CGRectMake(0, 0, 200, 130)];
    if (self) {
        UILabel* title = [[UILabel alloc] initWithFrame:CGRectMake((self.center.x - content.frame.origin.x)/2, 0, content.frame.size.width, 40)];
        title.text = @"请输入名称";
        
        nameBox = [[UITextField alloc] initWithFrame:CGRectMake(10, 45, content.frame.size.width-20, 25)];
        nameBox.borderStyle = UITextBorderStyleRoundedRect;
        nameBox.delegate = self;
        
        [content addSubview:title];
        [content addSubview:nameBox];
        [nameBox becomeFirstResponder];
    }
    return self;
}

-(void) confirmAction{
    NSString* name = nameBox.text;
    if (self.confirmBlock){
        self.confirmBlock(self,@{@"imageName":name});
    }
}

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [super touchesBegan:touches withEvent:event];
    [nameBox resignFirstResponder];
}

@end
