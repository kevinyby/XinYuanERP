#import "EmployeeController.h"
#import "AppInterface.h"

@implementation EmployeeController

-(NSArray*) getTheNeedRefreshTabsAttributesWhenPopBack
{
    return @[@"ZZ_TAB_BTNPending", @"TraceStatus"];
}


-(void) swipAction:(UISwipeGestureRecognizer*)gestureRecognizer
{
    if (gestureRecognizer.direction == UISwipeGestureRecognizerDirectionUp) {
        [JsonControllerHelper flipPage: self isNextPage:NO];
    } else if (gestureRecognizer.direction == UISwipeGestureRecognizerDirectionDown) {
        [JsonControllerHelper flipPage: self isNextPage:YES];
    }
}



#define CachePath [[[[[FileManager tempPath] stringByAppendingPathComponent: @"Writing"]stringByAppendingPathComponent: self.department] stringByAppendingPathComponent: self.order] stringByAppendingPathComponent: @"writing.txt"]
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (self.controlMode == JsonControllerModeCreate) {
        // start
        [ScheduledTask.sharedInstance registerSchedule:self timeElapsed:20 repeats:0];
        
        // get and set to view
        NSData* data = [NSData dataWithContentsOfFile:CachePath];
        if (! data)  return;
        
        NSString* jsonString = [[NSString alloc] initWithData: data encoding:NSUTF8StringEncoding];
        NSDictionary* objects = [CollectionHelper convertJSONStringToJSONObject: jsonString];
        if ([self needToWriteOrRenderCache: objects]) {
            [self.jsonView setModel: objects];
        }
    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    [ScheduledTask.sharedInstance unRegisterSchedule: self];
}

-(void)didSuccessSendObjects:(NSMutableDictionary *)objects response:(ResponseJsonModel *)response
{
    [super didSuccessSendObjects:objects response:response];
    
    [FileManager deleteFile: CachePath];
}

/// pragma mark - Scheduled Action

-(void) scheduledTask
{
    if (self.controlMode != JsonControllerModeCreate) return;
    
    NSDictionary* withImagesObjects = [self.jsonView getModel];
    NSMutableDictionary* objects = [DictionaryHelper filter:withImagesObjects withType:[UIImage class]];
    if ([self needToWriteOrRenderCache: objects]) {
        NSString* jsonString = [CollectionHelper convertJSONObjectToJSONString: objects];
        [FileManager writeDataToFile: CachePath data: [jsonString dataUsingEncoding: NSUTF8StringEncoding]];
    }
}


-(BOOL) needToWriteOrRenderCache: (NSDictionary*)objects
{
    int notEmptyCount = 0;
    for (NSString* key in objects) {
        if (!OBJECT_EMPYT(objects[key])) {
            notEmptyCount++;
        }
    }
    return notEmptyCount > 6;
}





- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    __weak EmployeeController* weakInstance = self;
    
    JsonView* jsonView = self.jsonView;
    
    //---------------------- INFO ---------------------------------
    
    JsonDivView* infoNestedView = (JsonDivView*)[jsonView getView: @"NESTED_SCROLL.NESTED_INFO"];
    // Add swipe gesture
    UISwipeGestureRecognizer* swipupGestureUP = [[UISwipeGestureRecognizer alloc] initWithTarget: self action:@selector(swipAction:)];
    swipupGestureUP.direction = UISwipeGestureRecognizerDirectionUp ;
    UISwipeGestureRecognizer* swipGestureDown = [[UISwipeGestureRecognizer alloc] initWithTarget: self action:@selector(swipAction:)];
    swipGestureDown.direction = UISwipeGestureRecognizerDirectionDown ;
    [infoNestedView addGestureRecognizer: swipupGestureUP];
    [infoNestedView addGestureRecognizer: swipGestureDown];
    
    
    // LEFT ________________________
    
    // edit departments
    JRTextField* editDepartmentTx = ((JRLabelCommaTextFieldView*)[infoNestedView getView:@"department"]).textField;
    editDepartmentTx.textFieldDidClickAction = ^void(JRTextField* jrTextField) {
        NSString* contentKey = @"department";
        __block BOOL isNeedToSaveToServer = NO;
        
        // popup departments
        UIView* superView = [PopupTableHelper getCommonPopupTableView];
        JRButtonsHeaderTableView* departmentEditTableView = (JRButtonsHeaderTableView*)[superView viewWithTag: POPUP_TABLEVIEW_TAG];
        // title label
        departmentEditTableView.titleLabel.text = LOCALIZE_KEY(@"department");
        // cancel button
        JRButton* cancelBtn = departmentEditTableView.leftButton ;
        cancelBtn.didClikcButtonAction = ^void(id sender) {
            [PopupViewHelper dissmissCurrentPopView];
        };
        JRButton* addBtn = departmentEditTableView.rightButton;
        [addBtn setTitle:LOCALIZE_KEY(KEY_ADD) forState:UIControlStateNormal];

        // add button
        addBtn.didClikcButtonAction = ^void(NormalButton* button) {
            [PopupViewHelper popAlert: LOCALIZE_MESSAGE(@"AddNewDepartment") message:nil style:UIAlertViewStylePlainTextInput actionBlock:^(UIView *popView, NSInteger index) {
                UIAlertView* alertView = (UIAlertView*)popView;
                NSString* newJobPosition = [alertView textFieldAtIndex: 0].text;
                if (OBJECT_EMPYT(newJobPosition)) return ;
                
                NSMutableArray* sectionsContents = [departmentEditTableView.tableView.tableView.contentsDictionary objectForKey: contentKey];
                // if have this department , then
                if ([sectionsContents containsObject: newJobPosition]) {
                    int row = [sectionsContents indexOfObject: newJobPosition];
                    NSIndexPath* containsIndexPath = [NSIndexPath indexPathForRow: row inSection: 0];
                    [departmentEditTableView.tableView.tableView selectRowAtIndexPath:containsIndexPath animated:YES scrollPosition:UITableViewScrollPositionMiddle];
                } else {
                    isNeedToSaveToServer = YES;
                    [sectionsContents addObject:newJobPosition];
                    int row = [sectionsContents indexOfObject: newJobPosition];
                    [departmentEditTableView.tableView.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow: row inSection:0]] withRowAnimation: UITableViewRowAnimationBottom];
                }
            } dismissBlock:nil buttons:LOCALIZE_KEY(@"CANCEL"), LOCALIZE_KEY(@"OK"), nil];
        };
        
        // search table view
        departmentEditTableView.tableView.tableView.tableViewBaseDidDeleteContentsAction = ^void(TableViewBase* tableViewObj, NSIndexPath* indexPath) {
            isNeedToSaveToServer = YES;
        };
        departmentEditTableView.tableView.tableView.tableViewBaseCanEditIndexPathAction = ^BOOL(TableViewBase* tableViewObj, NSIndexPath* indexPath){
            return YES;
        };
        departmentEditTableView.tableView.tableView.tableViewBaseShouldDeleteContentsAction = ^BOOL(TableViewBase* tableViewObj, NSIndexPath* indexPath) {
            if (indexPath.row == 0 || indexPath.row == 1) {
                return NO;
            }
            return YES;
        };
        departmentEditTableView.tableView.tableView.tableViewBaseHeightForIndexPathAction = ^CGFloat(TableViewBase* tableViewObj, NSIndexPath* indexPath) {
            return [FrameTranslater convertCanvasHeight: UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? 100 : 50];
        };
        departmentEditTableView.tableView.tableView.tableViewBaseDidSelectAction = ^(TableViewBase* tableViewObj, NSIndexPath* indexPath){
            // set the new department to text field
            id value = [tableViewObj contentForIndexPath: indexPath];
            [jrTextField setValue: value];
            [PopupViewHelper dissmissCurrentPopView];
        };
        // pop table
        [PopupViewHelper popView:superView inView:[ViewHelper getTopView] tapOverlayAction:^void(UIControl* control){} willDissmiss:^(UIView *view) {
            // will dimiss , then save the departments
            if (! isNeedToSaveToServer) return ;
            NSMutableArray* sectionsContents = [departmentEditTableView.tableView.tableView.contentsDictionary objectForKey: contentKey];
            [sectionsContents removeObjectsInRange:NSMakeRange(0, 2)];
            NSString* jobPositionsString = [CollectionHelper convertJSONObjectToJSONString:sectionsContents];
            [VIEW.progress show];
            [AppServerRequester modifySetting:APPSettings_TYPE_USER_JOBPOSITIONS json:jobPositionsString completeHandler:^(ResponseJsonModel *data, NSError *error) {
                [VIEW.progress hide];
            }];
        }];
        // load the data in the table and show all departments
        [AppViewHelper showIndicatorInView: departmentEditTableView];
        [AppServerRequester readSetting: APPSettings_TYPE_USER_JOBPOSITIONS completeHandler:^(ResponseJsonModel *data, NSError *error) {
            NSString* jobPositionString = data.results[@"settings"];
            NSMutableArray* dataSources = [PopupTableHelper getJobPositionDataSoucesFromSettingsString: jobPositionString];
            departmentEditTableView.tableView.tableView.contentsDictionary = [DictionaryHelper deepCopy: @{contentKey: dataSources}];
            [departmentEditTableView.tableView reloadTableData];
            [AppViewHelper stopIndicatorInView: departmentEditTableView];
        }];
    };
    
    
    
    // edit joblevel
    JRTextField* editJobLevelTx = ((JRLabelCommaTextFieldView*)[infoNestedView getView:@"jobLevel"]).textField;
    editJobLevelTx.textFieldDidClickAction = ^void(JRTextField* jrTextField) {
        NSString* contentKey = @"jobLevel";
        __block BOOL isNeedToSaveToServer = NO;
        __block BOOL isEditing = NO;
        
        // popup departments
        UIView* superView = [PopupTableHelper getCommonPopupTableView];
        JRButtonsHeaderTableView* jobLevelEditTableView = (JRButtonsHeaderTableView*)[superView viewWithTag: POPUP_TABLEVIEW_TAG];
        jobLevelEditTableView.tableView.headersXcoordinates = @[@(50),@(100)];
        jobLevelEditTableView.titleLabel.text = LOCALIZE_KEY(VALUES_PICKER_jobLevel);

        // cancel button
        JRButton* cancelBtn = jobLevelEditTableView.leftButton ;
        cancelBtn.didClikcButtonAction = ^void(id sender) {
            [PopupViewHelper dissmissCurrentPopView];
        };
        // edit button
        JRButton* editBtn = jobLevelEditTableView.rightButton;
        editBtn.didClikcButtonAction = ^void(NormalButton* button) {
            if (! isEditing) {
                isEditing = YES;
                [button setTitle:LOCALIZE_KEY(@"done") forState:UIControlStateNormal];
            } else {
                isEditing = NO;
                [button setTitle:LOCALIZE_KEY(@"edit") forState:UIControlStateNormal];
            }
            [jobLevelEditTableView.tableView reloadTableData];
        };
        jobLevelEditTableView.tableView.tableView.tableViewBaseCellForIndexPathAction = ^UITableViewCell*(TableViewBase* tableViewObj, NSIndexPath* indexPath,UITableViewCell* oldCell)
        {
            JRTextField* editTextField = (JRTextField*)[oldCell.contentView viewWithTag:10010];
            UILabel* label = (UILabel*)[oldCell.contentView viewWithTag: ALIGNTABLE_CELL_LABEL_TAG(1)];
            label.userInteractionEnabled = YES;
            if (!editTextField) {
                editTextField = [[JRTextField alloc] init];
                editTextField.tag = 10010;
                editTextField.textColor = [UIColor flatBlackColor];
                [ColorHelper setBorder: editTextField color:[UIColor flatGrayColor]];
                [oldCell.contentView addSubview: editTextField];
                // Change the datasouces
                editTextField.textFieldDidEndEditingBlock = ^(NormalTextField* tx, NSString* oldText) {
                    NSString* newText = tx.text;
                    if ([oldText isEqualToString:newText]) return ;
                    
                    isNeedToSaveToServer = YES;
                    UITableViewCell* cell = (UITableViewCell*)tx.superview;
                    while (cell && ![cell isKindOfClass:[UITableViewCell class]]) {
                        cell = (UITableViewCell*)cell.superview;
                    }
                    NSIndexPath* indexPath = [tableViewObj indexPathForCell: cell];
                    NSMutableArray* values = [tableViewObj contentForIndexPath:indexPath];
                    [values replaceObjectAtIndex: values.count - 1 withObject:newText];
                };
            }
            return oldCell;
        };
        jobLevelEditTableView.tableView.tableView.tableViewBaseWillShowCellAction = ^(TableViewBase* tableViewObj,UITableViewCell* cell, NSIndexPath* indexPath){
            
            UITextField* editTextField = (UITextField*)[cell.contentView viewWithTag:10010];
            UILabel* label = (UILabel*)[cell.contentView viewWithTag: ALIGNTABLE_CELL_LABEL_TAG(1)];
            if (!isEditing) {
                label.hidden = NO;
                editTextField.hidden = YES;
            } else {
                label.hidden = YES;
                editTextField.hidden = NO;
                
                editTextField.text = label.text;
                [editTextField setSize: [FrameTranslater convertCanvasSize:CGSizeMake(210, 50)]];
                [editTextField setCenterY: [label centerY]];
                [editTextField setOriginX: [label originX]];
            }
        };
        jobLevelEditTableView.titleHeaderViewDidSelectAction = ^void(JRTitleHeaderTableView* headerTableView, NSIndexPath* indexPath){
            if (isEditing) return;
            FilterTableView* filterTableView = (FilterTableView*)headerTableView.tableView.tableView;
            NSArray* value = [filterTableView contentForIndexPath:indexPath];
            [jrTextField setValue: [value firstObject]];
            [PopupViewHelper dissmissCurrentPopView];
        };
        
        // pop table
        [PopupViewHelper popView:superView inView:[ViewHelper getTopView] tapOverlayAction:^void(UIControl* control){} willDissmiss:^(UIView *view) {
            // will dimiss , then save the datasources
            if (! isNeedToSaveToServer) return ;
            NSArray* sectionsContents = [jobLevelEditTableView.tableView.tableView.contentsDictionary objectForKey: contentKey];
            NSString* jobPositionsString = [CollectionHelper convertJSONObjectToJSONString: sectionsContents];
            [VIEW.progress show];
            [AppServerRequester modifySetting:APPSettings_TYPE_USER_JOBLEVELS json:jobPositionsString completeHandler:^(ResponseJsonModel *data, NSError *error) {
                [VIEW.progress hide];
            }];
            
        }];
        // load the data in the table and show all departments
        [AppViewHelper showIndicatorInView: jobLevelEditTableView];
        editBtn.userInteractionEnabled = NO;
        [AppServerRequester readSetting: APPSettings_TYPE_USER_JOBLEVELS completeHandler:^(ResponseJsonModel *data, NSError *error) {
            editBtn.userInteractionEnabled = YES;
            [AppViewHelper stopIndicatorInView: jobLevelEditTableView];
            
            NSArray* array = DATA.config[@"JOBLEVELS"];
            NSString* jobLevelJsonString = data.results[@"settings"];
            if (jobLevelJsonString) {
                NSArray* temp =[CollectionHelper convertJSONStringToJSONObject:jobLevelJsonString];
                if (temp) array = temp;
            }
            jobLevelEditTableView.tableView.tableView.contentsDictionary = [DictionaryHelper deepCopy: @{contentKey: array}];
            [jobLevelEditTableView.tableView reloadTableData];
        }];
        
    };
    
    

    
    // Right ________________________
    
    // birthday and employeeDate
    JRTextField* birthdayTextField = ((JRLabelCommaTextFieldView*)[infoNestedView getView: @"birthday"]).textField;
    birthdayTextField.textFieldDidSetTextBlock = ^void(NormalTextField* tx, NSString* oldText) {
        NSString* newText = tx.text;
        if (!OBJECT_EMPYT(newText)) {
            NSDate* birthday = [DateHelper dateFromString: newText pattern:PATTERN_DATE];
            NSInteger age = [DateHelper getAgeFromBirthday:birthday];
            [((id<JRComponentProtocal>)[jsonView getView:@"age"]) setValue: @(age)];
        }
    };
    JRTextField* employDateTextField = ((JRLabelCommaTextFieldView*)[infoNestedView getView: @"employDate"]).textField;
    employDateTextField.textFieldDidSetTextBlock = ^void(NormalTextField* tx, NSString* oldText) {
        NSString* newText = tx.text;
        if (!OBJECT_EMPYT(newText)) {
            NSDate* employeeDate = [DateHelper dateFromString: newText pattern:PATTERN_DATE];
            NSDateComponents* components = [[NSCalendar currentCalendar] components:NSCalendarUnitYear | NSCalendarUnitMonth fromDate:employeeDate toDate:[NSDate date] options:0];
            [((id<JRComponentProtocal>)[((JRComplexView*)[jsonView getView:@"Seniority_Complex"]) getView:@"year"]) setValue: @(components.year)];
            [((id<JRComponentProtocal>)[((JRComplexView*)[jsonView getView:@"Seniority_Complex"]) getView:@"month"]) setValue: @(components.month)];
        }
    };
    
    
    // experience view
    JRComplexView* experienceView = (JRComplexView*)[infoNestedView getView: @"work_experience"];
    JRTableView* expTableView = (JRTableView*)[experienceView getView: @"TBL_Contents"];
    
    expTableView.tableViewBaseCellForIndexPathAction = ^UITableViewCell*(TableViewBase* tableViewObj, NSIndexPath* indexPath, UITableViewCell* oldCell){
        oldCell.backgroundColor = [UIColor clearColor];
        oldCell.textLabel.font = [UIFont systemFontOfSize: [FrameTranslater convertFontSize: 15]];
        oldCell.textLabel.text = oldCell.textLabel.text;
        return oldCell;
    };
    expTableView.tableViewBaseHeightForIndexPathAction = ^CGFloat(TableViewBase* tableViewObj, NSIndexPath* indexPath){
        return [FrameTranslater convertFontSize: 30];
    };
    expTableView.tableViewBaseDidSelectAction = ^void(TableViewBase* tableViewObj, NSIndexPath* indexPath){
        NSString* content = [tableViewObj contentForIndexPath:indexPath];
        JsonView* experenceJsonView = [EmployeeViewsHelper popupJsonView:@"Components" key:@"AddExperienceView" dissmiss:nil];
        JRComplexView* experienceComplexView = (JRComplexView*)[experenceJsonView getView: @"experiencePopup"];
        [experienceComplexView setValue: content];
        experenceJsonView.userInteractionEnabled = NO;
    };
    expTableView.JRTableViewSetValue = ^void(JRTableView* tableView, id value){
        NSMutableArray* contents = [ArrayHelper deepCopy: [value componentsSeparatedByString:COMMA]];
        tableView.contentsDictionary = [NSMutableDictionary dictionaryWithObject: contents forKey:tableView.attribute];
        [tableView reloadData];
    };
    expTableView.JRTableViewGetValue = ^id(JRTableView* tableView){
        NSMutableArray* contents = [tableView.contentsDictionary objectForKey: tableView.attribute];
        NSString* value = nil;
        for (int i = 0 ; i < contents.count; i++) {
            if (i == 0) {
                value = contents[i];
            } else {
                value = [value stringByAppendingFormat:@"%@%@",COMMA, contents[i]];
            }
        }
        return value;
    };
    experienceView.setJRComplexViewValueBlock = ^void(JRComplexView* view, id value) {
        [expTableView setValue: value];
    };
    experienceView.getJRComplexViewValueBlock = ^id(JRComplexView* view) {
        return [expTableView getValue];
    };
    
    // experience view add button
    JRButton* buttonAdd = (JRButton*)[experienceView getView: @"BTN_Add"];
    buttonAdd.didClikcButtonAction = ^void(JRButton* buttonAdd) {
        if ([JRTextFieldHelper isKeyBoardShowing]) [ViewHelper resignFirstResponserOnView: buttonAdd.superview];
        /*JsonView* experenceJsonView = */[EmployeeViewsHelper popupJsonView:@"Components" key:@"AddExperienceView" dissmiss:^(UIView *view) {
            JRComplexView* experienceComplexView = (JRComplexView*)[(JsonView*)view getView: @"experiencePopup"];
            NSString* values = [experienceComplexView getValue];
            if (! values) return ;
            
            NSString* attribute = expTableView.attribute;
            if (!expTableView.contentsDictionary) expTableView.contentsDictionary = [NSMutableDictionary dictionaryWithObject:[NSMutableArray array] forKey:attribute];
            [[expTableView.contentsDictionary objectForKey:attribute] addObject: values];
            
            [expTableView reloadData];
        }];
        
    };
    
    
    //----------- Another Tabs Views
    
    self.didShowTabView = ^void(int index, JsonDivView* tabView) {
        if (weakInstance.controlMode == JsonControllerModeCreate) return;
        
        JRButton* button = [weakInstance.tabsButtonsView.subviews objectAtIndex: index];
        NSString* buttonKey = button.attribute;
        
        //----------- Peding View
        if ([buttonKey isEqualToString:@"ZZ_TAB_BTNPending"]) {
            
            // load it from server, get the identities
            NSDictionary* objects = nil;
            NSString* employeeNO = [(((id<JRComponentProtocal>)[jsonView getView:PROPERTY_EMPLOYEENO])) getValue];
            if (! OBJECT_EMPYT(employeeNO)) {
                objects = @{PROPERTY_EMPLOYEENO: employeeNO};
            } else if (weakInstance.identification) {
                objects = [RequestModelHelper getModelIdentities: weakInstance.identification];
            }
            if (! objects) return;
            
            JRRefreshTableView* tableView = (JRRefreshTableView*)[jsonView getView:@"NESTED_PENDING.PENDING_TABLE"];
            
            
            
            // send the request
            [AppViewHelper showIndicatorInView: tableView];
            [AppServerRequester readModel: @"Approvals" department:CATEGORIE_APPROVAL objects: objects fields:@[@"pendingApprovals"] completeHandler:^(ResponseJsonModel *data, NSError *error) {
                [AppViewHelper stopIndicatorInView: tableView];
                NSString* jsonString = [[data.results firstObject] firstObject];
                NSDictionary* pendingApprovals = [CollectionHelper convertJSONStringToJSONObject: jsonString];
                NSMutableDictionary* contents = [DictionaryHelper convertToOneDimensionDictionary: pendingApprovals];
                NSMutableDictionary* realContentsDictionary = [DictionaryHelper filter:contents filter:^BOOL(id value) { return ((NSArray*)value).count == 0;}];
                [weakInstance assembleResults: realContentsDictionary tableView:tableView];
            }];
            
            
        } else if ([buttonKey isEqualToString:@"TraceStatus"]) {
            JRRefreshTableView* tableView = (JRRefreshTableView*)[jsonView getView:@"NESTED_TraceStatus.TraceStatus_TABLE"];
            
            static const NSString* unReadKey = nil;
            tableView.tableView.tableViewBaseWillShowCellAction = ^void(TableViewBase *tableViewObj, UITableViewCell *cell, NSIndexPath *indexPath) {
                // show image
                UIImageView* imageView = [ListViewControllerHelper getImageViewInCellTail: @"Read.png" cell:cell];
                NSMutableDictionary* unReadsObj = objc_getAssociatedObject(tableViewObj, &unReadKey);
                
                NSString* orderType =  [tableViewObj.keysMap objectForKey:[tableViewObj.sections objectAtIndex: indexPath.section]];
                NSString* department = [DATA.modelsStructure getCategory: orderType];
                NSString* orderNumber = [tableViewObj realContentForIndexPath: indexPath];
                
                if ([[[unReadsObj objectForKey: department] objectForKey: orderType] containsObject: orderNumber]) {
                    imageView.image = [UIImage imageNamed:@"UnRead.png"];
                } else {
                    imageView.image = [UIImage imageNamed:@"Read.png"];
                }
            };
            
            // send the request
            RequestJsonModel* requestModel = [RequestJsonModel getJsonModel];
            requestModel.path = PATH_LOGIC(DEPARTMENT_HUMANRESOURCE, @"trace");
            NSString* employeeNumber = [((id<JRComponentProtocal>)[weakInstance.jsonView getView:PROPERTY_EMPLOYEENO]) getValue];
            if (!employeeNumber) {
                employeeNumber = DATA.signedUserName;
            }
            [requestModel.parameters setObject:employeeNumber forKey:@"User"];
            [DATA.requester startPostRequest:requestModel completeHandler:^(HTTPRequester* requester, ResponseJsonModel *response, NSHTTPURLResponse *httpURLReqponse, NSError *error) {
                if (response.status) {
                    // orders
                    NSDictionary* orderResults = [response.results firstObject];
                    NSMutableDictionary* contents = [DictionaryHelper deepCopy: orderResults];
                    NSMutableDictionary* realContentsDictionary = [DictionaryHelper filter:contents filter:^BOOL(id value) { return ((NSArray*)value).count == 0;}];
                    [weakInstance assembleResults: realContentsDictionary tableView:tableView];
                    
                    // un reads
                    NSString* unreadJSON = [response.results lastObject];
                    NSMutableDictionary* unReadsObj = [DictionaryHelper deepCopy:[CollectionHelper convertJSONStringToJSONObject: unreadJSON]];
                    objc_setAssociatedObject(tableView.tableView, &unReadKey, nil, OBJC_ASSOCIATION_RETAIN);
                    objc_setAssociatedObject(tableView.tableView, &unReadKey, unReadsObj, OBJC_ASSOCIATION_RETAIN);
                }
            }];
        }
    };
}

