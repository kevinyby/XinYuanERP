#import "SetDropboxController.h"
#import "AppInterface.h"

@interface SetDropboxController ()

@end

@implementation SetDropboxController

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
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear: animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    self.navigationItem.title = LOCALIZE_KEY(@"Dropbox_Settings");
}


@end
