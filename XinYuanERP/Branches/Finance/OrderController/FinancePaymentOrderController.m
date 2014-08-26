#import "FinancePaymentOrderController.h"
#import "FinancePaymentBillCell.h"
#import "AppInterface.h"


#define STAFF_CATEGORY              @"staffCategory"
#define STAFF_NUMBER                @"staffNO"


// Table Left   ------------ Begin ---------------------------------

#define ReferenceOrder_Attr_TotalShouldPay @"totalPay"      // the cost

// Table Left   ------------ End ---------------------------------


@implementation FinancePaymentOrderController
{
    JRRefreshTableView* tableLeft;
    JRLazyLoadingTable* tableRight;
    
    // Table Right   ------------ Begin ---------------------------------
    NSMutableArray* tableRightSectionContents;
    NSMutableArray* tableRightContentsImages;
    // Table Right   ------------ End ---------------------------------
    
    
    // Table Left   ------------ Begin ---------------------------------
    NSMutableArray* tableLeftSectionBillsContents;
    // Table Left   ------------ End ---------------------------------
}

-(void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    NSLog(@"FinancePaymentOrderController ----- didReceiveMemoryWarning");
}

-(void)dealloc
{
    NSLog(@"FinancePaymentOrderController ----- dealloc");
    
    [tableRight stopLazyLoading];
    
    tableLeft = nil;
    tableRight = nil;
    
    [tableRightSectionContents removeAllObjects];
    tableRightSectionContents = nil;
    
    [tableRightContentsImages removeAllObjects];
    tableRightContentsImages = nil;
    
    [tableLeftSectionBillsContents removeAllObjects];
    tableLeftSectionBillsContents = nil;
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    JsonView* jsonView = self.jsonView;
    __weak FinancePaymentOrderController* weakSelf = self;
    NSDictionary* specConfig = self.specifications[@"Specifications"];
    
    
    
    
    // -------
    
    
    
    // NESTED_MAIN   ------------ Begin ---------------------------------
    // staff categry & staff number
    JRLabelCommaTextFieldView* staffCategory = (JRLabelCommaTextFieldView*)[jsonView getView: @"NESTED_MAIN_Header.staffCategory"];
    JRLabelCommaTextFieldView* staffNO = (JRLabelCommaTextFieldView*)[jsonView getView: @"NESTED_MAIN_Header.staffNO"];
    
    JRTextField* staffCategoryTextField = staffCategory.textField;
    __weak JRTextField* staffNOTextField = staffNO.textField;

    NSArray* keys =  @[KEY_EMPLOYEE, KEY_VENDOR, KEY_CLIENT, KEY_OTHERS];
    NSArray* values = @[MODEL_EMPLOYEE, MODEL_VENDOR, MODEL_CLIENT, KEY_OTHERS];
    
    // pop
    staffCategoryTextField.isEnumerateValue = YES;
    staffCategoryTextField.enumerateValues = values;
    staffCategoryTextField.enumerateValuesLocalizeKeys = keys;
    staffCategoryTextField.textFieldDidClickAction = ^void(JRTextField* textField) {
        [CustomPickerView popupPicker: textField keys:keys doneBlock:^(JRTextField* sender, unsigned int selectedIndex, NSString *selectedVisualValue) {
            sender.text = selectedVisualValue;        // set text

            staffNOTextField.text = nil;
            NSString* selectedMemberType = [sender.enumerateValues objectAtIndex: selectedIndex];
            staffNOTextField.memberType = selectedMemberType;
            
            if ([selectedMemberType isEqualToString: KEY_OTHERS]) {
                staffNOTextField.textFieldDidClickAction = nil;
                [staffNOTextField becomeFirstResponder];
            } else {
                // pop
                [weakSelf popupMembersPicker: selectedMemberType textField:staffNOTextField];
                // change the staff number click action
                staffNOTextField.textFieldDidClickAction = ^void(JRTextField* textField) {
                    [weakSelf popupMembersPicker: selectedMemberType textField:textField];
                };
            }
        }];
    };
    // NESTED_MAIN   ------------ End ---------------------------------
    
    
    
    
    
    
    
    // Table Left   ------------ Begin ---------------------------------
    // left table-------------
    tableLeftSectionBillsContents = [[NSMutableArray alloc] init];
    NSMutableArray* weaktableLeftSectionBillsContents = tableLeftSectionBillsContents;
    tableLeft = (JRRefreshTableView*)[jsonView getView:@"TABLE_Left"];
    tableLeft.tableView.tableViewBaseNumberOfSectionsAction = ^NSInteger(TableViewBase* tableViewObj) { return 1; };
    tableLeft.tableView.tableViewBaseCanEditIndexPathAction = ^BOOL(TableViewBase *tableViewObj, NSIndexPath *indexPath) {
        if (indexPath.row == weaktableLeftSectionBillsContents.count) return NO;
        return YES;
    };
    tableLeft.tableView.tableViewBaseShouldDeleteContentsAction = ^BOOL(TableViewBase *tableViewObj, NSIndexPath *indexPath) {
        if (indexPath.row == weaktableLeftSectionBillsContents.count) {
            return NO;
        } else {
            [weaktableLeftSectionBillsContents removeObjectAtIndex: indexPath.row];     // keep the data source update . or will error occur
            return YES;
        }
    };
    tableLeft.tableView.tableViewBaseNumberOfRowsInSectionAction = ^NSInteger(TableViewBase* tableViewObj, NSInteger section) {
        return weakSelf.controlMode == JsonControllerModeCreate ? weaktableLeftSectionBillsContents.count + 1 : weaktableLeftSectionBillsContents.count;
    };
    UITableViewCell *(^ previousCellAction)(TableViewBase *, NSIndexPath *, UITableViewCell *) = tableLeft.tableView.tableViewBaseCellForIndexPathAction;
    tableLeft.tableView.tableViewBaseCellForIndexPathAction = ^UITableViewCell*(TableViewBase* tableViewObj, NSIndexPath* indexPath, UITableViewCell* oldCell) {
        if (previousCellAction) previousCellAction(tableViewObj, indexPath, oldCell);       // back ground , border , radius
        FinancePaymentBillCell* financePaymentBillCellView = (FinancePaymentBillCell*)[oldCell viewWithTag: 2030];
        
        // alloc add item view
        if (! financePaymentBillCellView) {
            financePaymentBillCellView = [[FinancePaymentBillCell alloc] init];
            financePaymentBillCellView.textFieldDelegate = weakSelf;
            [FrameHelper setComponentFrame: specConfig[@"LeftTableOrderCellFrame"] component:financePaymentBillCellView];
            // frames and subrenders
            for (int i = 0; i < financePaymentBillCellView.subviews.count; i++) {
                NSArray* frame = [specConfig[@"LeftTableOrderCellElementsFrames"] safeObjectAtIndex: i];
                UIView* subview = [financePaymentBillCellView.subviews objectAtIndex: i];
                [FrameHelper setComponentFrame: frame component:subview];
                // subRender
                if ([subview conformsToProtocol:@protocol(JRComponentProtocal)]) {
                    [((id<JRComponentProtocal>)subview) subRender: [specConfig[@"LeftTableOrderCellElementsSubRenders"] safeObjectAtIndex: i]];
                }
            }
            financePaymentBillCellView.tag = 2030;
            [oldCell addSubview: financePaymentBillCellView];
            
            // did click first cell action
            JRTextField* itemOrderNOTf = financePaymentBillCellView.itemOrderNOTf;
            itemOrderNOTf.textFieldDidClickAction = ^void(JRTextField* textField) {
                [weakSelf didTapBillItemFirstRowAction: textField];
            };
        }
        
        // set data
        NSMutableDictionary* billValues = [weaktableLeftSectionBillsContents safeObjectAtIndex: indexPath.row];
        [financePaymentBillCellView setBillValues: billValues];
        return oldCell;
    };
    
    // Table Left   ------------ End ---------------------------------
    
    
    
    
    // Table Right   ------------ Begin ---------------------------------
    // super behaviour
    JRButton* priorPageBTN = (JRButton*)[self.jsonView getView:json_BTN_PriorPage];
    JRButton* nextPageBTN = (JRButton*)[self.jsonView getView: json_BTN_NextPage];
    JRButton* backBTN = (JRButton*)[self.jsonView getView: JSON_KEYS(json_NESTED_header, json_BTN_Back)];
    
    NormalButtonDidClickBlock superPriorPageBTNBlock = priorPageBTN.didClikcButtonAction;
    priorPageBTN.didClikcButtonAction = ^void(id sender) {
        [tableRight stopLazyLoading];
        superPriorPageBTNBlock(sender);
    };
    NormalButtonDidClickBlock superNextPageBTNBlock = nextPageBTN.didClikcButtonAction;
    nextPageBTN.didClikcButtonAction = ^void(id sender) {
        [tableRight stopLazyLoading];
        superNextPageBTNBlock(sender);
    };
    backBTN.didClikcButtonAction = ^void(id sender) {
        [tableRight stopLazyLoading];
        [VIEW.navigator popViewControllerAnimated: YES];
    };
    
    // right table-----------
    
    tableRight = (JRLazyLoadingTable*)[jsonView getView:@"TABLE_Right"];
    // right table data
    tableRightContentsImages = tableRight.loadImages;
    tableRight.cellImageViewFrame = [RectHelper parseRect: specConfig[@"RightTableImageFrame"]];
    
    tableRightSectionContents = [NSMutableArray array];
    tableRight.tableView.contentsDictionary = [[NSMutableDictionary alloc] initWithObjectsAndKeys:tableRightSectionContents, @"IMAGES_NAME", nil];
    
    
    tableRight.tableView.valuesXcoordinates = @[specConfig[@"RightTableImageNameX"]];
    tableRight.tableView.tableViewBaseDidSelectAction = ^void(TableViewBase* tableViewObj, NSIndexPath* indexPath){
        UITableViewCell* oldCell = [tableViewObj cellForRowAtIndexPath: indexPath];
        JRImageView* jrimageView = (JRImageView*)[oldCell viewWithTag: 3002];
        [BrowseImageView browseImage: jrimageView adjustSize: 0];
    };
    
    
    // button ,  take photo to list
    JRButton* takePhotoButton = (JRButton*)[jsonView getView: @"ZZ_BTNTake_Picture"];
    [JRComponentHelper setupPhotoPickerWithInteractivView: takePhotoButton handler:^(AppImagePickerController *imagePickerController) {
        imagePickerController.didFinishPickingImage = ^void(UIImagePickerController* controller, UIImage* image) {
            [tableRightContentsImages addObject: image];
            
            NSInteger index = [[tableRightSectionContents lastObject] integerValue];
            NSString* imageName = [NSString stringWithFormat: @"%d", ++index];
            [tableRightSectionContents addObject: imageName];
            
            [tableRight reloadTableData];
        };
    }];
    // Table Right   ------------ End ---------------------------------
    
    
}


