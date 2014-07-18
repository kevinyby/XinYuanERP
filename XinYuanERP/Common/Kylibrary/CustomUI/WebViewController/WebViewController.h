//
//  WebViewController.h
//  XinYuanERP
//
//  Created by Xinyuan4 on 14-1-15.
//  Copyright (c) 2014年 Xinyuan4. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RotateViewController.h"


#define PDF_PREFIX @"PDF/"

#define PRODUCTPDF_PREFIX @"ProductPDF/"
#define PRODUCTPDF_PREFIXPATH [PDF_PREFIX stringByAppendingString: PRODUCTPDF_PREFIX]
#define PRODUCTPDF_PATH(_SUFFIX) [PRODUCTPDF_PREFIXPATH stringByAppendingString:_SUFFIX]

#define CONTRACTPDF_PREFIX @"ContractPDF/"
#define CONTRACTPDF_PREFIXPATH [PDF_PREFIX stringByAppendingString: CONTRACTPDF_PREFIX]
#define CONTRACTPDF_PATH(_SUFFIX) [CONTRACTPDF_PREFIXPATH stringByAppendingString:_SUFFIX]

@interface WebViewController : RotateViewController

- (id)initWithUrlString:(NSString*)aURL;

@end
