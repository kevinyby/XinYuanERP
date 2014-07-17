//
//  PlaceHolderTextView.m
//  XinYuanERP
//
//  Created by Xinyuan4 on 14-7-14.
//  Copyright (c) 2014年 Xinyuan4. All rights reserved.
//

#import "PlaceHolderTextView.h"

@interface PlaceHolderTextView()


@end

@implementation PlaceHolderTextView


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
   
}


- (id)init
{
    self = [super init];
    if (self) {
        
        [self setPlaceholderSetting];
    }
    return self;
}

-(void)setPlaceholderSetting
{
    [self setPlaceholder:@""];
    [self setPlaceholderColor:[UIColor lightGrayColor]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChanged:) name:UITextViewTextDidChangeNotification object:nil];
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    if([_placeholder length] > 0) {
        if (!_placeHolderLabel) {
            _placeHolderLabel = [[UILabel alloc] initWithFrame:CGRectMake(5,8,self.bounds.size.width,0)];
            if (NSFoundationVersionNumber <= NSFoundationVersionNumber_iOS_6_1) {
                _placeHolderLabel.frame = CGRectMake(7,9,self.bounds.size.width,0);
            }
            _placeHolderLabel.lineBreakMode = NSLineBreakByWordWrapping;
            _placeHolderLabel.numberOfLines = 0;
            _placeHolderLabel.font = [UIFont systemFontOfSize:14];
            _placeHolderLabel.backgroundColor = [UIColor clearColor];
            _placeHolderLabel.textColor = _placeholderColor;
            [self addSubview:_placeHolderLabel];
        }
        
        _placeHolderLabel.text = self.placeholder;
        [_placeHolderLabel sizeToFit];
        [self sendSubviewToBack:_placeHolderLabel];
    }
}

- (void)textChanged:(NSNotification *)notification
{
    if([self.placeholder length] > 0) {
        self.placeHolderLabel.hidden = ([self.text length] > 0);
    }
}

@end
