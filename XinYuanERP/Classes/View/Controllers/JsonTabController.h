#import "JsonController.h"

@interface JsonTabController : JsonController

@property (strong, readonly) JsonDivView* scrollDivView;
@property (strong, readonly) JsonDivView* tabsButtonsView;


@property (copy) void(^didShowTabView)(int index, JsonDivView* tabView);    // For Tabs View Call Back


#pragma mark - Override Methods
-(NSArray*) getTheNeedRefreshTabsAttributesWhenPopBack;

@end
