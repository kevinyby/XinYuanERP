#import "AppSearchTableViewController.h"

#define SORT_ASC    @"ASC"
#define SORT_DESC   @"DESC"

@interface AppRefreshTableViewController : AppSearchTableViewController


#pragma mark - Class Methods
+(void) compareToSendModelRefreshRequest: (JRRefreshTableView*)refreshTableView filter:(ContentFilterBlock)filter requestModel:(RequestJsonModel*)requestJsonModel isTop:(BOOL)isTop completion:(void(^)(BOOL isNoNewData))completion;





@end
