#import "ActionManager.h"
#import "AppInterface.h"

@implementation ActionManager

static ActionManager* sharedInstance;

@synthesize adminAction;


+(void)initialize {
    if (self == [ActionManager class]) {
        sharedInstance = [[ActionManager alloc] init];
    }
}

+(ActionManager*) getInstance {
    return sharedInstance;
}



-(void) initialiazeAdministerProcedure {
    self.adminAction = [[AdministratorAction alloc] init];
}

-(void) destroyReleaseableProcedure {
    self.adminAction = nil;
}





#pragma mark - Alert

-(void) alertError: (id)error {
    NSString* message = nil;
    if ([error isKindOfClass:[NSError class]]) {
        NSDictionary* userInfo = ((NSError*)error).userInfo;
        NSString* reason = [userInfo objectForKey: KEY_ERROR];
        message = reason ? reason : LOCALIZE_MESSAGE(@"CheckConnection");
    } else if ([error isKindOfClass:[NSString class]]) {
        message = LOCALIZE_MESSAGE(error);
        if (!message) message = error;
    }
    
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle: LOCALIZE_KEY(KEY_ERROR)
                                                    message: message
                                                   delegate: nil
                                          cancelButtonTitle: LOCALIZE_KEY(@"OK")
                                          otherButtonTitles: nil];
    [alert show];
}

-(void) alertWarning: (NSString*)message {
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle: LOCALIZE_KEY(KEY_WARNING)
                                                    message: message
                                                   delegate: nil
                                          cancelButtonTitle: LOCALIZE_KEY(@"OK")
                                          otherButtonTitles: nil];
    [alert show];
}


-(void) alertMessage: (NSString*)message {
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle: LOCALIZE_KEY(KEY_MESSAGE)
                                                    message: message
                                                   delegate: nil
                                          cancelButtonTitle: LOCALIZE_KEY(@"OK")
                                          otherButtonTitles: nil];
    [alert show];
}

@end
