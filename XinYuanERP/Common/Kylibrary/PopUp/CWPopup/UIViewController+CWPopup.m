//
//  UIViewController+CWPopup.m
//  CWPopupDemo
//
//  Copyright (c) 2013年 Xinyuan4. All rights reserved.
//

#import "UIViewController+CWPopup.h"
#import <objc/runtime.h>
#import <QuartzCore/QuartzCore.h>
#import <float.h>

#define ANIMATION_TIME 0.5f
#define STATUS_BAR_SIZE 22

NSString const *CWPopupKey = @"CWPopupkey";
NSString const *CWBlurViewKey = @"CWFadeViewKey";
NSString const *CWUseBlurForPopup = @"CWUseBlurForPopup";

@implementation UIViewController (CWPopup)

@dynamic popupViewController, useBlurForPopup;

#pragma mark - blur view methods

- (UIImage *)getScreenImage {
    // frame without status bar
    CGRect frame;
    if (UIDeviceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation)) {
        frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    } else {
        frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width);
    }
    
    UIGraphicsBeginImageContext(frame.size);
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    CGContextClipToRect(currentContext, frame);
    UIImage *screenshot = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return screenshot;
}


#pragma mark - present/dismiss

- (void)presentPopupViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)flag completion:(void (^)(void))completion {
    if (self.popupViewController == nil) {
        // initial setup
        self.popupViewController = viewControllerToPresent;
        self.popupViewController.view.autoresizesSubviews = NO;
        self.popupViewController.view.autoresizingMask = UIViewAutoresizingNone;
        [self.popupViewController viewWillAppear:YES];
        CGRect finalFrame = [self getPopupFrameForViewController:viewControllerToPresent];
        
        // blurview
        if (self.useBlurForPopup) {
//            [self addBlurView];
        } else {
            UIView *fadeView = [UIView new];
            if (UIDeviceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation)) {
                fadeView.frame = [UIScreen mainScreen].bounds;
            } else {
                fadeView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width);
            }
            fadeView.backgroundColor = [UIColor blackColor];
            fadeView.alpha = 0.0f;
            [self.view addSubview:fadeView];
            
            UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissPopup)];
            tapRecognizer.numberOfTapsRequired = 1;
            [fadeView addGestureRecognizer:tapRecognizer];
            
            objc_setAssociatedObject(self, &CWBlurViewKey, fadeView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
        UIView *blurView = objc_getAssociatedObject(self, &CWBlurViewKey);
        // setup
        if (flag) { // animate
            CGRect initialFrame = CGRectMake(finalFrame.origin.x, [UIScreen mainScreen].bounds.size.height + viewControllerToPresent.view.frame.size.height/2, finalFrame.size.width, finalFrame.size.height);
            viewControllerToPresent.view.frame = initialFrame;
            [self.view addSubview:viewControllerToPresent.view];
            [UIView animateWithDuration:ANIMATION_TIME delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                viewControllerToPresent.view.frame = finalFrame;
                blurView.alpha = self.useBlurForPopup ? 1.0f : 0.4f;
            } completion:^(BOOL finished) {
                [self.popupViewController viewDidAppear:YES];
                [completion invoke];
            }];
        } else { // don't animate
            [self.popupViewController viewDidAppear:YES];
            viewControllerToPresent.view.frame = finalFrame;
            [self.view addSubview:viewControllerToPresent.view];
            [completion invoke];
        }
        // if screen orientation changed
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(screenOrientationChanged) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    }
}

- (void)dismissPopupViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion {
    UIView *blurView = objc_getAssociatedObject(self, &CWBlurViewKey);
    [self.popupViewController viewWillDisappear:YES];
    if (flag) { // animate
        CGRect initialFrame = self.popupViewController.view.frame;
        [UIView animateWithDuration:ANIMATION_TIME delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.popupViewController.view.frame = CGRectMake(initialFrame.origin.x, [UIScreen mainScreen].bounds.size.height + initialFrame.size.height/2, initialFrame.size.width, initialFrame.size.height);
            // uncomment the line below to have slight rotation during the dismissal
            // self.popupViewController.view.transform = CGAffineTransformMakeRotation(M_PI/6);
            blurView.alpha = 0.0f;
        } completion:^(BOOL finished) {
            [self.popupViewController viewDidDisappear:YES];
            [self.popupViewController.view removeFromSuperview];
            [blurView removeFromSuperview];
            self.popupViewController = nil;
            [completion invoke];
        }];
    } else { 
        [self.popupViewController viewDidDisappear:YES];
        [self.popupViewController.view removeFromSuperview];
        [blurView removeFromSuperview];
        self.popupViewController = nil; 
        blurView = nil;
        [completion invoke];
    }
    // remove observer
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - handling screen orientation change

- (CGRect)getPopupFrameForViewController:(UIViewController *)viewController {
    
    return viewController.view.frame;

}

//- (void)screenOrientationChanged {
//    
//    UIView *blurView = objc_getAssociatedObject(self, &CWBlurViewKey);
//    [UIView animateWithDuration:ANIMATION_TIME animations:^{
//        self.popupViewController.view.frame = [self getPopupFrameForViewController:self.popupViewController];
//        if (UIDeviceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation)) {
//            blurView.frame = [UIScreen mainScreen].bounds;
//        } else {
//            blurView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width);
//        }
//        if (self.useBlurForPopup) {
//            [UIView animateWithDuration:1.0f animations:^{
//                // for delay
//            } completion:^(BOOL finished) {
//                [blurView removeFromSuperview];
//                // popup view alpha to 0 so its not in the blur image
//                self.popupViewController.view.alpha = 0.0f;
////                [self addBlurView];
//                self.popupViewController.view.alpha = 1.0f;
//                // display blurView again
//                UIView *blurView = objc_getAssociatedObject(self, &CWBlurViewKey);
//                blurView.alpha = 1.0f;
//            }];
//        }
//    }];
//}

/*--*/
- (void)dismissPopup {
    if (self.popupViewController != nil) {
        [self dismissPopupViewControllerAnimated:YES completion:^{
            NSLog(@"popup view dismissed");
        }];
    }
}
#pragma mark - popupViewController getter/setter

- (void)setPopupViewController:(UIViewController *)popupViewController {
    objc_setAssociatedObject(self, &CWPopupKey, popupViewController, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIViewController *)popupViewController {
    return objc_getAssociatedObject(self, &CWPopupKey);

}

- (void)setUseBlurForPopup:(BOOL)useBlurForPopup {
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0 && useBlurForPopup) {
        NSLog(@"ERROR: Blur unavailable prior to iOS 7");
        objc_setAssociatedObject(self, &CWUseBlurForPopup, [NSNumber numberWithBool:NO], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    } else {
        objc_setAssociatedObject(self, &CWUseBlurForPopup, [NSNumber numberWithBool:useBlurForPopup], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

- (BOOL)useBlurForPopup {
    NSNumber *result = objc_getAssociatedObject(self, &CWUseBlurForPopup);
    return [result boolValue];

}

@end
