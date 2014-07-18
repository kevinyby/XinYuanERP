#import <UIKit/UIKit.h>
#import "JRBaseView.h"

@class TableViewBase;
@class JRLocalizeLabel;
@class JRRefreshTableView;

@class TableViewBase;
@class JRTitleHeaderTableView;

typedef void(^JRTitleHeaderTableViewDidSelectAction)(JRTitleHeaderTableView* headerTableView, NSIndexPath* indexPath);




@interface JRTitleHeaderTableView : JRBaseView 

@property (strong) UIView* headerView;
@property (strong) JRLocalizeLabel* titleLabel;
@property (strong) JRRefreshTableView* tableView;
@property (strong) UIView* footerView;

@property (copy) JRTitleHeaderTableViewDidSelectAction titleHeaderViewDidSelectAction;


#pragma mark - Public Method
-(void) refreshSubviewsConstraints;



@end
