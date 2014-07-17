//
//  TextScrollView.h
//  XinYuanERP
//
//  Created by Xinyuan4 on 14-4-29.
//  Copyright (c) 2014年 Xinyuan4. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TextStorage.h"

@class PlaceHolderTextView;

@interface TextScrollView : UIScrollView<UITextViewDelegate>

@property (nonatomic, strong) PlaceHolderTextView* textView;
@property (nonatomic, strong) TextStorage* textStorage;

@end
