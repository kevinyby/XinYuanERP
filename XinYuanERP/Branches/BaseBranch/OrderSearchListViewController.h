#import "AppModelListController.h"

@class OrderSearchListViewController;

typedef void(^DidTapAddNewOrderBlock)(OrderSearchListViewController* controller, id sender);




@interface OrderSearchListViewController : AppModelListController


@property (strong) NSString* order;                 // order or model
@property (strong) NSString* department;            // departments or categories

@property (copy) DidTapAddNewOrderBlock didTapAddNewOrderBlock;


@end