#pragma mark - Override Super Class Methods
-(RequestJsonModel*) assembleReadRequest:(NSDictionary*)objects
{
    RequestJsonModel* requestModel = [RequestJsonModel getJsonModel];
    requestModel.path = PATH_LOGIC_READ(self.department);
    [requestModel addModels: self.order, BILL_FinancePaymentBill, nil];
    [requestModel addObjects: objects, @{}, nil];
    [requestModel.preconditions addObjectsFromArray: @[@{}, @{attr_paymentOrderNO: @"0-0-orderNO"}]];
    return requestModel;
}

-(NSMutableDictionary*) assembleReadResponse: (ResponseJsonModel*)response
{
    // Table Left   ------------ Begin ---------------------------------
    
    // load the data to table left
    NSMutableArray* billContents = [ArrayHelper deepCopy:[response.results lastObject]];
    [tableLeftSectionBillsContents setArray: billContents];
    [tableLeft reloadTableData];
    
    // get other other order to caculate , all this is to caculate the shoul pay
    // 1 . get all the same referenceOrderNO in the bills
    RequestJsonModel* requestModel = [RequestJsonModel getJsonModel];
    requestModel.path = PATH_LOGIC_READ(SUPERBRANCH);
    
    NSArray* perviousBillFields = @[attr_referenceOrderNO, attr_realPaid];
    NSArray* referenceOrderFields = @[PROPERTY_ORDERNO, ReferenceOrder_Attr_TotalShouldPay];
    for (NSInteger i = 0 ; i < billContents.count; i++) {
        NSDictionary* content = [billContents objectAtIndex:i];
        int identifier = [[content objectForKey: PROPERTY_IDENTIFIER] intValue];
        NSString* referenceOrderNO = [content objectForKey: attr_referenceOrderNO];
        NSString* referenceOrderType = [content objectForKey: attr_referenceOrderType];
        NSString* referenceDepartment = [DATA.modelsStructure getCategory: referenceOrderType];
        
        // get the previous bills , to caculate the money have been paid
        [requestModel.fields addObject: perviousBillFields];                            // real pay
        [requestModel addModel: DOT_CONNENT(DEPARTMENT_FINANCE, BILL_FinancePaymentBill)];
        [requestModel addObject: @{attr_referenceOrderNO : referenceOrderNO}];
        [requestModel.criterias addObject:@{@"and": [NSMutableDictionary dictionaryWithDictionary:@{PROPERTY_IDENTIFIER: [NSString stringWithFormat:@"%@(%d)",CRITERIAL_LT, identifier]}]}];
        
        // get the reference order , to get the 'total pay'
        [requestModel.fields addObject: referenceOrderFields];                         // total pay
        [requestModel addModel: DOT_CONNENT(referenceDepartment, referenceOrderType)];
        [requestModel addObject: @{PROPERTY_ORDERNO : referenceOrderNO}];
        [requestModel.criterias addObject:@{}];
    }
    
    // 2 . send the request to get the datas, caculate the should pay
    [AppViewHelper showIndicatorInView: tableLeft];
    [DATA.requester startPostRequest: requestModel completeHandler:^(HTTPRequester *requester, ResponseJsonModel *model, NSHTTPURLResponse *httpURLReqponse, NSError *error) {
        if (model.status) {
            [AppViewHelper stopIndicatorInView: tableLeft];
            NSArray* results = model.results;
            for (NSInteger i = 0; i < results.count; i++,i++) {
                // get previous pay
                NSArray* prevoiousBillValues = [results objectAtIndex: i];
                float beforeBillTotalPaid = 0;
                for (NSInteger j = 0; j < prevoiousBillValues.count; j++) {
                    NSArray* values = [prevoiousBillValues objectAtIndex:j ];
                    float paid = [[values objectAtIndex:[perviousBillFields indexOfObject:attr_realPaid]] floatValue];
                    beforeBillTotalPaid += paid;
                }
                
                // get total pay
                NSArray* referenceOrderValues = [[results objectAtIndex: i+1] firstObject];     // id , only one value
                float totalPay = [[referenceOrderValues objectAtIndex:[referenceOrderFields indexOfObject:ReferenceOrder_Attr_TotalShouldPay]] floatValue];
                
                // get the left
                NSNumber* shouldPay = [NSNumber numberWithFloat: (totalPay - beforeBillTotalPaid)];
                
                // set to data sources
                [[tableLeftSectionBillsContents objectAtIndex:i/2] setObject: shouldPay forKey:attr_SHOULD_PAY];
            }
            
        } else {
            [ACTION alertError: error];
        }
        
        [tableLeft reloadTableData];
    }];
    // Table Left   ------------ End ---------------------------------
    

    // call super . load the data to json view
    return [super assembleReadResponse:response];
}

