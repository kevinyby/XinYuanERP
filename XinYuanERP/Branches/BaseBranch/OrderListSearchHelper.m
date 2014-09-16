#import "OrderListSearchHelper.h"
#import "AppInterface.h"

@implementation OrderListSearchHelper
{
    BaseOrderListController* _orderListController;
    NSMutableArray* _backupCriterias ;
    
    
    TableViewBase* _searchTableView;
    NSMutableDictionary* _searchValuesDataSources;
}


- (instancetype)initWithController: (BaseOrderListController*)listController
{
    self = [super init];
    if (self) {
        _orderListController = listController;
        _backupCriterias = [[NSMutableArray alloc] initWithArray: listController.requestModel.criterias];
        
        _searchValuesDataSources = [[NSMutableDictionary alloc] init];
        
        
        _orderPropertiesMap = [DATA.modelsStructure getModelStructure: listController.order];
        _orderSearchProperties = [[_orderPropertiesMap allKeys] mutableCopy];
        _searchTableViewSuperView = [PopupTableHelper getCommonPopupTableView];
        
        [self initializeTableViewAndEvent];
    }
    return self;
}


- (void) initializeTableViewAndEvent
{
    __weak OrderListSearchHelper* weakInstance = self;
    
    // local variables
    NSString* orderType = _orderListController.order;
    NSMutableArray* orderSearchProperties = _orderSearchProperties;
    NSMutableDictionary* searchValuesDataSources = _searchValuesDataSources;
    
    JRButtonsHeaderTableView* searchHeaderTableView = (JRButtonsHeaderTableView*)[_searchTableViewSuperView viewWithTag: POPUP_TABLEVIEW_TAG];
    [searchHeaderTableView.tableView setHideSearchBar: YES];
    _searchTableView = searchHeaderTableView.tableView.tableView;
    TableViewBase* tableViewBaseObj = _searchTableView;
    
    // change the button title and button event
    JRButton* rightButton = searchHeaderTableView.rightButton;
    [rightButton setTitle:LOCALIZE_KEY(@"SEARCH") forState:UIControlStateNormal];
    rightButton.didClikcButtonAction = ^void(JRButton* button) {
        [weakInstance searchButtonAction];
    };
    
    JRButton* leftButton = searchHeaderTableView.leftButton;
    [leftButton setTitle:LOCALIZE_KEY(@"clear") forState:UIControlStateNormal];
    leftButton.didClikcButtonAction = ^void(JRButton* button) {
        [weakInstance clearButtonAction];
    };
    
    // set the table contents
    
    tableViewBaseObj.tableViewBaseDidSelectAction = ^void(TableViewBase* tableViewObj, NSIndexPath* indexPath) {
        NSString* property = orderSearchProperties[indexPath.row];
        BOOL isBooleanValue = [weakInstance isBooleanValue: property];
        if (isBooleanValue) {
            if (!searchValuesDataSources[property]) {
                [searchValuesDataSources setObject: @(YES) forKey:property];
            } else {
                [searchValuesDataSources removeObjectForKey: property];
            }
            [tableViewObj reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
        
    };
    tableViewBaseObj.tableViewBaseNumberOfSectionsAction = ^NSInteger(TableViewBase* tableViewObj) {
        return 1;
    };
    tableViewBaseObj.tableViewBaseNumberOfRowsInSectionAction = ^NSInteger(TableViewBase* tableViewObj, NSInteger section) {
        return orderSearchProperties.count;
    };
    tableViewBaseObj.tableViewBaseCellForIndexPathAction = ^UITableViewCell*(TableViewBase* tableViewObj, NSIndexPath* indexPath, UITableViewCell* oldCell) {
        NSString* property = orderSearchProperties[indexPath.row];
        
        // Label
        NSInteger labelTag = 1000111;
        JRLocalizeLabel* label = (JRLocalizeLabel*)[oldCell.contentView viewWithTag: 1000111];
        if (!label) {
            label = [[JRLocalizeLabel alloc] initWithFrame:CanvasRect(10, 25, 120, 70)];
            label.tag = labelTag;
            [oldCell.contentView addSubview: label];
            
            label.font = [UIFont systemFontOfSize: CanvasFontSize(25)];
            label.disableChangeTextTransition = YES;
        }
        label.text = nil;
        
        
        // TextField
        NSInteger textFieldTag = 1000222;
        JRTextField* textField = (JRTextField*)[oldCell.contentView viewWithTag: textFieldTag];
        CGRect rect = CanvasRect(140, 15, 200, 50);
        if (!textField) {
            textField = [[JRTextField alloc] init];
            textField.tag = textFieldTag;
            [oldCell.contentView addSubview: textField];
            
            textField.borderStyle = UITextBorderStyleNone;
            textField.textAlignment = NSTextAlignmentCenter;
            [ColorHelper setBorder: textField color:[UIColor flatGrayColor]];
        }
        textField.frame = rect;
        textField.textFieldDidClickAction = nil;
        [textField setValue: nil];
        textField.hidden = YES;
        
        
        // Checkbox
        NSInteger checkBoxTag = 3000333;
        JRCheckBox* checkBox = (JRCheckBox*)[oldCell.contentView viewWithTag: checkBoxTag];
        if (!checkBox) {
            checkBox = [[JRCheckBox alloc] initWithFrame:CanvasRect(280, 0, 80, 80)];
            checkBox.tag = checkBoxTag;
            [oldCell.contentView addSubview: checkBox];
            
            [checkBox setSize:CanvasSize(80, 80)];
        }
        checkBox.checked = NO;
        checkBox.hidden = YES;
        
        
        // set text and date event
        NSString* text = APPLOCALIZES(orderType, property);
        
        BOOL isBooleanValue = [weakInstance isBooleanValue: property];
        if (isBooleanValue) {
            
            checkBox.hidden = NO;
            text = [LOCALIZE_KEY(@"if") stringByAppendingString: text];
            
        } else {
            
            textField.hidden = NO;
            
            NSArray* levelApps = @[levelApp1, levelApp2, levelApp3, levelApp4];
            if ([levelApps containsObject: property]) {
                
                text = [text stringByAppendingString: LOCALIZE_KEY(@"people")];
                
            } else {
                
                BOOL isDate = [weakInstance isDateValue: property];
                if (isDate) {
                    
                    [textField addOriginX: -CanvasW(20)];
                    [textField addSizeWidth: CanvasW(40)];
                    
                    textField.textFieldDidClickAction = ^void(JRTextField* textFieldObj) {
                        
                        
                        // From
                        [ActionSheetDatePicker showPickerWithTitle: LOCALIZE_KEY(@"from") datePickerMode:UIDatePickerModeDate selectedDate:[NSDate date] doneBlock:^(NSDate *selectedDateFrom, UITextField* origin1) {
                            
                            
                            // get the "From" date   ...
                            NSString* fromString = [DateHelper stringFromDate:selectedDateFrom pattern:PATTERN_DATE];
                            origin1.text = fromString;
                            
                            
                            // To
                            [ActionSheetDatePicker showPickerWithTitle: LOCALIZE_KEY(@"to") datePickerMode:UIDatePickerModeDate selectedDate:selectedDateFrom doneBlock:^(NSDate *selectedDateTo, UITextField* origin2) {
                                
                                
                                // get the "To" date   ...
                                NSString* fromString = origin2.text;
                                NSString* toString = [DateHelper stringFromDate:selectedDateTo pattern:PATTERN_DATE];
                                NSString* scopeString = [fromString stringByAppendingFormat:@" ~ %@", toString ];
                                origin2.text = scopeString;
                                
                                
                            } cancelBlock:^{ origin1.text = nil; } origin:origin1];
                        } cancelBlock:^{ textFieldObj.text = nil; } origin:textFieldObj];
                        
                        
                    };
                    
                    
                }
                
            }
            
        }
        
        
        //        NSLog(@"++ %@ : %@", property, text);
        label.text = text;
        [label adjustWidthToFontText];
        
        
        
        // clear background and set background
        [weakInstance clearCellBackgroundColor: oldCell];
        if (isBooleanValue) {
            if (searchValuesDataSources[property]) {
                [weakInstance setCellBackgroundColor: oldCell];
            }
        }
        // set value to checkbox and textfield
        if (searchValuesDataSources[property]) {
            checkBox.checked = [searchValuesDataSources[property] boolValue];
            [textField setValue: searchValuesDataSources[property]] ;
        }
        
        // set changed data to datasource
        if (!textField.textFieldDidSetTextBlock) {
            textField.textFieldDidSetTextBlock = ^void(NormalTextField* textField, NSString* oldText) {
                [weakInstance valueDidChangeAction: textField];
            };
        }
        if (!checkBox.stateChangedBlock) {
            checkBox.stateChangedBlock = ^void(JRCheckBox *checkBox) {
                [weakInstance valueDidChangeAction: checkBox];
            };
        }
        
        
        return oldCell;
    };
}



#pragma mark - Private Methods

-(void) setCellBackgroundColor: (UITableViewCell*)cell
{
    [ColorHelper setBackGround: cell color:[[UIColor flatBlueColor] colorWithAlphaComponent: 0.3]];
}

-(void) clearCellBackgroundColor: (UITableViewCell*)cell
{
    [ColorHelper setBackGround: cell color:[UIColor clearColor]];
}

-(void) valueDidChangeAction: (id)sender
{
    NSIndexPath* indexPath = [TableViewHelper getIndexPath: _searchTableView cellSubView:sender];
    if (!indexPath) return;
    UITableViewCell* cell = [TableViewHelper getTableViewCell: _searchTableView cellSubView:sender];
    
    NSString* property = _orderSearchProperties[indexPath.row];
//    NSLog(@"%d,%d : %@", indexPath.section, indexPath.row, property);
    id value = nil;
    
    if ([sender isKindOfClass:[JRTextField class]]) {
        
        JRTextField* textField = (JRTextField*)sender;
        value = [textField getValue];
        
    } else if ([sender isKindOfClass:[JRCheckBox class]]) {
        
        JRCheckBox* checkBox = (JRCheckBox*)sender;
        value = @(checkBox.checked);
        [self setCellBackgroundColor: cell];
        
    }
    
    if (!OBJECT_EMPYT(value)) {
        [_searchValuesDataSources setObject: value forKey:property];
    } else {
        [_searchValuesDataSources removeObjectForKey: property];
    }
}




-(BOOL) isBooleanValue: (NSString*)property
{
    return [self isProperty: property valueType:@"boolean"];
}

-(BOOL) isDateValue: (NSString*)property
{
    return [self isProperty: property valueType:@"Date"];
}

-(BOOL) isProperty: (NSString*)property valueType: (NSString*)type
{
    BOOL result = [_orderPropertiesMap[property] isEqualToString:type];
    return result;
}





#pragma mark - Button Action

-(void) searchButtonAction
{
    NSLog(@"--: %@", _searchValuesDataSources);
    
    RequestJsonModel* requesJsonModel = _orderListController.requestModel;
    NSMutableArray* criterias = requesJsonModel.criterias;
    
    for (NSString* key in _searchValuesDataSources) {
        NSString* value = _searchValuesDataSources[key];
        
        BOOL isBoolValue = [self isBooleanValue: key];

    }
    
    [self hideSearchTableView];
}



-(void) clearButtonAction
{
    [_searchValuesDataSources removeAllObjects];
    [_searchTableView reloadData];
}





#pragma mark - Public Methods

-(void) showSearchTableView
{
    if ([PopupViewHelper isCurrentPopingView]) {
        return;
    }
    [PopupViewHelper popView:_searchTableViewSuperView willDissmiss:nil];
}


-(void) hideSearchTableView
{
    [PopupViewHelper dissmissCurrentPopView];
}

@end
