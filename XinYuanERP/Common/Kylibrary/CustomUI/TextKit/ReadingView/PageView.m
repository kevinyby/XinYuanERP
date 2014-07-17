//
//  PageView.m
//  Reader
//
//  Created by Xinyuan4 on 14-4-14.
//  Copyright (c) 2014年 Xinyuan4. All rights reserved.
//

#import "PageView.h"
#import "AppInterface.h"

@implementation PageView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

        CGRect textViewRect = CGRectMake([FrameTranslater convertCanvasX:20], [FrameTranslater convertCanvasY:10], frame.size.width-[FrameTranslater convertCanvasWidth:60], frame.size.height);
        
        NSTextContainer *container = [[NSTextContainer alloc] initWithSize:CGSizeMake(textViewRect.size.width, CGFLOAT_MAX)];
        container.widthTracksTextView = YES;
        
        NSLayoutManager *layoutManager = [[NSLayoutManager alloc] init];
        [layoutManager addTextContainer:container];
        
        _textStorage = [[TextStorage alloc] init];
        [self.textStorage addLayoutManager:layoutManager];
    
        UITextView *newTextView            = [[UITextView alloc] initWithFrame:textViewRect textContainer:container];
        newTextView.autoresizingMask       = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        newTextView.keyboardDismissMode    = UIScrollViewKeyboardDismissModeOnDrag;
        newTextView.dataDetectorTypes      = UIDataDetectorTypeAll;
        newTextView.backgroundColor        = [UIColor colorWithRed:247.0f/255.0f green:247.0f/255.0f blue:247.0f/255.0f alpha:1.0f];//[UIColor clearColor];
        newTextView.hidden                 = NO;
        newTextView.editable               = NO;
        newTextView.userInteractionEnabled = NO;
        self.textView                      = newTextView;
        [self addSubview:self.textView];
    

    }
    return self;
}


@end
