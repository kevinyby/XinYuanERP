#import <UIKit/UIKit.h>


@interface AppImagePickerController : UIImagePickerController


@property (copy) void(^didCancelPickingImage)(UIImagePickerController* controller);

@property (copy) void(^didFinishPickingImage)(UIImagePickerController* controller, UIImage* image);


@property (copy) void(^didRotateFromOrientation)(UIImagePickerController* controller, UIInterfaceOrientation orientation);

@property (copy) void(^willShowViewController)(UIImagePickerController* controller, BOOL animated);


@end