-(void) didRenderWithReceiveObjects: (NSMutableDictionary*)objects
{
    [super didRenderWithReceiveObjects: objects];
    
    // Table Right   ------------ Begin ---------------------------------
    // load right table images file names  , set the imagepaths , then the table do lazy loading by itself
    [tableRightSectionContents removeAllObjects];
    tableRight.loadImagePaths = nil;
    [tableRight reloadTableData];
    
    NSString* rightTableImagesPath = [self getRightTableImagePath];
    [DATA.requester startDownloadRequest:IMAGE_URL(DOWNLOAD)
                              parameters:@{@"PATH":[NSString stringWithFormat:@"/%@/",rightTableImagesPath]}
                         completeHandler:^(HTTPRequester* requester, ResponseJsonModel *data, NSHTTPURLResponse *httpURLReqponse, NSError *error) {
                             NSArray *fileNames = data.results;
                             for (NSString* fileName in fileNames) {
                                 if ([fileName hasSuffix: @"png"] || [fileName hasSuffix: @"jpg"]) {
                                     [tableRightSectionContents addObject: fileName];
                                 }
                             }
                             
                             // occupy the position , ensure the image against to its name
                             NSMutableArray* loadingImagesPaths = [NSMutableArray array];
                             for (int i = 0; i < fileNames.count; i++) {
                                 NSString* fileName = fileNames[i];
                                 NSString* imagePath = [rightTableImagesPath stringByAppendingPathComponent: fileName];
                                 [loadingImagesPaths addObject: imagePath];
                             }
                             tableRight.loadImagePaths = loadingImagesPaths;
                             [tableRight reloadTableData];
                         }];
    // Table Right   ------------ End ---------------------------------
    
}

