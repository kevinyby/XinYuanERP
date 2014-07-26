#import "ViewManager.h"
#import "AppInterface.h"

@implementation ViewManager

@synthesize window;
@synthesize progress;
@synthesize navigator;

static ViewManager* sharedInstance;

- (id)init
{
    self = [super init];
    if (self) {
        window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        progress = [[MBProgressHUD alloc] init];
        navigator = [[AppNavigationViewController alloc] init];
        [navigator.view addSubview: progress];
        
        NSLog(@"device identifierForVendor : %@", [[[UIDevice currentDevice] identifierForVendor] UUIDString]);
        NSLog(@"device name: %@", [[UIDevice currentDevice] name]);
        
//        for (int i = 0; i < 5; i++)  NSLog(@"%d", arc4random() % 10);
//        NSString* string = @"aaa";
//        NSArray* result = [AppViewHelper getKeyElements: string];
//        NSNumber* nsmu = [NSNumber numberWithFloat:2];
//        BOOL isEqual = [nsmu isEqual: @(2)];
    }
    return self;
}

-(const void *)byteFromString:(NSString *)aText
{
    NSData *data = [aText dataUsingEncoding:NSUTF8StringEncoding];
    return [data bytes];
}

-(NSString *)stringFromByte:(const void *)bytes withLength:(int)value
{
    return [[NSString alloc] initWithBytes:bytes length:value encoding:NSUTF8StringEncoding] ;
}

+(void)initialize {
    // Without that extra check, your initializations could run twice in this class,
    // if you ever have a subclass that doesn't implement its own +initialize method.
    if (self == [ViewManager class]) {
        sharedInstance = [[ViewManager alloc] init];
    }
}

+(ViewManager*) getInstance {
    return sharedInstance;
}

-(void) showBootViewController
{
    BootViewController* bootViewController = [[BootViewController alloc]init];
    self.window.rootViewController = bootViewController;
}
-(void) showLoginViewController
{
    VIEW.window.rootViewController = VIEW.navigator;
    LoginViewController *loginViewController = [[LoginViewController alloc]init];
    [VIEW.navigator pushViewController: loginViewController animated:NO];
}

-(void) showApnsAlertWithContents: (NSDictionary*)userInfo
{
    // Check the progress is showing
    if (VIEW.isProgressShowing) {
        DLOG(@"Next Time To Alert APNS");
        [self performSelector:@selector(showApnsAlertWithContents:) withObject:userInfo afterDelay:5];
        return;
    }
    
    
    
    NSDictionary* appleContents = userInfo[@"aps"];
    
    NSDictionary* informations = [CollectionHelper convertJSONStringToJSONObject:userInfo[REQUEST_APNS_INFOS]];
//    NSString* userFrom = [informations objectForKey: APNS_INFOS_USER_FROM];
    NSString* userTo = [informations objectForKey: APNS_INFOS_USER_TO];
    
    NSString* message = [appleContents objectForKey: REQUEST_APNS_ALERT];
    
    [UIAlertView alertViewWithTitle:LOCALIZE_KEY(@"Push_Notifications") message:message cancelButtonTitle:LOCALIZE_KEY(@"skip") ensureButtonTitle:LOCALIZE_KEY(@"read") onCancel:nil onEnsure:^{
        NSString* department = [informations objectForKey: APNS_INFOS_CATEGORY];
        NSString* order = [informations objectForKey: APNS_INFOS_MODEL];
        NSDictionary* identities = [informations objectForKey: APNS_INFOS_ID];
        id identification = [RequestModelHelper getModelIdentification: identities];
        
        [JsonBranchFactory navigateToOrderController: department order:order identifier:identification];
    }];
    
    
    // refresh icon
    NSString* user = DATA.signedUserName;
    if (! user) {
        user = userTo;
    }
    [ApproveHelper refreshBadgeIconNumber: user];
}


#pragma mark -
-(BOOL) isTestDevice
{
    if ([kURL isEqualToString:@"http://192.168.0.202"] || [kURL isEqualToString:@"http://192.168.0.203"] || [kURL isEqualToString:@"http://192.168.0.204"]) {
        return YES;
    }
    if ([[[UIDevice currentDevice] model] rangeOfString: @"Simulator"].location != NSNotFound) {
        return YES;
    }
    NSArray* testDeviceNames = @[@"iPad mini"];
    NSString* currentDeviceName = [[UIDevice currentDevice] name];
    if ([testDeviceNames containsObject:currentDeviceName]) {
        return YES;
    }
    return NO;
}

@end
