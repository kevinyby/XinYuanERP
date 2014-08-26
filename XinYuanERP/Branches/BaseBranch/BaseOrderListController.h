#import "AppModelListController.h"


@class BaseOrderListController;


typedef void(^DidTapAddNewOrderBlock)(BaseOrderListController* controller, id sender);




@interface BaseOrderListController : AppModelListController



@property (strong) NSString* order;                 // order or model
@property (strong) NSString* department;            // departments or categories



@property (copy) DidTapAddNewOrderBlock didTapAddNewOrderBlock;



#pragma mark - Public Methods

- (void)handleOrderListController: (BaseOrderListController*)listController order:(NSString*)order;


#pragma mark - Subclass Override Methods

-(void) setInstanceVariablesValues: (BaseOrderListController*)listController order:(NSString*)order;

-(void) setExceptionAttributes: (BaseOrderListController*)listController order:(NSString*)order;

-(void) setHeadersSortAction: (BaseOrderListController*)listController order:(NSString*)order;


@end
