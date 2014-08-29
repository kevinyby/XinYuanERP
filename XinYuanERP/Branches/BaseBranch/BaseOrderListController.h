#import "AppModelListController.h"



#define list_REQUEST_PATH           @"PATH"

#define list_VIEW_HEADERS           @"HEADERS"
#define list_VIEW_HEADERSX          @"HEADERSX"
#define list_VIEW_VALUESX           @"VALUESX"

#define list_VIEW_FILTER            @"FILTERS"  //  "FILTER_NIL" , "FILTER_NumberName" ...

#define list_ELIMINATE_SEARCH       @"__Eliminate_Search_Fields"


@class OrderListSearchHelper;


@interface BaseOrderListController : AppModelListController


@property (strong) NSString* order;                 // order or model
@property (strong) NSString* department;            // departments or categories




#pragma mark - Public Methods

-(void) initializeWithDepartment:(NSString*)department order:(NSString*)orderType;




#pragma mark - Subclass Override Methods

-(void) handleSearchHelper: (OrderListSearchHelper*)searchHelperObj;

-(void) setInstanceVariablesValues;

-(void) setExceptionAttributes;

-(void) setHeadersSortActions;


@end
