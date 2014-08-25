#import "AppModelListController.h"

@class BaseOrderListController;

typedef void(^DidTapAddNewOrderBlock)(BaseOrderListController* controller, id sender);




@interface BaseOrderListController : AppModelListController


@property (strong) NSString* order;                 // order or model
@property (strong) NSString* department;            // departments or categories

@property (copy) DidTapAddNewOrderBlock didTapAddNewOrderBlock;


@end
