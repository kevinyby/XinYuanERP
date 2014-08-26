#import "AppModelListController.h"


@interface BaseOrderListController : AppModelListController


@property (strong) NSString* order;                 // order or model
@property (strong) NSString* department;            // departments or categories



#pragma mark - Public Methods

- (void)handleOrderListController;


#pragma mark - Subclass Override Methods

-(void) setInstanceVariablesValues;

-(void) setExceptionAttributes;

-(void) setHeadersSortActions;


@end
