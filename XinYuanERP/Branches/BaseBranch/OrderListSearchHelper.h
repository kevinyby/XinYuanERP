#import <Foundation/Foundation.h>



@class BaseOrderListController;



@interface OrderListSearchHelper : NSObject


@property (strong, readonly) NSDictionary* orderPropertiesMap;

@property (strong, readonly) NSMutableArray* orderSearchProperties;

@property (strong, readonly) UIView* searchTableViewSuperView;



- (instancetype)initWithController: (BaseOrderListController*)listController;


-(void) showSearchTableView;
-(void) hideSearchTableView;


@end
