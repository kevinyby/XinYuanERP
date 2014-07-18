#import "SetExpirationsController.h"
#import "AppInterface.h"

#define CONNECT_MONTH_COUNT(_count) [NSString stringWithFormat:@"%d %@%@", _count, LOCALIZE_KEY(@"unit_entry"), LOCALIZE_KEY(@"month")]




@implementation SetExpirationsController
{
    NSString* order ;
    NSString* department ;
    
    JRButton* expirationButton ;
    JRGradientLabel* expirationLabel ;
    
    int expirationMonthCount;
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

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    // DO SAVE DATA
    NSDictionary* expirationSettings = @{department: @{order: @(expirationMonthCount)}};
    NSString* jsonString = [CollectionHelper convertJSONObjectToJSONString: expirationSettings];
    [AppServerRequester modifySetting:APPSettings_TYPE_ADMIN_ORDERSEXPIRATIONS json:jsonString completeHandler:^(ResponseJsonModel *data, NSError *error) {
        
    }];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    UIView* headerView = [self.view viewWithTag: 90099];
    [headerView setCenterX: self.view.bounds.size.width/2];
    [headerView setCenterY:[FrameTranslater convertCanvasHeight: 110]];
    
    
    // DO GET DATA
    [AppServerRequester readSetting: APPSettings_TYPE_ADMIN_ORDERSEXPIRATIONS completeHandler:^(ResponseJsonModel *data, NSError *error) {
        NSDictionary* results = data.results;
        NSString* jsonString = [results objectForKey:@"settings"];
        
        int monthCount = 0 ;
        if (jsonString) {
            NSError* newError = nil;
            NSDictionary* expirationSettings = [NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding: NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:&newError];
            monthCount = [[[expirationSettings objectForKey: department] objectForKey:order] intValue];
        }
        [self setExpirationMonthCount: monthCount];
        
    }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    __weak SetExpirationsController* weakInstance = self;
    self.navigationItem.title = LOCALIZE_KEY(order);
    
    // Header View
    UIView* headerView = [[UIView alloc] init];
    [FrameHelper setFrame: CGRectMake(0, 0, 300, 60) view:headerView];
    headerView.tag = 90099;
    [self.view addSubview:headerView];
    
    // Expiration Label
    JRGradientLabel* label = [[JRGradientLabel alloc] init];
    expirationLabel = label;
    NSDictionary* config = @{@"FONT_NAME": @"MarkerFelt-Wide" ,
                             @"FONT_SIZE": @(45) ,
                             @"JS_FONT_N_COLOR": @[ @(159), @(145), @(133), @(1) ],
                             @"STROKE.width_": @(2.0),};
    [expirationLabel subRender:config];
    [FrameHelper setFrame: CGRectMake(0, 0, 200, 55) view:expirationLabel];
    [headerView addSubview: expirationLabel];
    
    
    // Expiration Button
    JRButton* jrButton = [[JRButton alloc] init];
    expirationButton = jrButton;
    [expirationButton subRender:@{@"JR_BGN_IMG": @"Vendordatacard_05.png", @"FONT_SIZE": @(17), @"JS_FONT_N_COLOR": @[@(255),@(255),@(255),@(1)]}];
    [expirationButton setTitle: [NSString stringWithFormat:@"%@ %@", LOCALIZE_KEY(@"Setting"), LOCALIZE_KEY(@"expiredDate")] forState:UIControlStateNormal];
    [headerView addSubview: expirationButton];
    [expirationButton setOriginX:[expirationButton.superview sizeWidth] - [expirationButton sizeWidth]];
    [expirationButton setCenterY: [expirationButton.superview middlePoint].y];
    
    
    // Expriation Button Event
    expirationButton.didClikcButtonAction = ^void(JRButton* button){
        NSArray* array = @[LOCALIZE_KEY(@"NullSetting"),CONNECT_MONTH_COUNT(1),CONNECT_MONTH_COUNT(2),CONNECT_MONTH_COUNT(3),CONNECT_MONTH_COUNT(6),CONNECT_MONTH_COUNT(12),CONNECT_MONTH_COUNT(24)];
        int selectSelection = [array indexOfObject: label.text];
        selectSelection = selectSelection == NSNotFound ? 0 : selectSelection;
        [ActionSheetStringPicker showPickerWithTitle:@"" rows:array initialSelection:selectSelection doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
            int count = [selectedValue intValue];
            [weakInstance setExpirationMonthCount: count];
        } cancelBlock: nil origin:button];
    };
    
    
}

-(void) initializeSubViewConstraints
{
    RefreshTableView* headerTableView = self.headerTableView;
    headerTableView.hideSearchBar = YES;
    headerTableView.disableTriggered = YES;
    
    float gap  = [FrameTranslater convertCanvasHeight: 150];
    
    [headerTableView setTranslatesAutoresizingMaskIntoConstraints: NO];
    [self.view addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat:@"|-0-[headerTableView]-0-|"
                               options:NSLayoutFormatAlignAllTrailing
                               metrics:nil
                               views:NSDictionaryOfVariableBindings(headerTableView)]];
    [self.view addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat:@"V:|-(gap)-[headerTableView]-0-|"
                               options:NSLayoutFormatAlignAllTrailing
                               metrics:@{@"gap":@(gap)}
                               views:NSDictionaryOfVariableBindings(headerTableView)]];
}


#pragma mark -
-(void) setExpirationMonthCount: (int)count
{
    expirationMonthCount = count;
    NSString* text = count == 0 ? LOCALIZE_KEY(@"NullSetting") : CONNECT_MONTH_COUNT(expirationMonthCount);
    expirationLabel.text = text;
}

@end
