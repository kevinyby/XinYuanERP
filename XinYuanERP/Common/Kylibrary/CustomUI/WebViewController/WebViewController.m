//
//  WebViewController.m
//  XinYuanERP
//
//  Created by Xinyuan4 on 14-1-15.
//  Copyright (c) 2014年 Xinyuan4. All rights reserved.
//

/*测试的路径*/
static NSString *testUrl = @"ProductDescPDF";

#import "WebViewController.h"
#import "MBProgressHUD.h"
#import "AppInterface.h"

@interface WebViewController ()<UIWebViewDelegate>

@property(nonatomic,strong)UIWebView* webView;
@property(nonatomic,strong)NSString* loadingUrlString;

@end

@implementation WebViewController

- (id)initWithUrlString:(NSString*)aURL{
	if (self=[super init]) {
        self.loadingUrlString=aURL;
	}
	return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
	_webView =[[UIWebView alloc]initWithFrame:self.view.bounds];
    self.webView.delegate = self;
    self.webView.scalesPageToFit = YES;
    [self.view addSubview:self.webView];
    
    UIImage* cancelImage = [UIImage imageNamed:@"public_取消按钮.png"];
    UIButton* cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancelButton setImage:cancelImage forState:UIControlStateNormal];
    [cancelButton setImage:cancelImage forState:UIControlStateSelected];
    [cancelButton addTarget:self action:@selector(cancelAction:) forControlEvents:UIControlEventTouchUpInside];
    CGRect rect = CGRectMake(self.view.bounds.size.width - 50, 5, 40, 40);
    [cancelButton setFrame:rect];
    [self.view addSubview:cancelButton];
    
//    NSString* webloadingUrl = [NSString stringWithFormat:@"%@/%@",testUrl,self.loadingUrlString];
    [DATA.requester startDownloadRequest:IMAGE_URL(DOWNLOAD) parameters:@{@"PATH":self.loadingUrlString} completeHandler:^(HTTPRequester *requester, ResponseJsonModel *model, NSHTTPURLResponse *httpURLReqponse, NSError *error) {
        NSData* pdfData = model.binaryData;
        [self.webView loadData:pdfData MIMEType:@"application/pdf" textEncodingName:nil baseURL: nil];
        
    }];
    
}


#pragma mark -
#pragma mark - WebView
//- (void)webViewDidFinishLoad:(UIWebView *)webView {
//    [MBProgressHUD hideHUDForView:self.view animated:YES];
//}
//
//- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
//    [MBProgressHUD hideHUDForView:self.view animated:YES];
//}
//
//- (void)webViewDidStartLoad:(UIWebView *)webView {
//    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//    hud.mode = MBProgressHUDModeIndeterminate;
//    hud.labelText = @"Loading...";
//}

#pragma mark -
#pragma mark - Button Action
-(void)cancelAction:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
