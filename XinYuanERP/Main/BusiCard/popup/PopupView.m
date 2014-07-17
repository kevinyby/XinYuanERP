//
//  PopupView.m
//  XinYuanERP
//
//  Created by bravo on 13-10-29.
//  Copyright (c) 2013年 Xinyuan4. All rights reserved.
//

#import "PopupView.h"
#import <QuartzCore/QuartzCore.h>

@implementation PopupView
@synthesize cancel;
@synthesize done;
@synthesize delegate;
@synthesize confirmBlock;
@synthesize cancleBlock;

+(PopupView*) popWithType:(Class)type
                  confirm:(PopupViewConfirmBlock)confirm
                   cancel:(PopupViewCancelBlock)cancel{
    PopupView* view = [((PopupView*)[type alloc]) initWithContentSize:CGRectZero];
    view.confirmBlock = confirm;
    view.cancleBlock = cancel;
    return view;
}

-(id) initWithContentSize:(CGRect)frame{
    self = [super init];
    if (self){
        self.frame = CGRectMake(0, 0,
                                [UIScreen mainScreen].bounds.size.width,
                                [UIScreen mainScreen].bounds.size.height);
        self.alpha = 0.0f;
        self.backgroundColor = [UIColor clearColor];
        mask = [[UIView alloc] initWithFrame:self.frame];
        mask.backgroundColor = [UIColor blackColor];
        mask.alpha = 0.0f;
        [self addSubview:mask];
        content = [[UIToolbar alloc] initWithFrame:frame];
        content.center = self.center;
        content.backgroundColor = [UIColor whiteColor];
        content.layer.cornerRadius = 6;
        content.layer.masksToBounds = YES;
        content.layer.borderWidth = 0.5f;
        content.layer.borderColor = [[UIColor lightGrayColor] CGColor];
        [self addSubview:content];
        
        self.cancel = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        self.cancel.frame = CGRectMake(0, frame.size.height-30, frame.size.width/2, 30);
        [self.cancel setTitle:@"取消" forState:UIControlStateNormal];
        [self.cancel addTarget:self action:@selector(cancelAction) forControlEvents:UIControlEventTouchUpInside];
        [content addSubview:self.cancel];
        
        self.done = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        self.done.frame = CGRectMake(frame.size.width/2, frame.size.height-30, frame.size.width/2, 30);
        [self.done setTitle:@"确认" forState:UIControlStateNormal];
        [self.done addTarget:self action:@selector(confirmAction) forControlEvents:UIControlEventTouchUpInside];
        [content addSubview:self.done];
    }
    return self;
}

-(void) cancelAction{
    if (self.delegate != nil &&
        [self.delegate conformsToProtocol:@protocol(PopupViewDelegate)]&&
        [self.delegate respondsToSelector:@selector(didCancel)]){
            [self.delegate didCancel];
    }
    else{
        //delegate is not work? try block
        if (self.cancleBlock){
            self.cancleBlock(self);
        }
    }
    [self dismissWithAnimate:YES];
}

-(void) confirmAction{
    if (self.delegate != nil &&
        [self.delegate conformsToProtocol:@protocol(PopupViewDelegate)] &&
        [self.delegate respondsToSelector:@selector(didConfirm)]){
            [self.delegate didConfirm];
    }
    [self dismissWithAnimate:YES];
}

-(void) showWithAnimate:(BOOL)animate{
    if (animate){
        [UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.30];
		self.alpha = 1.0f;
        mask.alpha = 0.5f;
		[UIView commitAnimations];
    }
    else{
        self.alpha = 1.0f;
    }
}

-(void) dismissWithAnimate:(BOOL)animate{
    if (animate){
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.30];
        self.alpha = 0.0f;
        [UIView commitAnimations];
        
        [self performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:0.3];
    }else{
        [self removeFromSuperview];
    }
}

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    content.center = CGPointMake(self.center.x, self.center.y);
    [UIView commitAnimations];
}

-(void) textFieldDidBeginEditing:(UITextField *)textField{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    content.center = CGPointMake(self.center.x, self.center.y-80);
    [UIView commitAnimations];
}


@end
