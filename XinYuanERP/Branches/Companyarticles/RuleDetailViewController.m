//
//  RuleDetailViewController.m
//  XinYuanERP
//
//  Created by Xinyuan4 on 13-9-9.
//  Copyright (c) 2013年 Xinyuan4. All rights reserved.
//

#import "RuleDetailViewController.h"
#import "AppInterface.h"

@interface RuleDetailViewController ()


@end

@implementation RuleDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithURL:(NSURL*)aURL{
	if (self=[super initWithNibName:nil bundle:nil]) {
//		[self openURL:aURL];
        _loadingURL=aURL;
	}
	return self;
}

- (void)dealloc
{
    _webView.delegate = nil;
    
    
     
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.view.backgroundColor=[UIColor whiteColor];
    
    
    
    rightItem =[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(printAction:)];
    self.navigationItem.rightBarButtonItem=rightItem;
    
    _webView =[[UIWebView alloc]initWithFrame:self.view.bounds];
    _webView.delegate = self;
    _webView.scalesPageToFit = YES;
    [self.view addSubview:_webView];
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:_loadingURL];
    [_webView loadRequest:request];
    
}

// for ios5.0 , 6.0 deprecated
-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return ((toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft)||(toInterfaceOrientation == UIInterfaceOrientationLandscapeRight));
}

-(NSUInteger) supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscape;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationLandscapeLeft ;
}

// for ios6.0 supported
-(BOOL) shouldAutorotate {
    return YES ;//YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)printAction:(id)sender
{
    float pdfWidth = 612.0f;
    float pdfHeight = 792.0f;
    
    MyPrintPageRender *myRenderer = [[MyPrintPageRender alloc] init];
    UIViewPrintFormatter *viewFormatter = [_webView viewPrintFormatter];
    [myRenderer addPrintFormatter:viewFormatter startingAtPageAtIndex:0];
    
    NSData *pdfData = [myRenderer convertUIWebViewToPDFsaveWidth: pdfWidth saveHeight:pdfHeight];

//    NSString *path = [[NSBundle mainBundle] pathForResource:@"公司简介01" ofType:@"pdf"];
//    NSURL *url = [NSURL fileURLWithPath:path];
   
	UIPrintInteractionController *pic = [UIPrintInteractionController sharedPrintController];
    if(!pic){
        LOG(@"Couldn't get shared UIPrintInteractionController!");
        return;
    }
    
    if  (pic && [UIPrintInteractionController canPrintData:pdfData] ) {
        
		pic.delegate = self;
		
        UIPrintInfo *printInfo = [UIPrintInfo printInfo];
        printInfo.outputType = UIPrintInfoOutputGeneral;
//        printInfo.jobName = [path lastPathComponent];
        printInfo.duplex = UIPrintInfoDuplexLongEdge;
        pic.printInfo = printInfo;
        pic.showsPageRange = YES;
        pic.printingItem = pdfData;
		
        void (^completionHandler)(UIPrintInteractionController *, BOOL, NSError *) = ^(UIPrintInteractionController *pic, BOOL completed, NSError *error) {
            
			if (!completed && error)
				NSLog(@"FAILED! due to error in domain %@ with error code %u",error.domain, error.code);
        };
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
			[pic presentFromBarButtonItem:rightItem animated:YES completionHandler:completionHandler];
        } else {
			[pic presentAnimated:YES completionHandler:completionHandler];
            [_webView setFrame:self.view.bounds];
            
		}
	}

}
@end
