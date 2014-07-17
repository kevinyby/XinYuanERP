#import <Foundation/Foundation.h>

@interface ApproveHelper : NSObject

#pragma mark - Checkout the pending approvals and badge icon number
+(void) refreshBadgeIconNumber: (NSString*)user;
+(int) getPendingOrdersCount: (NSString*)pendingApprovalStr;

@end
