
#import <Foundation/Foundation.h>
//#import "BaseVC.h"

@protocol BaseTableViewFooterViewDelegate;
@interface BaseTableViewFooterView : UIView<UIGestureRecognizerDelegate>

@property(nonatomic,retain)UILabel *tipLabel;
@property(nonatomic,retain)UIActivityIndicatorView *activityIndicator;
@property(nonatomic,assign)id<BaseTableViewFooterViewDelegate> bfDelegate;

-(void)start;
-(void)stop;
-(void)stopNoMoreData;

@end


@protocol BaseTableViewFooterViewDelegate <NSObject>
-(void)BaseTableViewFooterViewTapAction:(BaseTableViewFooterView*)aBaseTableViewFooterView;

@end



