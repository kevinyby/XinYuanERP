#import "BaseController.h"


@class ApprovalsViews;


@interface SetApprovalsController : BaseController


@property (readonly) ApprovalsViews* approvalsView;

- (id)initWithOrder: (NSString*)order department:(NSString *)department;

@end
