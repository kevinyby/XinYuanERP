#import <Foundation/Foundation.h>

@interface OrderListSearchHelper : NSObject



@property (strong, readonly) NSDictionary* orderPropertiesMap;

@property (strong, readonly) NSMutableArray* orderSearchProperties;

@property (strong, readonly) UIView* searchTableViewSuperView;



- (instancetype)initWithOrder: (NSString*)order;


-(void) showSearchTableView;


@end
