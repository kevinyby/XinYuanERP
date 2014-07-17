//
//  PageView.h
//  Reader
//
//  Created by Xinyuan4 on 14-4-14.
//  Copyright (c) 2014年 Xinyuan4. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TextStorage;

@interface PageView : UIView

@property (strong, nonatomic) UITextView *textView;
@property (nonatomic, strong) TextStorage *textStorage;

@end
