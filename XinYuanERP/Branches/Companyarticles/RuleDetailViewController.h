//
//  RuleDetailViewController.h
//  XinYuanERP
//
//  Created by Xinyuan4 on 13-9-9.
//  Copyright (c) 2013年 Xinyuan4. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RotateViewController.h"

@interface RuleDetailViewController : RotateViewController<UIWebViewDelegate,UIPrintInteractionControllerDelegate>
{
     UIWebView* _webView;
     NSURL  *_loadingURL;
     UIBarButtonItem* rightItem;
}

- (id)initWithURL:(NSURL*)aURL;
@end
