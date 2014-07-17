//
#import "MBProgressHUD+Intercepter.h"
#import "ViewManager.h"

@implementation MBProgressHUD (Intercepter)

-(void)show
{
    self.labelText = nil;
    self.detailsLabelText = nil;
    self.mode = MBProgressHUDModeIndeterminate;
    
    [self show: YES];
}

-(void)hide
{
    [self hide: YES];
}

-(void) setupCompletedView: (BOOL)isSuccessfully
{
	self.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:isSuccessfully ? @"37x_Right.png" : @"37x_Wrong.png"]];
	self.mode = MBProgressHUDModeCustomView;
}

-(void) hideAfterDelay:(NSTimeInterval)delay
{
    [self hide: YES afterDelay:delay];
}


@end