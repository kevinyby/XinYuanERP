#import <Foundation/Foundation.h>



#define SORT_ASC    @"ASC"
#define SORT_DESC   @"DESC"






@class JsonController;
@class JRLocalizeLabel;
@class BaseOrderListController;


@interface OrderListControllerHelper : NSObject



#pragma mark - View Did Load

+ (void)setRightBarButtonItems: (BaseOrderListController*)listController;




#pragma mark - Delete Order

+(NSString*) getImageFolderName:(BaseOrderListController*)listController indexPath:(NSIndexPath*)realIndexPath;

+(NSString*) getDeleteImageFolderProperty: (NSString*)department order:(NSString*)order;

+(void) deleteWithCheckPermission:(NSString*)orderType deparment:(NSString*)department identification:(id)identification tips:(NSString*)tips handler:(void(^)(bool isSuccess))handler;





#pragma mark - Header Sorts

+(void) iterateHeaderJRLabel: (BaseOrderListController*)listController handler:(BOOL(^)(JRLocalizeLabel* label, int index, NSString* attribute))handler;

+(JRLocalizeLabel*) getHeaderJRLabelByAttribute: (BaseOrderListController*)listController attribute:(NSString*)attribute;

+(void) clickHeaderLabelSortRequestAction: (JRLocalizeLabel*)label listController:(BaseOrderListController*)listController;

+(NSString*) reverseSortString: (NSString*)sortString;





#pragma mark - Navigation


+(void) navigateToOrderController: (NSString*)department order:(NSString*)order identifier:(id)identifier;

+(JsonController*) getNewJsonControllerInstance:(NSString*)department order:(NSString*)order;

+(NSDictionary*) getModelsListSpecification: (NSString*)department order:(NSString*)order;





#pragma mark - Search Item

+(void) sortSearchProperties: (NSMutableArray*)searchProperties propertiesMap:(NSDictionary*)propertiesMap orderType:(NSString*)orderType;


@end