-(RequestJsonModel*) assembleSendRequest: (NSMutableDictionary*)withoutImagesObjects order:(NSString*)order department:(NSString*)department
{
    RequestJsonModel* requestModel = [RequestJsonModel getJsonModel];
    requestModel.path = PATH_LOGIC_CREATE(department);
    [requestModel addModel: order];
    [requestModel addObject: withoutImagesObjects ];
    [requestModel.preconditions addObject: @{}];
    
    for (int i = 0; i < tableLeftSectionBillsContents.count; i++) {
        NSMutableDictionary* itemValues = tableLeftSectionBillsContents[i];
        [requestModel addModel: BILL_FinancePaymentBill];
        [requestModel addObject: itemValues];
        [requestModel.preconditions addObject: @{attr_paymentOrderNO:@"0-orderNO"}];
    }
    
    return requestModel;
}

-(void) didSuccessSendObjects: (NSMutableDictionary*)objects response:(ResponseJsonModel*)response
{
    [super didSuccessSendObjects: objects response:response];
    
    
    // Table Right   ------------ Begin ---------------------------------
    //  save right images
    NSArray* fileNames = tableRightSectionContents;
    NSArray* rightTableImageNames = [self getRightTableImagesNames: fileNames];
    NSMutableArray* rightTableImagesDatas = [NSMutableArray array];
    for (int i = 0; i < tableRightContentsImages.count; i++) {
        UIImage* image = tableRightContentsImages[i];
        [rightTableImagesDatas addObject: UIImageJPEGRepresentation(image, 0.5)];
    }
    __block NSError* errorOccur = nil;
    [AppServerRequester saveImages: rightTableImagesDatas paths:rightTableImageNames completeHandler:^(id identification, ResponseJsonModel *data, NSError *error, BOOL isFinish) {
        if (error) errorOccur = error;
        if (isFinish) {
            if (errorOccur) {
                // TODO ......
                [PopupViewHelper popAlert:@"Failed" message:@"Image Upload Failed ." style:0 actionBlock:^(UIView *popView, NSInteger index) {
                    [VIEW.navigator popViewControllerAnimated: YES];
                } dismissBlock:nil buttons:LOCALIZE_KEY(@"OK"), nil];
                
            }
        }
    }];
    // Table Right   ------------ End ---------------------------------
}


