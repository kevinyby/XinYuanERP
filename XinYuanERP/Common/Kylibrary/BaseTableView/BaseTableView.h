/*
 
 基类tableView
 
 */

#import "BaseHeaderView.h"
#import "BaseLoadingView.h"
#import "BaseEmptyView.h"
#import "BaseTableViewFooterView.h"
#import "DOErrorView.h"


@protocol BaseTableViewDelegate;


@interface BaseTableView : UITableView<UIScrollViewDelegate,BaseHeaderDelegate,UITableViewDelegate,BaseTableViewFooterViewDelegate>

@property(nonatomic,assign)BOOL hasHeaderView;
@property(nonatomic,assign)BOOL hasFooterView;

@property(nonatomic,strong)BaseHeaderView *headerView;
@property(nonatomic,strong)BaseTableViewFooterView *footerView;

@property(nonatomic,assign)id<BaseTableViewDelegate> baseDelegate;

@property(nonatomic,strong)NSMutableArray *datas;
@property(nonatomic,assign)BOOL isLoading;
@property(nonatomic,assign)BOOL isHeader;
@property(nonatomic,assign)BOOL isMore;
@property(nonatomic,assign)BOOL isRefresh;

@property(nonatomic,assign)NSInteger pageNum;
@property(nonatomic,assign)NSInteger totalPage;
@property(nonatomic,assign)NSInteger currentPage;

@property(nonatomic,strong)BaseLoadingView *loadingView;
@property(nonatomic,strong)BaseEmptyView *emptyView;
@property(nonatomic,strong)DOErrorView *errorView;


//关闭动画并加入数据
-(void)finishLoadingDataAction:(NSArray*)aArray;

-(void)scrollViewDidScrollTOBaseTableViewAction;
-(void)scrollViewDidEndDraggingTOBaseTableViewAction;

-(void)resetData;

@end





////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////
@protocol BaseTableViewDelegate <NSObject>

-(void)baseTableViewHeaderAction:(BaseTableView*)aBaseTableView;
-(void)baseTableViewFooterAction:(BaseTableView*)aBaseTableView;

@end
////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////




