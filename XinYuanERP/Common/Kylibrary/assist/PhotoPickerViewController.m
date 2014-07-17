//
//  PhotoPickerViewController.m
//  XinYuanERP
//
//  Created by Xinyuan4 on 13-9-22.
//  Copyright (c) 2013年 Xinyuan4. All rights reserved.
//

#import "PhotoPickerViewController.h"
#import "AppInterface.h"

@interface PhotoPickerViewController ()

@end

@implementation PhotoPickerViewController

- (id)init
{
    self = [super init];
    if (self) {
        self.allowsEditing = YES;
        self.sourceType = UIImagePickerControllerSourceTypeCamera;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//// for ios5.0 , 6.0 deprecated
//-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
//{
//    return ((toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft)||(toInterfaceOrientation == UIInterfaceOrientationLandscapeRight));
//}
//
//-(NSUInteger) supportedInterfaceOrientations {
//    if (IS_IPHONE) {
////        return UIInterfaceOrientationMaskLandscape;
//        return UIInterfaceOrientationMaskPortrait;
//        
//    }
//    return UIInterfaceOrientationMaskAll;
////   return UIInterfaceOrientationMaskPortrait;
//}
//
////- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
////    if (IS_IPHONE) {
////        return UIInterfaceOrientationPortrait|UIInterfaceOrientationPortraitUpsideDown;
////    }
//////    return UIInterfaceOrientationPortrait|UIInterfaceOrientationPortraitUpsideDown;
////    return UIInterfaceOrientationLandscapeLeft;
////}
//
//// for ios6.0 supported
//-(BOOL) shouldAutorotate {
//    return YES ;//YES;
//}

@end
