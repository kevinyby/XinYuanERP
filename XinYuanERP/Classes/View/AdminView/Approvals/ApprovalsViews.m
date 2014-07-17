#import "ApprovalsViews.h"
#import "AppInterface.h"


#define APPOROVAL_VIEW_TAG(_index) (8080+_index)
#define LEVEL_VIEW_TAG(_index) (9090+_index)


@implementation ApprovalsViews
{
    NSArray* approvals;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


-(void)setModelName:(NSString *)modelName
{
    [super setModelName: modelName];
    approvals = [DATA.modelsStructure getModelApprovals: modelName];
}


#pragma mark -

- (void)initializeSubViews
{
    float baselineY = 2;
    
    int count = approvals.count;
    NSMutableArray* localizeKeys = [NSMutableArray arrayWithCapacity:count];
    
    // add the tabs
    PickerViewBase* tabsPicker = [[PickerViewBase alloc] init];
    for (int i = 0; i < count; i++) {
        NSString* key = [approvals objectAtIndex: i];
        [localizeKeys addObject: LOCALIZE_KEY(LOCALIZE_CONNECT_KEYS(self.modelName, key))];
    }
    tabsPicker.contents = localizeKeys;
    [tabsPicker setOriginY: [FrameTranslater convertCanvasY: baselineY]];
    [tabsPicker setSizeWidth:[FrameTranslater convertCanvasWidth: 200]] ;
    [self addSubviewToContentView: tabsPicker];
    
    __block int currnetRow = 0 ;
    tabsPicker.pickerViewBasedDidSelectAction = ^(PickerViewBase* pickerViewObj, NSInteger row, NSInteger component) {
        if (currnetRow == row) return ;
        
        TableHeaderAddButtonView* currentApprovalView = (TableHeaderAddButtonView* )[self.contentView viewWithTag: APPOROVAL_VIEW_TAG(currnetRow)];
        TableHeaderAddButtonView* selectedApprovalView = (TableHeaderAddButtonView* )[self.contentView viewWithTag: APPOROVAL_VIEW_TAG(row)];
        
        UIView* currentLevelView = (UIView* )[self.contentView viewWithTag: LEVEL_VIEW_TAG(currnetRow)];
        UIView* selectedLevelView = (UIView* )[self.contentView viewWithTag: LEVEL_VIEW_TAG(row)];
        
        currnetRow = row;

        // in
        [UIView transitionWithView: self
                          duration: 0.8
                           options: UIViewAnimationOptionCurveEaseInOut
                        animations:^ { [selectedApprovalView setCenterX: self.bounds.size.width / 2 ];
                                       [selectedLevelView setCenterX: self.bounds.size.width / 2 ]; }
                        completion:^ (BOOL isFinish){}];
        
        // out
        [UIView transitionWithView: self
                          duration: 0.5
                           options: UIViewAnimationOptionCurveEaseOut
                        animations:^ { [currentApprovalView setOriginX: CGRectGetWidth(self.bounds)];
                                       [currentLevelView setOriginX: CGRectGetWidth(self.bounds)]; }
                        completion:^ (BOOL isFinish){}];
        
    };
    
    
    // add the tableviews
    for (int i = 0; i < count; i++) {
        TableHeaderAddButtonView* approvalView = [[TableHeaderAddButtonView alloc] init];
        approvalView.headers = @[LOCALIZE_KEY(@"number"), LOCALIZE_KEY(@"name") ];     // default
        approvalView.headersXcoordinates = @[@(20), @(200)];
        approvalView.valuesXcoordinates = @[@(10), @(200)];
        
        // add button event
        __weak TableHeaderAddButtonView* weakApprovalView = approvalView;
        approvalView.addButton.didClikcButtonAction = ^void(NormalButton* button) {
            // popup a picker table
            self.disableZoom = YES;
            NSMutableArray* numbers = [NSMutableArray array];
            for (NSString* username in [DATA.usersNOApproval allKeys]){
                if ([DATA.usersNOApproval[username] boolValue]) {
                    BOOL isHaveReadPermission = [PermissionChecker check: username department:self.categoryName order:self.modelName permission:PERMISSION_READ];
                    if (isHaveReadPermission) {
                        [numbers addObject:username];
                    }
                }
            }
            
            PickerModelTableView* pickView = [[PickerModelTableView alloc] initWithModel:MODEL_EMPLOYEE];
            [PickerModelTableView setEmployeesNumbersNames:pickView.tableView.tableView numbers:numbers];
            
            
            UIView* containerView = VIEW.navigator.topViewController.view;
            [PopupViewHelper popView: pickView inView:containerView tapOverlayAction:nil willDissmiss:^(UIView *view) {
                self.disableZoom = NO;
            }];
            [ViewHelper setShadowWithCorner:pickView config:@{@"CornerRadius":@(5.0)}];
            
            
            pickView.titleHeaderViewDidSelectAction = ^void(JRTitleHeaderTableView* headerTableView, NSIndexPath* indexPath, TableViewBase* tableView){
                FilterTableView* filterTableView = (FilterTableView*)tableView;
                NSArray* contents = [filterTableView contentForIndexPath: filterTableView.seletedVisibleIndexPath];
                id userNumber = [filterTableView realContentForIndexPath: indexPath];
                // popup to ask sure
                [PopupViewHelper popAlert: nil message:LOCALIZE_MESSAGE_FORMAT(@"AskSureToAddApproval", DATA.usersNONames[userNumber]) style:0 actionBlock:^(UIView *popView, NSInteger index) {
                    if (index == 1) {
                        [TableViewBaseHelper insertToFirstRowWithAnimation: weakApprovalView.tableView section:0 content:contents realContent:userNumber];
                    }
                } dismissBlock:nil buttons:LOCALIZE_KEY(@"CANCEL"), LOCALIZE_KEY(@"OK"), nil];
            };
            
        };
        
        // set frame
        [FrameHelper setFrame: CGRectMake(0, baselineY, 500, 400)  view:approvalView];
        [self addSubviewToContentView: approvalView];
        approvalView.tag = APPOROVAL_VIEW_TAG(i);
        
        
        //add level view
        
        UIView* levelView = [[UIView alloc]init];
        [FrameHelper setFrame:CGRectMake(0, 420, 500, 60)  view:levelView];
        [self addSubviewToContentView:levelView];
        levelView.tag = LEVEL_VIEW_TAG(i);
        
        UILabel* levelLabel = [[UILabel alloc] init];
        levelLabel.text = LOCALIZE_MESSAGE_FORMAT(@"SettingApprovalLevel", [localizeKeys objectAtIndex:i]) ;
        levelLabel.font = [UIFont fontWithName:@"Arial" size:20];
        [FrameHelper translateLabel:levelLabel canvas:CGRectMake(10, 15, 150, 30)];
        [levelView addSubview:levelLabel];
        
        JRTextField* levelTextField = [[JRTextField alloc] init];
        [FrameHelper setFrame: CGRectMake(150, 15, 100, 30)  view:levelTextField];
        [levelTextField setBorderStyle:UITextBorderStyleRoundedRect];
        levelTextField.tag = 2;
        [levelView addSubview:levelTextField];
         levelTextField.textFieldDidClickAction = ^void(JRTextField* textField) {
             JRButtonsHeaderTableView* searchTableView = [PopupTableHelper showUpJobLevelPopTableView: textField];
             searchTableView.leftButton.hidden = NO;
             searchTableView.leftButton.didClikcButtonAction = ^void(UIButton* button){
                 [textField setValue: nil];
                 [PopupTableHelper dissmissCurrentPopTableView];
             };
         };
        
        if (i == 0) {
            [approvalView setCenterX: self.bounds.size.width / 2 ];
            [levelView setCenterX: self.bounds.size.width / 2 ];
        } else {
            [approvalView setOriginX: CGRectGetWidth(self.bounds) ];
            [levelView setOriginX: CGRectGetWidth(self.bounds) ];
        }
        

        
    }
    
}

-(void) loadCurrentApprovalsSettings
{
    NSDictionary* orderAppSettings = [[DATA.approvalSettings objectForKey: self.categoryName] objectForKey: self.modelName];
    for (int i = 0; i < approvals.count; i++) {
        TableHeaderAddButtonView* approvalView = (TableHeaderAddButtonView* )[self.contentView viewWithTag: APPOROVAL_VIEW_TAG(i)];
        NSString* key = [approvals objectAtIndex: i];
        
        
        // Pair A :
        NSMutableDictionary* dictionary = [orderAppSettings objectForKey: key];
        
        
        // first : USERS
        NSArray* users = [dictionary objectForKey:APPSettings_APPROVALS_USERS];
        
        NSMutableArray* realContents = [ArrayHelper eliminateDuplicates: users];
        NSMutableArray* contents = [ViewControllerHelper getUserNumbersNames:realContents];

        NSString* andkey = [@(0) stringValue];
        approvalView.tableView.realContentsDictionary = [NSMutableDictionary dictionaryWithObject:realContents forKey:andkey];
        approvalView.tableView.contentsDictionary = [NSMutableDictionary dictionaryWithObject: contents forKey:andkey];
        
        approvalView.tableView.tableViewBaseWillShowCellAction = ^void(TableViewBase* tableViewObj,UITableViewCell* cell, NSIndexPath* indexPath) {
            NSString* username = [tableViewObj realContentForIndexPath: indexPath];
            
            NSString* tip = nil;
            if (! DATA.usersNONames[username]) {
                tip = APPLOCALIZE_KEYS(@"user", @"already", @"not", @"exist");
            } else
            if (! [DATA.usersNOApproval[username] boolValue]) {
                tip = APPLOCALIZE_KEYS(@"without",@"(Employee.ownApproval)" ) ;
            } else
            if ([DATA.usersNOResign[username] boolValue]) {
                tip = LOCALIZE_KEY(@"Employee.resign");
            }else
            {
                BOOL isHaveReadPermission = [PermissionChecker check: username department:self.categoryName order:self.modelName permission:PERMISSION_READ];
                if (! isHaveReadPermission) {
                    tip = APPLOCALIZE_KEYS(@"user", @"without", PERMISSION_READ, @"permission");
                }
            }
            
            
            NSInteger tag = 2014;
            JRLabel* tipLabel = (JRLabel*)[cell.contentView viewWithTag: tag];
            if (tipLabel) {
                tipLabel.hidden = YES;
            }
            if (tip) {
                // create one
                if (!tipLabel) {
                    tipLabel = [[JRLabel alloc] init];
                    tipLabel.tag = tag;
                    [cell.contentView addSubview: tipLabel];
                    tipLabel.font = [UIFont fontWithName:@"Arial" size:[FrameTranslater convertFontSize: 20]];
                    tipLabel.textColor = [UIColor redColor];
                }
                tipLabel.hidden = NO;
                tipLabel.text = tip;
                [tipLabel adjustWidthToFontText];
                [tipLabel setCenterY: [cell middlePoint].y];
                [tipLabel setOriginX: [cell sizeWidth] - [tipLabel sizeWidth] - 2];
            }
        };
        
        
        // second : PRAMAS
        NSDictionary* pramas = [dictionary objectForKey:APPSettings_APPROVALS_PRAMAS];
        UIView* levelView = (UIView* )[self.contentView viewWithTag: LEVEL_VIEW_TAG(i)];
        GestureTextField* txtField = (GestureTextField*)[levelView viewWithTag:2];
        txtField.text = [pramas objectForKey:APPSettings_APPROVALS_PRAMAS_LEVEL];
    }
}

-(NSMutableDictionary*) getApprovalsSettings
{
    // assemble the result
    NSMutableDictionary* result = [NSMutableDictionary dictionary];
    for (int i = 0; i < approvals.count; i++) {
        // Pair A :
        NSMutableDictionary* dictionary = [NSMutableDictionary dictionary];
        TableHeaderAddButtonView* approvalView = (TableHeaderAddButtonView* )[self.contentView viewWithTag: APPOROVAL_VIEW_TAG(i)];
        NSString* key = [approvals objectAtIndex: i];
        
        NSMutableDictionary* pramas = [NSMutableDictionary dictionary];
        
        // first : USERS
        NSArray* approvalUsers = [approvalView.tableView realContentsForSection: 0];
        [dictionary setObject: approvalUsers forKey:APPSettings_APPROVALS_USERS];
        
        
        // add approval level
        UIView* levelView = (UIView* )[self.contentView viewWithTag: LEVEL_VIEW_TAG(i)];
        GestureTextField* txtField = (GestureTextField*)[levelView viewWithTag:2];
        id levelValue = txtField.text ? txtField.text : @"";
        [pramas setObject:levelValue forKey:APPSettings_APPROVALS_PRAMAS_LEVEL];
        
        // second : PARAMETERS(i.e. level ... )   // to do ...
        [dictionary setObject: pramas forKey:APPSettings_APPROVALS_PRAMAS];
        
        [result setObject: dictionary forKey:key];
    }
    return result;
}


@end
