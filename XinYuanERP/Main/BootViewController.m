#import "BootViewController.h"
#import "AppInterface.h"


@implementation BootViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.

     self.view.backgroundColor = [UIColor greenColor];
    
     [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(bootFinishAction) userInfo:nil repeats:NO];
}

-(void)bootFinishAction{
    
    [VIEW showLoginViewController];
    
}

@end