#pragma mark - Temp Code
-(void) assembleResults: (NSMutableDictionary*)realContentsDictionary tableView:(JRRefreshTableView*)headerTableView
{
    
    // parse the contentdictionary
    NSMutableDictionary* contentsDictionary = [NSMutableDictionary dictionary];
    NSMutableDictionary* keysMap = [NSMutableDictionary dictionary];
    [TableContentHelper iterateContents: realContentsDictionary handler:^BOOL(id key, int section, id cellContent) {
        NSString* localizeSection = LOCALIZE_KEY(key);
        NSString* localizeValue = cellContent ;// LOCALIZE_KEY(value);
        if (! contentsDictionary[localizeSection]) {
            [contentsDictionary setObject:[NSMutableArray array] forKey:localizeSection];
        }
        [contentsDictionary[localizeSection] addObject: localizeValue];
        
        if (! keysMap[localizeSection]) {
            [keysMap setObject:key forKey:localizeSection];
        }
        return NO;
    }];
    
    // set the table data
    headerTableView.tableView.realContentsDictionary = realContentsDictionary;
    headerTableView.tableView.contentsDictionary = contentsDictionary;
    headerTableView.tableView.keysMap = keysMap;
    [headerTableView reloadTableData];
    
    headerTableView.tableView.tableViewBaseDidSelectAction = ^void(TableViewBase* tableViewObj, NSIndexPath* indexPath) {
        // get the department and orderType
        NSString* order = [[tableViewObj keysMap] objectForKey:[[tableViewObj sections] objectAtIndex: indexPath.section]];
        NSString* department = [DATA.modelsStructure getCategory: order];
        
        // get identificaion
        id identification = [tableViewObj realContentForIndexPath: indexPath];
        // show
        [JsonBranchHelper navigateToOrderController: department order:order identifier:identification];
    };
}

