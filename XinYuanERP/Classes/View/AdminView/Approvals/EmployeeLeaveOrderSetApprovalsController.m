#import "EmployeeLeaveOrderSetApprovalsController.h"
#import "AppInterface.h"

@interface EmployeeLeaveOrderSetApprovalsController ()

@end

@implementation EmployeeLeaveOrderSetApprovalsController



#define APP_LEAVE_DAY @"APP_LEAVE_DAY"


- (void)viewDidLoad
{
    self.approvalsView.initializeSubViewsBlock = ^void(ApprovalsViews* appview) {
        for (int i = 0; i < appview.approvals.count; i++) {
            PanelView* panelView = (PanelView*)[appview.contentView viewWithTag:ApprovalsViews_PANEL_VIEW_TAG(i)];
            NSString* approvalKey = appview.approvals[i];
            
            
            //add leave day view
            
            UIView* leaveDayView = [[UIView alloc]init];
            [FrameHelper setFrame:CGRectMake(0, 500, 500, 60)  view:leaveDayView];
            [panelView addSubview: leaveDayView];
            
            UILabel* dayLabel = [[UILabel alloc] init];
            dayLabel.text = APPLOCALIZE_KEYS(approvalKey, @"Day", @"count") ;// LOCALIZE_KEY(LOCALIZE_CONNECT_KEYS(appview.modelName, appview.approvals[i])) ;
            dayLabel.font = [UIFont fontWithName:@"Arial" size:20];
            [FrameHelper translateLabel:dayLabel canvas:CGRectMake(10, 15, 150, 30)];
            [leaveDayView addSubview:dayLabel];
            
            JRTextField* dayTextField = [[JRTextField alloc] init];
            [FrameHelper setFrame: CGRectMake(150, 15, 100, 30)  view:dayTextField];
            [dayTextField setBorderStyle:UITextBorderStyleRoundedRect];
            [leaveDayView addSubview:dayTextField];
            
            
            dayTextField.tag = 100;
            leaveDayView.tag = 99;
        }
    };
    
    
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    

    
    self.approvalsView.loadCurrentApprovalsSettingsBlock = ^void(ApprovalsViews*appview, NSDictionary* orderAppSettings) {
        for (int i = 0; i < appview.approvals.count; i++) {
            PanelView* panelView = (PanelView*)[appview.contentView viewWithTag:ApprovalsViews_PANEL_VIEW_TAG(i)];
            NSString* approvalKey = appview.approvals[i];
            
            
            UIView* leaveDayView = [panelView viewWithTag: 99];
            JRTextField* dayTextField = (JRTextField*)[leaveDayView viewWithTag: 100];
            
            [dayTextField setValue: [[orderAppSettings objectForKey: approvalKey] objectForKey:APP_LEAVE_DAY]];
        }
    };
    
    self.approvalsView.getApprovalsSettingsBlock = ^void(ApprovalsViews*appview, NSMutableDictionary* result ) {
        for (int i = 0; i < appview.approvals.count; i++) {
            PanelView* panelView = (PanelView*)[appview.contentView viewWithTag:ApprovalsViews_PANEL_VIEW_TAG(i)];
            NSString* approvalKey = appview.approvals[i];
            
            
            UIView* leaveDayView = [panelView viewWithTag: 99];
            JRTextField* dayTextField = (JRTextField*)[leaveDayView viewWithTag: 100];
            NSString* dayValue = [dayTextField getValue];
            
            if (!OBJECT_EMPYT(dayValue)) {
                [[result objectForKey: approvalKey] setObject: dayValue forKey:APP_LEAVE_DAY];
            }
        }
    };
    
}



@end
