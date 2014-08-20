#import <Foundation/Foundation.h>

@class JRLocalizeLabel;
@class BaseOrderListController;

@interface JsonBranchHelper : NSObject


+(void) clickHeaderLabelSortRequestAction: (JRLocalizeLabel*)label listController:(BaseOrderListController*)listController;

+(NSString*) reverseSortString: (NSString*)sortString;


@end
