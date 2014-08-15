#import <UIKit/UIKit.h>
#import "ModelBaseView.h"

#define ApprovalsViews_PANEL_VIEW_TAG(_index) (1101+_index)



@class PickerViewBase;
@class TableHeaderAddButtonView;

@interface ApprovalsViews : ModelBaseView

@property (readonly) NSArray* approvals;
@property (readonly) PickerViewBase* tabsPicker;
@property (nonatomic,assign) NSInteger subOrderDepth;



@property (copy) void(^initializeSubViewsBlock)(ApprovalsViews*view );
@property (copy) void(^loadCurrentApprovalsSettingsBlock)(ApprovalsViews*view,NSDictionary* orderAppSettings );
@property (copy) void(^getApprovalsSettingsBlock)(ApprovalsViews*view, NSMutableDictionary* result );

#pragma mark -

- (void)initializeSubViews;
-(void) loadCurrentApprovalsSettings;
-(NSMutableDictionary*) getApprovalsSettings;

@end





@interface PanelView : UIView

@property (strong) TableHeaderAddButtonView* approvalView;
@property (strong) UIView* levelView;

@end


