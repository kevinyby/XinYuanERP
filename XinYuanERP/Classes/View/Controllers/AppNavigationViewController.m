#import "AppNavigationViewController.h"
#import "ClassesInterface.h"

@interface AppNavigationViewController () <UINavigationControllerDelegate>

@end

@implementation AppNavigationViewController

- (id)init
{
    self = [super init];
    if (self) {
        self.delegate = self;
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskLandscape;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    NSLog(@"AppNavigationViewController - didReceiveMemoryWarning");
    // Dispose of any resources that can be recreated.
}


#pragma mark - UINavigationControllerDelegate

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
}

@end
