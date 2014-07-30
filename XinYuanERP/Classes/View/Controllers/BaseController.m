#import "BaseController.h"
#import "AppInterface.h"

@implementation BaseController



//        [UIApplication sharedApplication].statusBarHidden = YES;  // Hide status bar , for <= ios 6
// Hide status bar , for >= ios 7
- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [ViewControllerHelper setLandscapeBounds: self];
    self.view.backgroundColor = [UIColor whiteColor];
    
    //
    if (self.viewDidLoadBlock) {
        self.viewDidLoadBlock(self);
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    //
    if (self.viewWillAppearBlock) {
        self.viewWillAppearBlock(self, animated);
    }
}

-(void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    //
    if (self.viewDidDisappearBlock) {
        self.viewDidDisappearBlock(self, animated);
    }
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //
    if (self.viewDidAppearBlock) {
        self.viewDidAppearBlock(self, animated);
    }
}


@end
