#import "SetApprovalsController.h"
#import "AppInterface.h"
#import "ApprovalsViews.h"

@implementation SetApprovalsController
{
    NSString* order;
    NSString* department;
    
    ApprovalsViews* approvalsView;
}

- (id)initWithOrder: (NSString*)orderObj department:(NSString *)departmentObj
{
    self = [super init];
    if (self) {
        order = orderObj;
        department = departmentObj;
    }
    return self;
}

-(void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    // check if pop or push ?
    if ([VIEW.navigator.viewControllers containsObject:self]) {
        DLOG(@"It is push now , no need to save .");    // for the JRButton below
        return;
    } else {
        DLOG(@"It is Pop now , should need to save .");
    }
    
    
    // Save the settings to server
    NSMutableDictionary* result = [approvalsView getApprovalsSettings];
    
    NSString* json = [CollectionHelper convertJSONObjectToJSONString: @{department: @{order:result}}];
    [AppServerRequester modifySetting:APPSettings_TYPE_ADMIN_ORDERSAPPROVALS json:json completeHandler:^(ResponseJsonModel *data, NSError *error) {
        if (data.status) {
            [[DATA.approvalSettings objectForKey: department] setObject: result forKey:order];
        } else {
            [ACTION alertMessage: @"Settings Failed , please try again later."];
        }
    }];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear: animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    self.navigationItem.title = LOCALIZE_KEY(order);
    
    [approvalsView loadCurrentApprovalsSettings];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // set the container view
    approvalsView = [[ApprovalsViews alloc] initWithFrame: self.view.bounds];
    approvalsView.categoryName = department;
    approvalsView.modelName = order;
    [approvalsView initializeSubViews];
    
    [self.view addSubview:approvalsView];
    self.view.backgroundColor = [UIColor whiteColor];
    
    
    
    
#pragma mark - need nested orders or bills
    
    NSDictionary* insertOrderSpec = [DATA.modelsStructure getInsertModelsDefine];
    
    // check current
    if ([insertOrderSpec objectForKey: order]) {
        float baseLine = 600;
        // add a horizontal line
        UIView* line = [[UIView alloc] init];
        [FrameHelper setComponentFrame:@[@(0), @(baseLine), @(self.view.bounds.size.width), @(1)] component:line];
        [ColorHelper setBackGround: line color:[UIColor grayColor]];
        [self.view addSubview: line];
        
        // add buttons
        NSArray* subOrders = [insertOrderSpec objectForKey: order];
        for (int i = 0; i < subOrders.count; i++) {
            NSString* subOrder = [subOrders objectAtIndex: i];
            
            // add a button
            JRButton* jrButton = [[JRButton alloc] init];
            [FrameHelper setComponentFrame:@[@(i * 150 + 50), @(baseLine + 2)] component:jrButton];
            [jrButton subRender:@{@"JR_BGN_IMG": @"Vendordatacard_05.png", @"FONT_SIZE": @(17), @"JS_FONT_N_COLOR": @[@(255),@(255),@(255),@(1)]}];
            [jrButton setTitle: [NSString stringWithFormat:@"%@ %@", LOCALIZE_KEY(@"Setting"), LOCALIZE_KEY(subOrder)] forState:UIControlStateNormal];
            [self.view addSubview: jrButton];
            
            // next set subOrder
            jrButton.didClikcButtonAction = ^void(JRButton* button) {
                SetApprovalsController* approvalController = [[SetApprovalsController alloc] initWithOrder: subOrder department:department];
                [VIEW.navigator pushViewController: approvalController animated:YES];
            };
        }
    }
    

}



@end
