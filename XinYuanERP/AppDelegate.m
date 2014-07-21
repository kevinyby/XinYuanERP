#import "AppDelegate.h"
#import "AppInterface.h"

@implementation AppDelegate

// for debug , to be remved in production
void uncaughtExceptionHandler(NSException *exception) {
    NSLog(@"Crash : %@ %@ %@", exception.name, exception.reason, exception.userInfo);
    NSLog(@"Stacks Traces : %@", [exception callStackSymbols]);
    
    // send email
    NSString* exceptionName = exception.name;
    NSString* exceptionReason = exception.reason;
//    NSDictionary* exceptionUserInfo = exception.userInfo;
    NSArray* callStackSymbols = exception.callStackSymbols;
    
    NSString* format = @"mailto://413677195@qq.com?subject=？？？crash report&body=感谢您的配合!<br><br><br> 错误详情:<br>%@<br>--------------------------<br>%@<br>---------------------<br>%@";
    NSString *urlStr = [NSString stringWithFormat:format, exceptionName,exceptionReason,[callStackSymbols componentsJoinedByString:@"<br>"]];
    
    NSString* encodeURL = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: encodeURL]];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    LOG(@"didFinishLaunchingWithOptions launchOptions: %@",launchOptions);
    
    // for debug , to be remved in production
    NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
    
    // for Device Adaptive
    [FrameTranslater setCanvasSize: CGSizeMake(LONG_IPAD, SHORT_IPAD)];
    
    // for <= ios 6 , Hide status bar
    [UIApplication sharedApplication].statusBarHidden = YES;
    
    // for localize
    [CategoriesLocalizer setCurrentLanguage: [[NSUserDefaults standardUserDefaults] objectForKey: PREFERENCE_LANGUAGE]];
    
    // for registry apns
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeBadge)];
    
    // for dropbox
    [DropboxSyncAPIManager setAppKey: DROPBOX_APPKEY secret:DROPBOX_APPSECRET];
    
    // for Keyboard manager
    [IQKeyboardManager enableKeyboardManagerWithDistance: [FrameTranslater convertCanvasHeight: 85]];
    
    
    self.window = VIEW.window;
//    [VIEW showBootViewController];
    [VIEW showLoginViewController];
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    [DropboxSyncAPIManager authorizeURLCallback: url];
    return YES;
}

- (NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
    return UIInterfaceOrientationMaskAll;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}



#pragma mark － APNS
- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
    NSString *string = [NSString stringWithFormat:@"%@", deviceToken];                          // <7df34018 1160dcb8 2607885e 332e770b 497a7547 58592047 646396ce bc9ab913>
    NSString *deviceTokenStr = [string substringWithRange: (NSRange){1, [string length] - 2} ]; // 7df34018 1160dcb8 2607885e 332e770b 497a7547 58592047 646396ce bc9ab913
    NSLog(@"deviceToken : %@", deviceTokenStr);
    [UserInstance sharedInstance].DGUDID = deviceTokenStr;
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
    LOG(@"Failed to get token, error: %@", error);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo{
    LOG(@"didReceiveRemoteNotification userInfo: %@",userInfo);
    [VIEW showApnsAlertWithContents: userInfo];
}





@end
