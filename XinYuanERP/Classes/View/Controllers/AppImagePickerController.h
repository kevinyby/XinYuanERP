#import <UIKit/UIKit.h>

@interface AppImagePickerController : UIImagePickerController


@property (copy) void(^didFinishPickingImage)(UIImagePickerController* controller, UIImage* image);

@property (copy) void(^didCancelPickingImage)(UIImagePickerController* controller);

@end
