//
//  SpineMidReadingViewController.h
//  XinYuanERP
//
//  Created by Xinyuan4 on 14-5-4.
//  Copyright (c) 2014年 Xinyuan4. All rights reserved.
//

#import "JsonController.h"
@class PageViewController;
@interface SpineMidReadingViewController : JsonController<UIPageViewControllerDataSource,UIPageViewControllerDelegate,UIGestureRecognizerDelegate>
{
    int _leftPage;
    int _rightPage;
    BOOL _leftFlip;
    BOOL _rightFlip;
    
    int _totalPages;
    int _charsPerPage;
    int _textLength;
    int _charsOfLastPage;
    
    UIFont* _preferredFont;
    NSRange* _rangeOfPages;
}

@property(nonatomic,strong)UIPageViewController * pageController;
@property(nonatomic,strong)NSMutableAttributedString* content;

- (void)initPageController;
- (void)loadPageView;

@end
