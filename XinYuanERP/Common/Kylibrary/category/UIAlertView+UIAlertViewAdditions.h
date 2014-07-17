
#import <UIKit/UIKit.h>

typedef void (^EnsureBlock)();
typedef void (^CancelBlock)();
typedef void (^DismissBlock)(NSInteger buttonIndex);


@interface UIAlertView (UIAlertViewAdditions)<UIAlertViewDelegate>

+ (UIAlertView*) alertViewWithTitle:(NSString*) title
                            message:(NSString*) message
                  cancelButtonTitle:(NSString*) cancelButtonTitle;

+ (UIAlertView*) alertViewWithTitle:(NSString*) title
                            message:(NSString*) message
                  cancelButtonTitle:(NSString*) cancelButtonTitle
                  ensureButtonTitle:(NSString*) ensureButtonTitle
                           onCancel:(CancelBlock) cancelled
                           onEnsure:(EnsureBlock) ensure;

+ (UIAlertView*) alertViewWithTitle:(NSString*) title
                            message:(NSString*) message
                  cancelButtonTitle:(NSString*) cancelButtonTitle
                  otherButtonTitles:(NSArray*) otherButtons
                          onDismiss:(DismissBlock) dismissed
                           onCancel:(CancelBlock) cancelled;

+ (UIAlertView*) alertViewWithTitle:(NSString*) title
                            message:(NSString*) message
                  cancelButtonTitle:(NSString*) cancelButtonTitle
                  otherButtonTitles:(NSArray*) otherButtons
                           subViews:(NSArray*) subViews
                          onDismiss:(DismissBlock) dismissed
                           onCancel:(CancelBlock) cancelled;

@end
