#import <Foundation/Foundation.h>
#import "BaseOrderListController.h"


#define list_REQUEST_PATH           @"PATH"

#define list_VIEW_HEADERS           @"HEADERS"
#define list_VIEW_HEADERSX          @"HEADERSX"
#define list_VIEW_VALUESX           @"VALUESX"

#define list_VIEW_FILTER            @"FILTERS"  //  "FILTER_NIL" , "FILTER_NumberName" ...



#define SORT_ASC    @"ASC"
#define SORT_DESC   @"DESC"



@class JsonController;
@class JRLocalizeLabel;


@interface JsonBranchFactory : NSObject


@property (nonatomic, strong) NSString* department;






#pragma mark - Class Methods

+(void) iterateHeaderJRLabel: (BaseOrderListController*)listController handler:(BOOL(^)(JRLocalizeLabel* label, int index, NSString* attribute))handler;

+(JRLocalizeLabel*) getHeaderJRLabelByAttribute: (BaseOrderListController*)listController attribute:(NSString*)attribute;

+(void) navigateToOrderController: (NSString*)department order:(NSString*)order identifier:(id)identifier;

+(JsonController*) getNewJsonControllerInstance:(NSString*)department order:(NSString*)order;

+(NSDictionary*) getModelsListSpecification: (NSString*)department order:(NSString*)order;




@end
