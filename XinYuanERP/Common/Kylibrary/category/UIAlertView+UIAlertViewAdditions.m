//
//  UIAlertView+UIAlertViewAdditions.m
//  XinYuanERP
//
//  Copyright (c) 2013年 Xinyuan4. All rights reserved.
//

#import "UIAlertView+UIAlertViewAdditions.h"

static DismissBlock _dismissBlock;
static CancelBlock  _cancelBlock;
static EnsureBlock  _ensureBlock;

@implementation UIAlertView (UIAlertViewAdditions)


+ (UIAlertView*) alertViewWithTitle:(NSString*) title
                            message:(NSString*) message
                  cancelButtonTitle:(NSString*) cancelButtonTitle
                  ensureButtonTitle:(NSString*) ensureButtonTitle
                           onCancel:(CancelBlock) cancelled
                           onEnsure:(EnsureBlock) ensure{
    
    _cancelBlock  = [cancelled copy];
    _ensureBlock  = [ensure copy];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:[self class]
                                          cancelButtonTitle:cancelButtonTitle
                                          otherButtonTitles:ensureButtonTitle,nil];
    
    [alert show];
    return alert;
}

+ (UIAlertView*) alertViewWithTitle:(NSString*) title
                            message:(NSString*) message
                  cancelButtonTitle:(NSString*) cancelButtonTitle
                  otherButtonTitles:(NSArray*) otherButtons
                           subViews:(NSArray*) subViews
                          onDismiss:(DismissBlock) dismissed
                           onCancel:(CancelBlock) cancelled {
    _cancelBlock   = [cancelled copy];
    _dismissBlock  = [dismissed copy];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:[self class]
                                          cancelButtonTitle:cancelButtonTitle
                                          otherButtonTitles:nil];
    
    for(NSString *buttonTitle in otherButtons)
        [alert addButtonWithTitle:buttonTitle];
    
    for (UIView *view in subViews) {
        [alert addSubview:view];
    }
    
    [alert show];
    return alert;
}


+ (UIAlertView*) alertViewWithTitle:(NSString*) title
                            message:(NSString*) message
                  cancelButtonTitle:(NSString*) cancelButtonTitle
                  otherButtonTitles:(NSArray*) otherButtons
                          onDismiss:(DismissBlock) dismissed
                           onCancel:(CancelBlock) cancelled {
    
    _cancelBlock   = [cancelled copy];
    _dismissBlock  = [dismissed copy];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:[self class]
                                          cancelButtonTitle:cancelButtonTitle
                                          otherButtonTitles:nil];
    
    for(NSString *buttonTitle in otherButtons)
        [alert addButtonWithTitle:buttonTitle];
    
    [alert show];
    return alert;
}

+ (UIAlertView*) alertViewWithTitle:(NSString*) title
                            message:(NSString*) message
                  cancelButtonTitle:(NSString*) cancelButtonTitle {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:cancelButtonTitle
                                          otherButtonTitles: nil];
    [alert show];
    return alert;
}

+ (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (buttonIndex == [alertView cancelButtonIndex])
    {
        if (_cancelBlock) {
            _cancelBlock();
            _cancelBlock = nil;
        }
    }
    else
    {
        
        if (_ensureBlock) {
            _ensureBlock();
            _ensureBlock = nil;
        }
        
        if (_dismissBlock) {
            _dismissBlock(buttonIndex);
            _dismissBlock = nil;
        }
    }
}

@end
