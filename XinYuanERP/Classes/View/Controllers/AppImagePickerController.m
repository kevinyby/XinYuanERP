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

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    
}


#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    [self dismissViewControllerAnimated:YES completion:^{}];
    
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    if (self.didFinishPickingImage) self.didFinishPickingImage(picker, image);
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:^{}];
    
    if (self.didCancelPickingImage) self.didCancelPickingImage(picker);
}

#pragma UINavigationControllerDelegate

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    UIView* view = [[UIView alloc] init];
    
    UIImageView* maskChin = [[UIImageView alloc] initWithImage: [UIImage imageNamed: @"rect-chin-iPad"]];
    maskChin.bounds = CanvasRect(0, 0, maskChin.image.size.width, maskChin.image.size.height);
    
    UIImageView* maskEarLeft = [[UIImageView alloc] initWithImage: [UIImage imageNamed: @"rect-ear-left-iPad"]];
    maskEarLeft.bounds = CanvasRect(0, 0, maskEarLeft.image.size.width, maskEarLeft.image.size.height);
    
    UIImageView* maskEarRight = [[UIImageView alloc] initWithImage: [UIImage imageNamed: @"rect-ear-right-iPad"]];
    maskEarRight.bounds = CanvasRect(0, 0, maskEarRight.image.size.width, maskEarRight.image.size.height);
    
    [view addSubview: maskChin];
    [view addSubview: maskEarLeft];
    [view addSubview: maskEarRight];
    
    CGRect bounds = self.view.bounds;
    CGFloat width = bounds.size.width;
    CGFloat height = bounds.size.height;
    
    [maskChin setCenterY: height * 3/4];
    [maskChin setCenterX: width/2];
    
    CGFloat widthOffset = [FrameTranslater convertCanvasWidth: 50];
    CGFloat heightOffset = [FrameTranslater convertCanvasHeight: 600];
    
    [maskEarLeft setCenterY: heightOffset];
    [maskEarLeft setCenterX: widthOffset];
    [maskEarRight setCenterY: heightOffset];
    [maskEarRight setCenterX: width - widthOffset];
    
    [self.view addSubview: view];
}



@end
