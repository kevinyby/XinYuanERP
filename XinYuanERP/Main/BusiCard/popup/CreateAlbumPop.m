//
//  CreateAlbumPop.m
//  XinYuanERP
//
//  Created by bravo on 13-11-1.
//  Copyright (c) 2013年 Xinyuan4. All rights reserved.
//

#import "CreateAlbumPop.h"

@interface CreateAlbumPop(){
    UITextField* nameBox;
    UITextField* passwordBox;
}
@end

@implementation CreateAlbumPop

-(id) initWithContentSize:(CGRect)frame{
    self = [super initWithContentSize:CGRectMake(0, 0, 200, 170)];
    if (self){
        UILabel* title = [[UILabel alloc] initWithFrame:CGRectMake(40, 5, content.frame.size.width, 20)];
        title.text = @"新名片夹名称";
        
        nameBox = [[UITextField alloc] initWithFrame:CGRectMake(10, 30, content.frame.size.width-20, 30)];
        nameBox.borderStyle = UITextBorderStyleRoundedRect;
        nameBox.delegate = self;
        
        UILabel* title2 = [[UILabel alloc] initWithFrame:CGRectMake(40, 70, content.frame.size.width, 20)];
        title2.text = @"密码（选填）";
        passwordBox = [[UITextField alloc] initWithFrame:CGRectMake(10, 95, content.frame.size.width-20, 30)];
        passwordBox.borderStyle = UITextBorderStyleRoundedRect;
        [passwordBox setSecureTextEntry:YES];
        passwordBox.delegate = self;
        
        [content addSubview:title];
        [content addSubview:nameBox];
        [content addSubview:title2];
        [content addSubview:passwordBox];
    }
    return self;
}

-(void) confirmAction{
    if (self.confirmBlock){
        NSString* real_name = [nameBox.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        NSDictionary* data = @{@"albumName":real_name,
                               @"albumPassword":(passwordBox.text==nil?@"":passwordBox.text)};
        self.confirmBlock(self,data);
    }
}

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [super touchesBegan:touches withEvent:event];
    [nameBox resignFirstResponder];
    [passwordBox resignFirstResponder];
}
@end
