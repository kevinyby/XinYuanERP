#import <UIKit/UIKit.h>


@interface AppImagePickerController : UIImagePickerController


@property (copy) void(^didCancelPickingImage)(AppImagePickerController* controller);


@property (copy) void(^didFinishPickingImage)(AppImagePickerController* controller, UIImage* image);

@property (copy) void(^willShowViewController)(AppImagePickerController* controller, BOOL animated);




@property (copy) NSUInteger(^supportedInterfaceOrientationsAction)(AppImagePickerController* controller);
@property (copy) UIInterfaceOrientation(^preferredInterfaceOrientationForPresentationAction)(AppImagePickerController* controller);

@property (copy) void(^didRotateFromOrientation)(UIImagePickerController* controller, UIInterfaceOrientation orientation);




@end
