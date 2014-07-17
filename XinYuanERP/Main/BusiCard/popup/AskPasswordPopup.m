//
//  AskPasswordPopup.m
//  XinYuanERP
//
//  Created by bravo on 13-10-29.
//  Copyright (c) 2013年 Xinyuan4. All rights reserved.
//

#import "AskPasswordPopup.h"
@interface AskPasswordPopup(){
    UILabel* title;
}
@end

@implementation AskPasswordPopup
@synthesize password;
@synthesize done;
@synthesize cancel;

-(id) initWithContentSize:(CGRect)frame{
    self = [super initWithContentSize:CGRectMake(0, 0, 200, 130)];
    if (self){
        title = [[UILabel alloc] initWithFrame:CGRectMake((self.center.x - content.frame.origin.x)/2, 0, content.frame.size.width, 40)];
        title.text = @"请输入密码";
        [content addSubview:title];
        
        passwordBox = [[UITextField alloc] initWithFrame:CGRectMake(10, 45, content.frame.size.width-20, 25)];
        passwordBox.borderStyle = UITextBorderStyleRoundedRect;
        passwordBox.delegate = self;
        passwordBox.secureTextEntry = YES;
        [content addSubview:passwordBox];
        [passwordBox becomeFirstResponder];
    }
    return self;
}

-(void) confirmAction{
    password = [NSString stringWithString:passwordBox.text];
    passwordBox.text = @"";
    
    if (self.confirmBlock){
        self.confirmBlock(self,@{@"password":password});
    }
}

/* override this method cuz we want to dismiss the keyboard. */
-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [super touchesBegan:touches withEvent:event];
    [passwordBox resignFirstResponder];
}

-(void) showTip:(NSString *)msg{
    title.text = msg;
    title.tintColor = [UIColor redColor];
}


@end