#pragma mark - Private Methods

// Table Right   ------------ Begin ---------------------------------
// Right Table Image Names
-(NSArray*) getRightTableImagesNames: (NSArray*)names
{
    NSString* rightTableImagesPath = [self getRightTableImagePath];
    
    NSMutableArray* imagesFullPaths = [NSMutableArray array];
    for (int i = 0; i < names.count; i++) {
        NSString* imageName = [names objectAtIndex: i] ;
        if(OBJECT_EMPYT([imageName pathExtension])) {
            imageName = [imageName stringByAppendingPathExtension:@"jpg"];
        }
        NSString* imageFullName = [rightTableImagesPath stringByAppendingPathComponent:imageName];
        [imagesFullPaths addObject: imageFullName];
    }
    return imagesFullPaths;
}
-(NSString*) getRightTableImagePath
{
    NSString* signatureImagePath = [JsonControllerHelper getImageNamePathWithOrder:self.order attribute:@"IMG_Signature" jsoncontroller:self];
    NSString* orderResourcesPath = [signatureImagePath stringByDeletingLastPathComponent];
    NSString* rightTableImagePath = [orderResourcesPath stringByAppendingPathComponent: @"images"];
    return  rightTableImagePath;
}
// Table Right   ------------ End ---------------------------------







-(void) popupMembersPicker:(NSString*)memberType textField:(JRTextField*)textField
{
    PickerModelTableView *pickerTableView = [PickerModelTableView popupWithModel: memberType willDimissBlock:nil];
    pickerTableView.titleHeaderViewDidSelectAction = ^void(JRTitleHeaderTableView* headerTableView, NSIndexPath* indexPath){
        
        FilterTableView* filterTableView = (FilterTableView*)headerTableView.tableView.tableView;
        NSIndexPath* realIndexPath = [filterTableView getRealIndexPathInFilterMode: indexPath];
        
        NSString* number = [filterTableView realContentForIndexPath: realIndexPath];
        [textField setValue: number];
        [PickerModelTableView dismiss];
    };
}


