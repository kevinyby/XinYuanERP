#import "AppModelListController.h"

@class OrderSearchListViewController;

typedef void(^DidTapAddNewOrderBlock)(OrderSearchListViewController* controller, id sender);

@interface OrderSearchListViewController : AppModelListController

@property (copy) DidTapAddNewOrderBlock didTapAddNewOrderBlock;





#pragma mark -

+(NSString*) getDeleteImageFolderProperty: (NSString*)department order:(NSString*)order;

+(void) deleteWithCheckPermission:(NSString*)orderType deparment:(NSString*)department identification:(id)identification tips:(NSString*)tips handler:(void(^)(bool isSuccess))handler;

@end