#pragma mark - Override Super Class
-(BOOL) validateSendObjects: (NSMutableDictionary*)objects order:(NSString*)order
{
    NSString* workMask = [((id<JRComponentProtocal>)[self.jsonView getView:@"wordMask"]) getValue];
    if (workMask.length < 7 || [workMask rangeOfCharacterFromSet:[NSCharacterSet decimalDigitCharacterSet]].location == NSNotFound || [workMask rangeOfCharacterFromSet:[NSCharacterSet letterCharacterSet]].location == NSNotFound) {
        [ACTION alertMessage:LOCALIZE_MESSAGE(@"PasswordEnhanced")];
        return NO;
    }
    
    return [super validateSendObjects:objects order:order];
}

-(void)translateSendObjects:(NSMutableDictionary *)objects order:(NSString *)order
{
    [super translateSendObjects:objects order:order];
    
    // rsa
    NSString* encryptWordMask = [AppRSAHelper encrypt: objects[@"wordMask"]];
    if (encryptWordMask) {
        [objects setObject: encryptWordMask forKey:@"wordMask"];
    }
    //
    if (objects[@"idCard"]) [objects setObject:[AppRSAKeysKeeper simpleEncrypty:objects[@"idCard"]] forKey:@"idCard"];
    if (objects[@"livingAddress"]) [objects setObject:[AppRSAKeysKeeper simpleEncrypty:objects[@"livingAddress"]] forKey:@"livingAddress"];
}

-(void)translateReceiveObjects:(NSMutableDictionary *)objects
{
    [super translateReceiveObjects:objects];
    
    BOOL isAllApprived = [JsonControllerHelper isAllApplied: self.order valueObjects:objects];
    if (!isAllApprived) {
        NSString* decryptWordMask = [AppRSAHelper decrypt: objects[@"wordMask"]];
        [objects setObject: decryptWordMask forKey:@"wordMask"];
    }
    
    //rsa
    //
    if (objects[@"idCard"]) [objects setObject:[AppRSAKeysKeeper simpleDecrypt:objects[@"idCard"]] forKey:@"idCard"];
    if (objects[@"livingAddress"]) [objects setObject:[AppRSAKeysKeeper simpleDecrypt:objects[@"livingAddress"]] forKey:@"livingAddress"];
}



@end