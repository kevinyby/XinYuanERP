//
//  TextScrollView.m
//  XinYuanERP
//
//  Created by Xinyuan4 on 14-4-29.
//  Copyright (c) 2014年 Xinyuan4. All rights reserved.
//

#import "TextScrollView.h"
#import "AppInterface.h"

@implementation TextScrollView

- (id)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

-(void)setFrame:(CGRect)frame
{
    if ((frame.size.width - 0) < 1e-9 &&
        (frame.size.height - 0) < 1e-9) return;
    [super setFrame: frame];
    [self initSubViews:frame];
}


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

    }
    return self;
}

-(void)initSubViews:(CGRect)frame
{
    CGRect textViewRect = frame;
    textViewRect.origin.x = 0;
    textViewRect.origin.y = 0;
    NSTextContainer *container = [[NSTextContainer alloc] initWithSize:CGSizeMake(textViewRect.size.width, CGFLOAT_MAX)];
    container.widthTracksTextView = YES;
    
    NSLayoutManager *layoutManager = [[NSLayoutManager alloc] init];
    [layoutManager addTextContainer:container];
    
    _textStorage = [[TextStorage alloc] init];
    [self.textStorage addLayoutManager:layoutManager];
    
    _textView = [[PlaceHolderTextView alloc] initWithFrame:textViewRect textContainer:container];
    [_textView setPlaceholderSetting];
    self.textView.backgroundColor        = [UIColor clearColor];
    self.textView.hidden                 = NO;
    self.textView.editable               = YES;
    self.textView.userInteractionEnabled = YES;
    self.textView.selectable             = YES;
    self.textView.delegate               = self;
    [self.textView setToolBar];
    [ColorHelper setBorder:self.textView];
    [self addSubview:self.textView];
    
     
}

-(void)textViewDidBeginEditing:(UITextView *)textView
{
    NSLog(@"textViewDidBeginEditing");
    UIScrollView* scrollView = (UIScrollView*)textView.superview;
    scrollView.scrollEnabled = YES;
    CGRect viewRect=textView.frame;
    [scrollView scrollRectToVisible:viewRect animated:YES];
}

-(void)textViewDidEndEditing:(UITextView *)textView
{
    NSLog(@"textViewDidEndEditing");
    UIScrollView* scrollView = (UIScrollView*)textView.superview;
    scrollView.scrollEnabled = NO;
    CGRect viewRect=scrollView.frame;
    viewRect.origin.y = 0;
    [scrollView scrollRectToVisible:viewRect animated:YES];
    
}

- (void)textViewDidChange:(UITextView *)textView
{
    UIScrollView* scrollView = (UIScrollView*)textView.superview;
    CGSize textlinesize = [textView.text sizeWithFont: textView.font];
    
    int gap = IS_IPHONE ? 168 : 306;
    if (textView.contentSize.height>=scrollView.contentSize.height - gap) {
        
        scrollView.contentSize =  CGSizeMake(scrollView.frame.size.width, scrollView.contentSize.height+textlinesize.height);
        CGRect viewRect=scrollView.frame;
        viewRect.size.height=scrollView.contentSize.height;
        [scrollView scrollRectToVisible:viewRect animated:YES];
        
        if (textView.contentSize.height >= textView.frame.size.height) {
            CGRect articlesRect = textView.frame;
            articlesRect.size = textView.contentSize;
            textView.frame = articlesRect;
        }
    }

}


@end