// Table Left   ------------ Begin ---------------------------------
-(void) didTapBillItemFirstRowAction: (JRTextField*) textField
{
    NSInteger row = [TableViewHelper getIndexPath: tableLeft.tableView cellSubView:textField].row;
    NSInteger lastRow = [tableLeft.tableView numberOfRowsInSection:0] - 1;
    
    // is the last row , do add
    if ( row == lastRow && OBJECT_EMPYT([textField getValue])) {
        
        NSArray* departments = @[DEPARTMENT_WAREHOUSE];
        NSArray* orderTypes = @[ORDER_WHPurchaseOrder];
        NSArray* orderfields = @[@[PROPERTY_ORDERNO, @"purchaseDate", @"company", ReferenceOrder_Attr_TotalShouldPay]];
        ContentFilterBlock filterblock_one = ^void(int elementIndex , int innerCount, int outterCount, NSString* section, id cellElement, NSMutableArray* cellRepository){
            if (elementIndex <= 2) {
                if (cellElement) {
                    [cellRepository addObject: cellElement];
                }
            }
        };
        NSArray* contentsFilters = @[filterblock_one];
        
        [CustomPickerView popupPicker: textField keys:orderTypes doneBlock:^(id sender, unsigned int selectedIndex, NSString *selectedValue) {
            NSString* department = [departments objectAtIndex: selectedIndex];
            NSString* order = [orderTypes objectAtIndex: selectedIndex];
            NSArray* fields = [orderfields objectAtIndex: selectedIndex];
            ContentFilterBlock filter = [contentsFilters objectAtIndex: selectedIndex];
            
            UIActivityIndicatorView* indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            
            // get the data from server
            __block PickerModelTableView* popTableViewRef = nil;
            HTTPRequester* requester = [AppServerRequester readModel:order department: department objects:nil fields:fields completeHandler:^(ResponseJsonModel *data, NSError *error) {
                [indicatorView stopAnimating];
                // assemble the results
                [ListViewControllerHelper assembleTableContents: popTableViewRef.tableView.tableView objects:data.results keys:data.models filter:filter];
                [popTableViewRef.tableView.tableView reloadData];
            }];
            
            // pop table view to choose , data loading on avove requester
            PickerModelTableView *pickerTableView = [PickerModelTableView popupWithModel:order willDimissBlock:^(UIView *view) {
                [requester cancelRequester];
            }];
            popTableViewRef = pickerTableView;
            // show indicator
            [pickerTableView addSubview: indicatorView];
            indicatorView.center = [pickerTableView middlePoint];
            [indicatorView startAnimating];
            // set header x
            pickerTableView.tableView.headersXcoordinates = @[@(0), @(150), @(450)];
            // headers localize
            NSMutableArray* array = [NSMutableArray array];
            for (int i = 0; i < 3; i++) {
                [array addObject: LOCALIZE_CONNECT_KEYS(order, fields[i])];
            }
            pickerTableView.tableView.headers = [LocalizeHelper localize: array];
            
            // choose, the pop action to select
            pickerTableView.tableView.tableView.tableViewBaseDidSelectAction = ^void(TableViewBase* tablViewBaseObject, NSIndexPath* indexPath) {
                NSIndexPath* realIndexPath = [(FilterTableView*)tablViewBaseObject getRealIndexPathInFilterMode: indexPath];
                
                id referenceOrderNOid = [[tablViewBaseObject realContentForIndexPath: realIndexPath] objectAtIndex: [fields indexOfObject:PROPERTY_ORDERNO]];  //
                
                [PopupViewHelper popAlert: LOCALIZE_MESSAGE(@"SelectAnAction") message:nil style:0 actionBlock:^(UIView *popView, NSInteger index) {
                    // read
                    if (index == 1) {
                        [JsonBranchHelper navigateToOrderController: department order:order identifier:referenceOrderNOid];
                        // add
                    } else if (index == 2) {
                        // check if have already in the payment order
                        NSInteger result = [self checkIsContainsId: referenceOrderNOid contents:tableLeftSectionBillsContents];
                        
                        // then really add it
                        if (result == NSNotFound) {
                            id totalShouldPay = [[tablViewBaseObject realContentForIndexPath: realIndexPath] objectAtIndex: [fields indexOfObject: ReferenceOrder_Attr_TotalShouldPay]];
                            
                            // get the previous bills , to caculate the money have been paid
                            RequestJsonModel* requestModel = [RequestJsonModel getJsonModel];
                            requestModel.path = PATH_LOGIC_READ(self.department);
                            NSArray* perviousBillFields = @[attr_referenceOrderNO, attr_realPaid];
                            [requestModel.fields addObject: perviousBillFields];                            // real pay
                            [requestModel addModel: BILL_FinancePaymentBill];
                            [requestModel addObject: @{attr_referenceOrderNO : referenceOrderNOid}];
                            
                            [AppViewHelper showIndicatorInView: tableLeft];
                            [DATA.requester startPostRequest:requestModel completeHandler:^(HTTPRequester *requester, ResponseJsonModel *model, NSHTTPURLResponse *httpURLReqponse, NSError *error) {
                                if (model.status) {
                                    [AppViewHelper stopIndicatorInView: tableLeft];
                                    NSArray* results = model.results;
                                    // caculate the left of should pay ..
                                    
                                    float beforeBillTotalPaid = 0;
                                    for (NSInteger i = 0; i < results.count; i++,i++) {
                                        // get previous pay
                                        NSArray* prevoiousBillValues = [results objectAtIndex: i];
                                        for (NSInteger j = 0; j < prevoiousBillValues.count; j++) {
                                            NSArray* values = [prevoiousBillValues objectAtIndex:j ];
                                            float paid = [[values objectAtIndex:[perviousBillFields indexOfObject:attr_realPaid]] floatValue];
                                            beforeBillTotalPaid += paid;
                                        }
                                    }
                                    
                                    // get the left
                                    NSNumber* shouldPay = [NSNumber numberWithFloat: ([totalShouldPay floatValue] - beforeBillTotalPaid)];
                                    
                                    // reload the table data
                                    [tableLeftSectionBillsContents addObject: [DictionaryHelper deepCopy:@{
                                                                                                           attr_referenceOrderType:order,
                                                                                                           attr_referenceOrderNO:referenceOrderNOid,
                                                                                                           attr_SHOULD_PAY:shouldPay,
                                                                                                           }]];
                                    [tableLeft reloadTableData];
                                    
                                } else {
                                    [ACTION alertError: error];
                                }
                            }];
                            
                            // dismiss the table
                            [PickerModelTableView dismiss];
                        } else {
                            [ACTION alertWarning: LOCALIZE_MESSAGE_FORMAT(@"AlreadyExist", referenceOrderNOid)];
                            [tableLeft.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:result inSection:0] animated:YES scrollPosition:UITableViewScrollPositionMiddle];
                        }
                        
                    }
                } dismissBlock:nil buttons:LOCALIZE_KEY(KEY_CANCEL), LOCALIZE_KEY(@"read"), LOCALIZE_KEY(KEY_ADD), nil];
            };
        }];
        
    // not the last row
    } else {
        [PopupViewHelper popAlert: LOCALIZE_MESSAGE(@"SelectAnAction") message:nil style:0 actionBlock:^(UIView *popView, NSInteger index) {
            // read
            if (index == 1) {
                // get the department and orderType
                NSString* order = ((FinancePaymentBillCell*)textField.superview).order;
                NSString* department = [DATA.modelsStructure getCategory: order];
                
                // get identificaion
                id identification = [[tableLeftSectionBillsContents objectAtIndex: row] objectForKey:attr_referenceOrderNO];
                // show
                [JsonBranchHelper navigateToOrderController: department order:order identifier:identification];
            }
        } dismissBlock:nil buttons:LOCALIZE_KEY(KEY_CANCEL), LOCALIZE_KEY(@"read"), nil];
    }
}

-(NSInteger) checkIsContainsId: (NSString*)itemNO contents:(NSArray*)contents
{
    for (int i = 0; i < contents.count; i++) {
        NSDictionary* itemValues = [contents objectAtIndex: i];
        if ([itemValues[attr_referenceOrderNO] isEqualToString: itemNO]) {
            return i;
        }
    }
    return NSNotFound;
}




#pragma mark - UITextFieldDelegate
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    JRTextField* jrTextField = (JRTextField*)textField;
    id value = [jrTextField getValue];
    if (value) {
        NSIndexPath* indexPath = [TableViewHelper getIndexPath: tableLeft.tableView cellSubView:textField];
        NSMutableDictionary* itemValues = [tableLeftSectionBillsContents safeObjectAtIndex: indexPath.row];
        if (itemValues) {
            [itemValues setObject:value forKey:jrTextField.attribute];
            [tableLeft reloadTableData];
        }
    }
}

// Table Left   ------------ End ---------------------------------



@end
