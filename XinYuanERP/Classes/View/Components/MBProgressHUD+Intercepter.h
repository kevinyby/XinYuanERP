//
#import "MBProgressHUD.h"

@interface MBProgressHUD (Intercepter)

-(void) show;
-(void) hide;

-(void) setupCompletedView: (BOOL)isSuccessfully;
-(void) hideAfterDelay:(NSTimeInterval)delay;

@end
