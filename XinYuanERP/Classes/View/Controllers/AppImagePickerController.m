#import "AppImagePickerController.h"
#import "AppInterface.h"


@interface AppImagePickerController() <UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@end


@implementation AppImagePickerController

- (id)init
{
    self = [super init];
    if (self) {
        self.delegate = self;
    }
    return self;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    if (self.didRotateFromOrientation) {
        self.didRotateFromOrientation(self, fromInterfaceOrientation);
    }
}


#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    if (self.didFinishPickingImage) {
        self.didFinishPickingImage(picker, [info objectForKey:UIImagePickerControllerOriginalImage]);
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    if (self.didCancelPickingImage) {
        self.didCancelPickingImage(picker);
    }
}

#pragma UINavigationControllerDelegate

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if (self.willShowViewController) {
        self.willShowViewController(self, animated);
    }
}



@end
