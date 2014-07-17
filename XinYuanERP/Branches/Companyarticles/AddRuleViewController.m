//
//  AddRuleViewController.m
//  XinYuanERP
//
//  Created by Xinyuan4 on 13-9-9.
//  Copyright (c) 2013年 Xinyuan4. All rights reserved.
//

#import "AddRuleViewController.h"
#import "AppInterface.h"

@interface AddRuleViewController ()

@end

@implementation AddRuleViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.view.backgroundColor=[UIColor whiteColor];
    
    CGRect canvas = CGRectMake(0, 0, SHORT_IPAD, LONG_IPAD-100);
    [FrameHelper setFrame: canvas view:self.view];
    ((UIScrollView*)self.view).contentSize =  self.view.frame.size;
    
    ruleTxtView=[[UITextView alloc]init];
    [ruleTxtView setFrame:self.view.bounds];
    ruleTxtView.delegate=self;
    ruleTxtView.font=[UIFont fontWithName:@"Arial" size:[FrameTranslater convertFontSize:20]];
    [self.view addSubview:ruleTxtView];
    
    [ruleTxtView becomeFirstResponder];
   
}


- (void)textViewDidChange:(UITextView *)textView
{
     LOG(@"textViewDidChange");
//    NSLog(@"ruleTxtView.selectedRange.location==%d",ruleTxtView.selectedRange.location);
//    NSLog(@"ruleTxtView.contentSize.height==%f",ruleTxtView.contentSize.height);
     CGSize currentResize = [ruleTxtView.text sizeWithFont: ruleTxtView.font];
     NSLog(@"currentResize.height==%f",currentResize.height);
    NSLog(@"currentResize.width==%f",currentResize.width);
    
    if (ruleTxtView.contentSize.height>=((UIScrollView*)self.view).contentSize.height-216-(currentResize.height*2)) {
        CGSize currentResize = [ruleTxtView.text sizeWithFont: ruleTxtView.font];
        

        ((UIScrollView*)self.view).contentSize =  CGSizeMake(self.view.frame.size.width, ((UIScrollView*)self.view).contentSize.height+currentResize.height);
        CGRect ViewRect=self.view.frame;
        ViewRect.size.height=((UIScrollView*)self.view).contentSize.height;
        [((UIScrollView*)self.view) scrollRectToVisible:ViewRect animated:YES];

    }
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
