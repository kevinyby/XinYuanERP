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

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    NSLog(@"AppNavigationViewController - didReceiveMemoryWarning");
    // Dispose of any resources that can be recreated.
}




// https://gist.github.com/mdewolfe/9369751
// http://stackoverflow.com/questions/19560198/ios-app-error-cant-add-self-as-subview
// http://blog.csdn.net/wihing/article/details/27960741
#pragma mark UINavigationController Overrides

-(void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
	if ( self.canPushOrPop ) {
		[super pushViewController:viewController animated:animated];
	}
}

-(NSArray*)popToRootViewControllerAnimated:(BOOL)animated {
	if ( self.canPushOrPop ) {
		return [super popToRootViewControllerAnimated:animated];
	}
	else {
		return @[];
	}
}

-(NSArray*)popToViewController:(UIViewController *)viewController animated:(BOOL)animated {
	if ( self.canPushOrPop ) {
		return [super popToViewController:viewController animated:animated];
	}
	else {
		return @[];
	}
}

#pragma mark PUBLIC PROPERTIES

-(BOOL)canPushOrPop {
	id navLock = self.navLock;
	id topVC = self.topViewController;
	
	return ( (! navLock) || (navLock == topVC) );
}

-(id)navLock {
	return self.topViewController;
}


#pragma mark - UINavigationControllerDelegate

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
}

@end
