#import <UIKit/UIKit.h>
#import "ModelBaseView.h"

@interface ApprovalsViews : ModelBaseView


#pragma mark -

- (void)initializeSubViews;

-(void) loadCurrentApprovalsSettings;
-(NSMutableDictionary*) getApprovalsSettings;

@end
