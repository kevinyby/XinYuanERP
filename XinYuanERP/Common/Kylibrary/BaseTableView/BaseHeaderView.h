
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#define FOOTER_HIGHT 60.0f
typedef enum{
	EGOOPullRefreshPulling_DO = 0,
	EGOOPullRefreshNormal_DO,
	EGOOPullRefreshLoading_DO,
} EGOPullRefreshState_DO;

@protocol BaseHeaderDelegate;
@interface BaseHeaderView : UIView {
	
//	id _delegate;
	EGOPullRefreshState_DO _state;
    
	UILabel *_lastUpdatedLabel;
	UILabel *_statusLabel;
	CALayer *_arrowImage;
	UIActivityIndicatorView *_activityView;
	BOOL _isHeader;
    
    
}

@property(nonatomic,assign) id<BaseHeaderDelegate> delegate;

- (void)refreshLastUpdatedDate;
- (void)egoRefreshScrollViewDidScroll:(UIScrollView *)scrollView;
- (void)egoRefreshScrollViewDidEndDragging:(UIScrollView *)scrollView;
- (void)egoRefreshScrollViewDataSourceDidFinishedLoading:(UIScrollView *)scrollView;
- (id)initWithFrame:(CGRect)frame isHeader:(BOOL)header;
@end
@protocol BaseHeaderDelegate <NSObject>
- (void)egoRefreshTableHeaderDidTriggerRefresh:(BaseHeaderView*)view;
- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(BaseHeaderView*)view;
@optional
- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(BaseHeaderView*)view;
@end
