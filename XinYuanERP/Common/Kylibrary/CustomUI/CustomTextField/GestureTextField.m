//
//  GestureTextField.m
//  XinYuanERP
//
//  Created by Xinyuan4 on 14-4-10.
//  Copyright (c) 2014年 Xinyuan4. All rights reserved.
//

#import "GestureTextField.h"

@interface GestureTextField ()
{
    UIView* _tapView;
}

@end

@implementation GestureTextField

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

-(void)setTextFieldTapAction:(GestureTapAction)textFieldTapAction
{
    _textFieldTapAction = textFieldTapAction;
    
    if (textFieldTapAction) {
        if (_tapView) {
            [_tapView removeFromSuperview];
            _tapView = nil;
        }
        _tapView = [[UIView alloc] initWithFrame: self.frame];
        UITapGestureRecognizer* tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget: self action:@selector(tapAction:)];
        [_tapView addGestureRecognizer: tapGestureRecognizer];
        [self.superview addSubview: _tapView];
        
      }
    
}

-(void) tapAction: (UITapGestureRecognizer *)tapGesture {
    if (self.textFieldTapAction) self.textFieldTapAction(self);
}


@end
