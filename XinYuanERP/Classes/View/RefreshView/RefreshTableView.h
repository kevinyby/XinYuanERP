#import "HeaderSearchTableView.h"


@class RefreshTableView;
@protocol RefreshTableViewDelegate <NSObject>

@optional
-(void) didTriggeredTopRefresh: (RefreshTableView*)tableView;
-(void) didTriggeredBottomRefresh: (RefreshTableView *)tableView;

@end


@class RefreshTopView;
@class RefreshBottomView;

@interface RefreshTableView : HeaderSearchTableView

@property (nonatomic, assign) BOOL disableTriggered;
@property (strong) RefreshTopView* topView;
@property (strong) RefreshBottomView* bottomView;

@property (nonatomic, assign) id<RefreshTableViewDelegate> delegate;

-(void) doneDownloading: (BOOL)isTop ;

@end



















// ----------------------- Delegate Block

@interface RefreshTableView (DelegateBlock)


@property (copy) void(^refreshTableViewDidTriggeredRefreshTop)(RefreshTableView* tableViewObj);
@property (copy) void(^refreshTableViewDidTriggeredRefreshBottom)(RefreshTableView* tableViewObj);

@end
