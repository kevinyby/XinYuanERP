#import "RefreshTableView.h"
#import "JRViewProtocal.h"

@interface JRRefreshTableView : RefreshTableView <JRComponentProtocal>

@property (copy) id(^JRRefreshTableViewGetValue)(JRRefreshTableView* tableViewObj);
@property (copy) void(^JRRefreshTableViewSetValue)(JRRefreshTableView* tableViewObj, id value);



@property (assign) int refreshCompareColumnSortIndex;


@end
