#import <Foundation/Foundation.h>
#import "OrderSearchListViewController.h"

#define list_REQUEST_PATH           @"PATH"

#define list_VIEW_HEADERS           @"HEADERS"
#define list_VIEW_HEADERSX          @"HEADERSX"
#define list_VIEW_VALUESX           @"VALUESX"

#define list_VIEW_FILTER            @"FILTERS"  //  "FILTER_NIL" , "FILTER_NumberName" ...

@class JsonController;
@class JRLocalizeLabel;


@interface JsonBranchFactory : NSObject


@property (nonatomic, strong) NSString* department;



#pragma mark - Public Methods

- (void)handleOrderListController: (OrderSearchListViewController*)listController order:(NSString*)order;


#pragma mark - Subclass Override Methods

-(void) setInstanceVariablesValues: (OrderSearchListViewController*)listController order:(NSString*)order;

-(void) setExceptionAttributes: (OrderSearchListViewController*)listController order:(NSString*)order;

-(void) setHeadersSortAction: (OrderSearchListViewController*)listController order:(NSString*)order;


#pragma mark - Class Methods

+(void) iterateHeaderJRLabel: (OrderSearchListViewController*)listController handler:(BOOL(^)(JRLocalizeLabel* label, int index, NSString* attribute))handler;

+(JRLocalizeLabel*) getHeaderJRLabelByAttribute: (OrderSearchListViewController*)listController attribute:(NSString*)attribute;

+ (id)factoryCreateBranch:(NSString*)department;

+(void) navigateToOrderController: (NSString*)department order:(NSString*)order identifier:(id)identifier;

+(JsonController*) getNewJsonControllerInstance:(NSString*)department order:(NSString*)order;

+(NSDictionary*) getModelsListSpecification: (NSString*)department order:(NSString*)order;




@end
