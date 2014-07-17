#import <Foundation/Foundation.h>

@class JRLocalizeLabel;
@class OrderSearchListViewController;

@interface JsonBranchHelper : NSObject


+(void) clickHeaderLabelSortRequestAction: (JRLocalizeLabel*)label listController:(OrderSearchListViewController*)listController;

+(NSString*) reverseSortString: (NSString*)sortString;


@end
