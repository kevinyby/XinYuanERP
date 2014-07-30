#import "JsonController.h"
#import "AppInterface.h"

@implementation JsonController
{
    JsonView* jsonView;
}

-(id) initWithOrder: (NSString*)order department:(NSString*)department
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.order = order;
        self.department = department;
        self.controlMode = JsonControllerModeNull;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // assemble jsonview sepecifications and json view
    NSMutableDictionary* viewSpecifications = [JsonControllerHelper assembleJsonViewSpecifications: self.order];
    jsonView = (JsonView*)[JsonViewRenderHelper render: self.order specifications:viewSpecifications];
    [self.view addSubview: jsonView];
    // assemble controller sepecifications
    NSMutableDictionary* controllerSpecifications = [JsonControllerHelper assembleJsonControllerSpecifications: self.order];
    self.specifications = controllerSpecifications;
    
    // after get controll specifications , then set controller event
    [self setupClientEvents];
    [self setupServerEvents];
    
    // For Just Preview The View in LoginViewController Now // clear the border , for debug
    if (self.controlMode != JsonControllerModeNull){
        [ColorHelper clearBorderRecursive: jsonView];
    }
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (self.controlMode == JsonControllerModeCreate) {
        [ScheduledTask.sharedInstance registerSchedule:self timeElapsed:20 repeats:0];
    }
}

#pragma mark - Scheduled Action

-(void) scheduledTask
{
//    NSData* data = [FileManager getDataFromDocument: ];
//    objects = data ? [NSJSONSerialization JSONObjectWithData: data options:NSJSONReadingAllowFragments error:&error] : nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if ([self viewWillAppearShouldRequestServer]) {
        [self requestForModelDataFromServer];
    }
}

-(JsonView *)jsonView
{
    if (! jsonView) {
        [self view];
    }
    return jsonView;
}

-(void)setControlMode:(JsonControllerMode)controlMode
{
    _controlMode = controlMode;
    
    [JsonControllerHelper renderControllerModeWithSpecification: self];
}

-(BOOL) viewWillAppearShouldRequestServer
{
    return self.controlMode == JsonControllerModeRead;
}

#pragma mark - Request Server Methods

-(void) requestForModelDataFromServer
{
    NSDictionary* objects = [RequestModelHelper getModelIdentities: self.identification];
    if (! objects) return;
    
    self.controlMode = JsonControllerModeRead;
    
    [VIEW.progress show];
    RequestJsonModel* requestModel = [self assembleReadRequest: objects];
    [DATA.requester startPostRequestWithAlertTips:requestModel completeHandler:^(HTTPRequester* requester, ResponseJsonModel *data, NSHTTPURLResponse *httpURLReqponse, NSError *error) {
        [VIEW.progress hide];
        [self didReceiveModelDataFromServer: data error:error];
    }];
}
-(void) didReceiveModelDataFromServer: (ResponseJsonModel*)data error:(NSError*)error
{
    if (data.status) {
        // subclass override it , if needed
        NSMutableDictionary* modelToRender = [self assembleReadResponse: data];
        
        // enable events
        [self enableViewsWithReceiveObjects: modelToRender];
        
        // subclass override it , if needed
        [self translateReceiveObjects: modelToRender];
        
        // ok , do the render
        [self renderWithReceiveObjects: modelToRender];
        
        // call back
        [self didRenderWithReceiveObjects: modelToRender];
    }
}

#pragma mark - Initilize Controller Events
#pragma mark - Client End
-(void) setupClientEvents
{
    JsonView* varJsonView = self.jsonView;
    NSDictionary* clientConfig = self.specifications[kController_CLIENT];
    NSDictionary* imagesConfig = self.specifications[kController_IMAGES];

    // Toggle Buttons
    [JRComponentHelper setupToggleButtons: varJsonView components:clientConfig[kController_TOGGLES_BUTTONS]];
    // Date Pickers & Date Patterns
    [JRComponentHelper setupDatePickerComponents: varJsonView pickers:clientConfig[kController_DATEPICKERS] patterns:clientConfig[kController_DATEPATTERNS]];
    // QRCode Components
    [JRComponentHelper setupQRCodeComponents: varJsonView components:clientConfig[kController_QRCODES_BUTTONS]];
    // Signature
    [JRComponentHelper setupSignaturePicker: varJsonView config:clientConfig[kController_SIGNATURESBUTTONS]];
    // Photos Picker
    [JRComponentHelper setupPhotoPickerComponents: varJsonView config:imagesConfig[kController_IMAGE_PICKER]];
    // Photos Previews
    [JRComponentHelper setupPreviewImageComponents: self config:imagesConfig[kController_IMAGES_PREVIEWS]];
    // Popup Tables
    [PopupTableHelper setupPopTableViewsInJsonView: varJsonView config:clientConfig[kController_ValuesPicker]];
    
    
    // setup auto fill components when in create mode
    if (self.controlMode == JsonControllerModeCreate) {
        [JsonControllerHelper setupAutoFillComponents: varJsonView config:clientConfig];
    }
    
    // in viewDidLoad,  render with mode once , Cause in setControlMode: , maybe the jsonView = nil
    [JsonControllerHelper renderControllerModeWithSpecification: self];
}

#pragma mark - Server End
-(void) setupServerEvents
{
    // The Shared Buttons
    __weak JsonController* weakSelf = self;
    
    // The Common Buttons
    JRButton* priorPageBTN = (JRButton*)[self.jsonView getView:json_BTN_PriorPage];
    JRButton* nextPageBTN = (JRButton*)[self.jsonView getView: json_BTN_NextPage];
    
    JsonDivView* headerDiv = (JsonDivView*)[self.jsonView getView: json_NESTED_header];
    JRButton* backBTN = ((JRButton*)[headerDiv getView: json_BTN_Back]);
    JRButton* deleteBTN = ((JRButton*)[headerDiv getView: json_BTN_Delete]);
    JRButton* returnBTN = ((JRButton*)[headerDiv getView: json_BTN_Return]);
    
    priorPageBTN.didClikcButtonAction = ^void(id sender) {
        [JsonControllerHelper flipPage: weakSelf isNextPage:NO];
    };
    nextPageBTN.didClikcButtonAction = ^void(id sender) {
        [JsonControllerHelper flipPage: weakSelf isNextPage:YES];
    };
    
    backBTN.didClikcButtonAction = ^void(id sender) {
        [VIEW.navigator popViewControllerAnimated: YES];
    };
    deleteBTN.didClikcButtonAction = ^void(id sender) {
        
        NSString* orderType = self.order;
        NSString* department = self.department;
        id identification = self.identification;
        NSString* tips = LOCALIZE_KEY(@"order");
        
        [OrderSearchListViewController deleteWithCheckPermission: orderType deparment:department identification:identification tips:tips handler:^(bool isSuccess) {
            if (isSuccess) {
                
                // delete the images
                NSString* imagesFolderProperty = [OrderSearchListViewController getDeleteImageFolderProperty: department order:orderType];
                NSString* imagesFolderName = self.valueObjects[imagesFolderProperty];
                if (! OBJECT_EMPYT(imagesFolderName)) {
                    NSString* fullFolderName = [[JsonControllerHelper getImagesHomeFolder: orderType department:department] stringByAppendingPathComponent: imagesFolderName];
                    [VIEW.progress show];
                    VIEW.progress.detailsLabelText = APPLOCALIZE_KEYS(@"In_Process", @"delete", @"images");
                    [AppServerRequester deleteImagesFolder: fullFolderName completeHandler:^(HTTPRequester *requester, ResponseJsonModel *model, NSHTTPURLResponse *httpURLReqponse, NSError *error) {
                        [VIEW.progress hide];
                    }];
                }
                
                // pop
                UIViewController* controller = [VIEW.navigator.viewControllers objectAtIndex: VIEW.navigator.viewControllers.count - 2];
                if ([controller isKindOfClass:[OrderSearchListViewController class]]) {
                    OrderSearchListViewController* list = (OrderSearchListViewController*)controller;
                    list.isPopNeedRefreshRequest = YES;
                }
                
                [VIEW.navigator popViewControllerAnimated: YES];
            }
        }];
    };
    returnBTN.didClikcButtonAction = ^void(id sender) {
        NSDictionary* identities = [RequestModelHelper getModelIdentities: self.identification];
        if (! identities) return;
        
        [JsonControllerSeverHelper startReturnOrderRequest: self.order department:self.department valueObjects:self.valueObjects identities:identities];
    };
    
    // set up Submit Buttons Event
    [JsonControllerHelper iterateJsonControllerSubmitButtonsConfig: self handler:^BOOL(NSString* buttonKey, JRButton *submitBTN, NSString *departmentType, NSString *orderType, NSString *sendNestedViewKey, NSString *appTo, NSString *appFrom, JsonControllerSubmitButtonType buttonType) {
        
        // For Test
        if (weakSelf.controlMode == JsonControllerModeNull) {
            return YES;
        }
        
        // Disable and Enable Buttons
        [JsonControllerHelper setUserInterfaceEnable:submitBTN enable:NO];
        if (buttonType == JsonControllerSubmitButtonTypeSaveOrUpdate) {
            if (weakSelf.controlMode == JsonControllerModeCreate) {
                [JsonControllerHelper setUserInterfaceEnable:submitBTN enable:YES];
            }
        }
        
        // create / apply / submit ... Buttons registry event
        submitBTN.didClikcButtonAction = ^void(JRButton* button) {
            if (buttonType == JsonControllerSubmitButtonTypeSaveOrUpdate) {
                
                NSMutableDictionary* objects = [weakSelf getCreateObjects: orderType div:sendNestedViewKey];
                if (! objects) return;
                
                // create with apply inform user / forward user
                if (appTo) {
                    [ViewControllerHelper popApprovalView: appTo department:departmentType order:orderType selectAction:nil cancelAction:nil sendAction:^(id sender, NSString *forwardUserNumber) {
                        [objects setObject:forwardUserNumber forKey:PROPERTY_FORWARDUSER];
                        [self startSendCreateUpdateOrderRequest: objects order:orderType department:departmentType];
                    }];
                } else {
                    [self startSendCreateUpdateOrderRequest: objects order:orderType department:departmentType];
                }
                
            } else if (buttonType == JsonControllerSubmitButtonTypeApprove) {
                
                NSDictionary* identities = [RequestModelHelper getModelIdentities: self.identification];
                
                BOOL isNeedRequest = YES;
                NSMutableDictionary* objects = nil;
                [self assembleWillApplyObjects: appFrom order:orderType valueObjects:weakSelf.valueObjects divKey:sendNestedViewKey isNeedRequest:&isNeedRequest objects:&objects identities:&identities];
                if (! isNeedRequest) return;
                if (! identities) return;
                
                if (appTo) {
                    if ([JsonControllerHelper isLastAppLevel: orderType applevel:appFrom]) {
                        NSString* forwardUser = [weakSelf getFowardUserForFinalApplyOrder: orderType valueObjects:weakSelf.valueObjects appTo:appTo];
                        [weakSelf startApplyOrderRequest:orderType divViewKey:sendNestedViewKey appFrom:appFrom appTo:appTo forwarduser:forwardUser objects:objects identities:identities];
                    } else {
                        [ViewControllerHelper popApprovalView: appTo department:weakSelf.department order:weakSelf.order selectAction:nil cancelAction:nil sendAction:^(id sender, NSString *number) {
                            [weakSelf startApplyOrderRequest:orderType divViewKey:sendNestedViewKey appFrom:appFrom appTo:appTo forwarduser:number objects:objects identities:identities];
                        }];
                    }
                } else {
                    [weakSelf startApplyOrderRequest:orderType divViewKey:sendNestedViewKey appFrom:appFrom appTo:appTo forwarduser:nil objects:objects identities:identities];
                }
            }
        };
        return NO;
    }];
}


-(NSMutableDictionary*) getCreateObjects: (NSString*)orderType div:(NSString*)divViewKey
{
    // next three are subclass optional override
    // assemble the create objects
    NSMutableDictionary* objects = [self assembleSendObjects: divViewKey];
    // when validate failed
    if (! [self validateSendObjects: objects order:orderType]) {
        return nil;
    }
    // translate it
    [self translateSendObjects: objects order:orderType];
    
    return objects;
}

#pragma mark - SubClass Optional Override Methods

#pragma mark - Read

-(RequestJsonModel*) assembleReadRequest:(NSDictionary*)objects
{
    RequestJsonModel* requestModel = [RequestJsonModel getJsonModel];
    requestModel.path = PATH_LOGIC_READ(self.department);
    [requestModel addModels: self.order, nil];
    [requestModel addObjects: objects, nil];
    return requestModel;
}

-(NSMutableDictionary*) assembleReadResponse: (ResponseJsonModel*)response
{
    // get the data
    NSDictionary* modelValueObjects = [[response.results firstObject] firstObject];
    
    if (!modelValueObjects) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        // Configure for text only and offset down
        hud.mode = MBProgressHUDModeText;
        hud.labelText = LOCALIZE_MESSAGE(@"OrderDataEmpty");
        float hudViewHeight = [hud sizeHeight];
        hud.yOffset = hudViewHeight / 2 - [FrameTranslater convertCanvasHeight: 45];
        hud.removeFromSuperViewOnHide = YES;
        hud.userInteractionEnabled = NO;
        [hud hide:YES afterDelay:3];
        return nil;
    }
    
    self.valueObjects = [DictionaryHelper deepCopy: modelValueObjects];
    
    // the visible objects
    NSMutableDictionary* modelToRender = [DATA.modelsStructure getModelStructure:self.order];
    [DictionaryHelper combine: modelToRender with:self.valueObjects];
    
    return modelToRender;
}

-(void) enableViewsWithReceiveObjects: (NSMutableDictionary*)objects
{
    // check and disable returned button
    JRButton* returnBTN = ((JRButton*)[self.jsonView getView: JSON_KEYS(json_NESTED_header, json_BTN_Return)]);
    [JsonControllerHelper disableReturnedButton: returnBTN order:self.order withObjects:objects];
    
    // this two go first , will cause render controlle mode
    
    // check if is returned, then enable and disable the Submit Buttons
    if ([objects[PROPERTY_RETURNED] boolValue]) {
        // Enable Submit Buttons By Returned Status
        [JsonControllerHelper enableSubmitButtonsForReturnedStatus: self order:self.order withObjects:objects];
    } else {
        // Enable Submit Buttons By ForwardUser
        [JsonControllerHelper enableSubmitButtonsForApplyMode: self withObjects:objects order:self.order];
    }
    
    // exception and delete button
    [JsonControllerHelper enableExceptionButtonAfterFinalApprovas:self objects:objects];
    [JsonControllerHelper enableDeleteButtonByCheckPermission: self ];
}

-(void) translateReceiveObjects: (NSMutableDictionary*)objects
{
    NSDictionary* clientConfig = self.specifications[kController_CLIENT];
    
    [JRComponentHelper translateNumberToName: objects attributes:@[levelApp1,levelApp2,levelApp3,levelApp4,PROPERTY_CREATEUSER]];
    [JRComponentHelper tranlateDateComponentToVisual: objects patterns:clientConfig[kController_DATEPATTERNS] ];
}

-(void) renderWithReceiveObjects: (NSMutableDictionary*)objects
{
    [self.jsonView clearModel];
    [self.jsonView setModel: objects];
}

-(void) didRenderWithReceiveObjects: (NSMutableDictionary*)objects
{
    [JsonControllerHelper loadImagesToJsonView: self objects:objects];
}

//------------------------------------------------------------------------ Read End



#pragma mark - Create / Update

-(NSMutableDictionary*) assembleSendObjects: (NSString*)divViewKey
{
    NSMutableDictionary* objects = nil;
    UIView* contentView = nil;
    if (divViewKey) {
        contentView = [self.jsonView getView: divViewKey];
    } else {
        contentView = self.jsonView.contentView;
    }
    objects = [JsonModelHelper getModel: contentView];
    
    // exception
    [objects setObject:[(JRCheckBox*)[self.jsonView getView: JSON_KEYS(json_NESTED_header, json_BTN_Exception)] getValue] forKey:PROPERTY_EXCEPTION];
    
    return [DictionaryHelper filter: objects withObject:EMPTY_STRING];       // just in create mode, if not, Gson cause empty exceptioin.
}

-(BOOL) validateSendObjects: (NSMutableDictionary*)objects order:(NSString*)order
{
    // For Debug , not check it, remove it production
    if ([VIEW isTestDevice]) return YES;
    
    NSDictionary* serverConfig = self.specifications[kController_SERVER];
    NSString* message = nil;
    
    // validate the not empty objects
    NSArray* cannotEmptyAttributes = serverConfig[json_CHECK_NOTEMPTY];
    [JsonControllerHelper validateNotEmptyObjects: cannotEmptyAttributes jsonView:self.jsonView message:&message];
    if (message) {
        [ACTION alertMessage: message];
        return NO;
    }
    
    // validate the right format objects
    NSDictionary* formatAttributes = serverConfig[json_CHECK_FORMAT];
    [JsonControllerHelper validateFormatObjects: formatAttributes jsonView:self.jsonView message:&message];
    if (message) {
        [ACTION alertMessage: message];
        return NO;
    }
    
    return YES;
}

-(void) translateSendObjects: (NSMutableDictionary*)objects order:(NSString*)order
{
    NSDictionary* clientConfig = self.specifications[kController_CLIENT];
    [JRComponentHelper tranlateDateComponentToSend: self.jsonView patterns:clientConfig[kController_DATEPATTERNS] objects:objects];
}


-(RequestJsonModel*) assembleSendRequest: (NSMutableDictionary*)withoutImagesObjects order:(NSString*)order department:(NSString*)department
{
    RequestJsonModel* requestModel = [RequestJsonModel getJsonModel];
    requestModel.path = PATH_LOGIC_CREATE(department);
    [requestModel addModels: order, nil];
    [requestModel addObject: withoutImagesObjects ];
    return requestModel;
}

-(void) didSuccessSendObjects: (NSMutableDictionary*)objects response:(ResponseJsonModel*)response
{
    NSString* orderNO = objects[PROPERTY_ORDERNO];
    NSString* forwardUser = objects[PROPERTY_FORWARDUSER];
    
    // Have Images
    BOOL isHaveImages = [self.specifications[kController_IMAGES][kController_IMAGES_DATAS] count] > 0;
    NSMutableDictionary* imagesObjects = [DictionaryHelper subtract: objects withType:[UIImage class]];
    if (isHaveImages && imagesObjects.count != 0) {
        NSString* orderNO = objects[PROPERTY_ORDERNO];
        if (!orderNO) {
            orderNO = [((id<JRComponentProtocal>)[self.jsonView getView:PROPERTY_ORDERNO]) getValue];
            if (! orderNO) {
                orderNO = self.valueObjects[PROPERTY_ORDERNO];
            }
            if (! orderNO) {
                orderNO = self.valueObjects[PROPERTY_IDENTIFIER];
            }
        }
        NSString* forwardUser = objects[PROPERTY_FORWARDUSER];
        [self startSendCreateImagesRequest: imagesObjects orderNO:orderNO forwardUser:forwardUser];
        
    // Have No Images
    } else {
        [self startCreateUpdateInformRequest: orderNO forwardUser:forwardUser];
    }
}

-(void) didFailedSendObjects: (NSMutableDictionary*)objects response:(ResponseJsonModel*)response
{
    [VIEW.progress hide];
    NSArray* resetAttributes = self.specifications[kController_SERVER][kController_SUBMIT_CREATE_FAILED_RESET];
    for (NSString* attributes in resetAttributes) [(((id<JRComponentProtocal>)[self.jsonView getView:attributes])) setValue: nil];
}

//------------------------------------------------------------------------ Send / Create End



#pragma mark - Apply

-(NSString*) getFowardUserForFinalApplyOrder: (NSString*)orderType valueObjects:(NSDictionary*)valueObjects appTo:(NSString*)appTo
{
    return valueObjects[appTo];
}

-(void) assembleWillApplyObjects: (NSString*)applevel order:(NSString*)order valueObjects:(NSDictionary*)valueObjects divKey:(NSString*)divKey isNeedRequest:(BOOL*)isNeedRequest objects:(NSDictionary**)objects identities:(NSDictionary**)identities
{
    NSMutableDictionary* currentViewObjects = [self getCreateObjects: order div:divKey];
    if (! currentViewObjects) {
        *isNeedRequest = NO;
        return;
    };
    
    NSMutableDictionary* differObjectsWithoutImages = [JsonControllerHelper differObjects:valueObjects objects:currentViewObjects];
    
    // returned value
    if ([valueObjects[PROPERTY_RETURNED] boolValue]) {
        [differObjectsWithoutImages setObject:[NSNumber numberWithBool: NO] forKey:PROPERTY_RETURNED];
    }
    *objects = differObjectsWithoutImages;
}

-(void) didSuccessApplyOrder: (NSString*)orderType appFrom:(NSString*)appFrom appTo:(NSString*)appTo divViewKey:(NSString*)divViewKey forwarduser:(NSString*)forwardUser
{
    [ApproveHelper refreshBadgeIconNumber: DATA.signedUserName];
    [self.valueObjects setObject: DATA.signedUserName forKey:appFrom];
    [self startApplyInformRequest: orderType appFrom:appFrom appTo:appTo orderNO:self.identification forwardUser:forwardUser];
}

-(void) didFailedApplyOrder: (NSString*)orderType appFrom:(NSString*)appFrom appTo:(NSString*)appTo divViewKey:(NSString*)divViewKey
{
    VIEW.progress.labelText = [NSString stringWithFormat:@"%@%@", LOCALIZE_KEY(appFrom), LOCALIZE_KEY(@"failed")];
    [VIEW.progress setupCompletedView: NO];
    [VIEW.progress hideAfterDelay: 2];
}

//------------------------------------------------------------------------ Apply End


#pragma mark - Private Methods
-(void) startSendCreateUpdateOrderRequest: (NSMutableDictionary*)objects order:(NSString*)order department:(NSString*)department
{
    NSMutableDictionary* withoutImagesObjects = [DictionaryHelper filter:objects withType:[UIImage class]];
    
    if (self.controlMode == JsonControllerModeCreate) {
        // get the models that filtered the images
        [VIEW.progress show];
        RequestJsonModel* requestModel = [self assembleSendRequest: withoutImagesObjects order:order department:department];
        [DATA.requester startPostRequestWithAlertTips:requestModel completeHandler:^(HTTPRequester *requester, ResponseJsonModel *response, NSHTTPURLResponse *httpURLReqponse, NSError *error) {
            if (response.status) {
                // create order success
                NSString* orderNO = [[response.results firstObject] objectForKey:PROPERTY_ORDERNO];
                if (orderNO) {
                    [objects setObject: orderNO forKey:PROPERTY_ORDERNO];
                    [(id<JRComponentProtocal>)[self.jsonView getView: PROPERTY_ORDERNO] setValue: orderNO];
                }
                self.valueObjects = objects;
                
                [self didSuccessSendObjects: objects response: response];
            } else {
                // create order failed
                [self didFailedSendObjects: objects response: response];
            }
        }];
        
    } else if (self.controlMode == JsonControllerModeModify) {
        
        NSDictionary* identities = [RequestModelHelper getModelIdentities: self.identification];
        if (! identities) return;
        
        NSString* forwardUser = withoutImagesObjects[PROPERTY_FORWARDUSER];
        
        NSMutableDictionary* differWithoutImagesObjects = [JsonControllerHelper differObjects:self.valueObjects objects:withoutImagesObjects];
        
        if ([self.valueObjects[PROPERTY_RETURNED] boolValue]) {
            [differWithoutImagesObjects setObject:[NSNumber numberWithBool: NO] forKey:PROPERTY_RETURNED];
            [differWithoutImagesObjects setObject: forwardUser forKey:PROPERTY_FORWARDUSER];
        }
        
        [AppServerRequester modifyModel: order department:department objects:differWithoutImagesObjects identities:identities completeHandler:^(ResponseJsonModel *response, NSError *error) {
            if (response.status) {
                [DictionaryHelper combine:self.valueObjects with:objects];
                [self didSuccessSendObjects: self.valueObjects response: response];
            } else {
                [self didFailedSendObjects: differWithoutImagesObjects response: response];
            }
        }];
    }
}

-(void) startSendCreateImagesRequest: (NSDictionary*)imagesObjects orderNO:(NSString*)orderNO forwardUser:(NSString*)forwardUser
{
    // get image data and names
    NSMutableArray* jrImageViewAttributes = [NSMutableArray array];
    NSMutableArray* uploadUIImges = [NSMutableArray array];
    NSDictionary* imageDatasConfig = self.specifications[kController_IMAGES][kController_IMAGES_DATAS];
    [JsonControllerHelper feedUploadAttributes: jrImageViewAttributes uploadUIImges:uploadUIImges imagesObjects:imagesObjects imageDatasConfig:imageDatasConfig];
    
    NSMutableArray* imagesDatas = [NSMutableArray array];
    NSMutableArray* imagesPaths = [NSMutableArray array];
    NSMutableArray* imagesThumbnailsDatas = [NSMutableArray array];
    NSMutableArray* imagesThumbnailsPaths = [NSMutableArray array];
    [JsonControllerHelper getImagesDatasAndPaths:self datas:imagesDatas thumbnailDatas:imagesThumbnailsDatas paths:imagesPaths thumbnailPaths:imagesThumbnailsPaths attributes:jrImageViewAttributes uiImages:uploadUIImges];
//    [imagesDatas addObjectsFromArray: imagesThumbnailsDatas];
//    [imagesPaths addObjectsFromArray: imagesThumbnailsPaths];
    DLOG(@"Assemble images paths: %@", imagesPaths);
    
    if (imagesPaths.count == 0) {
        DLog(@"Image Paths Count = 0");
    }
    
    if (imagesPaths.count != imagesDatas.count) {
        DLog(@"Upload Images Count ---- Have Error , check it out !!!");
    }
    
    // send the request
    __block int uploadCount = 1;
    __block NSError* errorOccur = nil;
    if (!VIEW.isProgressShowing) [VIEW.progress show];     // may be reSend the request
    VIEW.progress.detailsLabelText = LOCALIZE_MESSAGE_FORMAT(@"UploadingImages", uploadCount);
    [AppServerRequester saveImages: imagesDatas paths:imagesPaths completeHandler:^(id identification, ResponseJsonModel *data, NSError *error, BOOL isFinish) {
        uploadCount++;
        int index = ceil( uploadCount / 2);
        if (error) {
            errorOccur = error;
            VIEW.progress.detailsLabelText = LOCALIZE_MESSAGE_FORMAT(@"UploadingImagesFailed", index);
        } else {
            VIEW.progress.detailsLabelText = LOCALIZE_MESSAGE_FORMAT(@"UploadingImages", index);
        }
        if (! isFinish) return ;
        
        
        // When finish uploading images
        
        // Have Error
        if (errorOccur) {
            NSString* message = [NSString stringWithFormat:@"%@%@%@", LOCALIZE_KEY(@"IMAGE"), LOCALIZE_KEY(@"UPLOAD"), LOCALIZE_KEY(@"failed")];
            [VIEW.progress hide];
            message = [message stringByAppendingFormat:@",%@", LOCALIZE_MESSAGE_FORMAT(@"REDO_YESORNO", LOCALIZE_KEY(@"UPLOAD"), LOCALIZE_KEY(@"IMAGE"))];
            [PopupViewHelper popAlert:LOCALIZE_KEY(@"FAILED") message:message style:0 actionBlock:^(UIView *popView, NSInteger index) {
                NSString* buttonTitle = [(UIAlertView*)popView buttonTitleAtIndex: index];
                if ([buttonTitle isEqualToString: LOCALIZE_KEY(@"YES")]) {
                    [self startSendCreateImagesRequest: imagesObjects orderNO:orderNO forwardUser:forwardUser];
                } else {
                    
                    //
                    [self startCreateUpdateInformRequest: orderNO forwardUser:forwardUser];
                }
            } dismissBlock:nil buttons:LOCALIZE_KEY(@"NO"), LOCALIZE_KEY(@"YES"), nil];
        
        // Have No Error
        } else {
            
            //
            [self startCreateUpdateInformRequest: orderNO forwardUser:forwardUser];
        }

    }];
}

-(void) startApplyOrderRequest: (NSString*)orderType divViewKey:(NSString*)divViewKey appFrom:(NSString*)appFrom appTo:(NSString*)appTo forwarduser:(NSString*)forwardUser objects:(NSDictionary*)objects identities:(NSDictionary*)identities
{
    [VIEW.progress show];
    VIEW.progress.detailsLabelText = LOCALIZE_MESSAGE(@"ApplyingNow");
    [AppServerRequester apply: orderType department:self.department identities:identities objects:objects applevel:appFrom forwarduser:forwardUser completeHandler:^(ResponseJsonModel *response, NSError *error) {
        BOOL isSuccessfully = response.status;
        if (isSuccessfully) {
            [self didSuccessApplyOrder: orderType appFrom:appFrom appTo:appTo divViewKey:divViewKey forwarduser:forwardUser];
        } else {
            [self didFailedApplyOrder: orderType appFrom:appFrom appTo:appTo divViewKey:divViewKey];
        }
    }];
}


// inform ----------------

-(void) startCreateUpdateInformRequest:(NSString*)orderNO forwardUser:(NSString*)forwardUser
{
    NSString* nextLevel = [JsonControllerHelper getNextAppLevel: PROPERTY_CREATEUSER];
    NSString* apnsMessage = LOCALIZE_MESSAGE_FORMAT(@"YouHaveNewOrderToApply", forwardUser, LOCALIZE_KEY(self.order), LOCALIZE_KEY(nextLevel));
    
    NSString* actionKey = nil ;
    if (self.controlMode == JsonControllerModeCreate) {
        actionKey = PERMISSION_CREATE;
    } else {
        actionKey = @"modify";
    }
    
    NSDictionary* identities = [RequestModelHelper getModelIdentities: orderNO];
    [JsonControllerSeverHelper startInformRequest: actionKey orderType:self.order department:self.department identities:identities forwardUser:forwardUser apnsMessage:apnsMessage];
}
-(void) startApplyInformRequest: (NSString*)orderType appFrom:(NSString*)appFrom appTo:(NSString*)appTo orderNO:(NSString*)orderNO forwardUser:(NSString*)forwardUser
{
    NSString* apnsMessage = LOCALIZE_MESSAGE_FORMAT(@"YouHaveNewOrderToApply", forwardUser, LOCALIZE_KEY(orderType), LOCALIZE_KEY(appTo));

    if ([JsonControllerHelper isLastAppLevel: orderType applevel:appFrom]) {
        if ([appTo isEqualToString: PROPERTY_CREATEUSER]) {
            appTo = PERMISSION_CREATE;
        }
        apnsMessage = LOCALIZE_MESSAGE_FORMAT(@"YourOrderHaveBeenApplied", forwardUser, LOCALIZE_KEY(appTo), LOCALIZE_KEY(orderType), LOCALIZE_KEY(appFrom));
    }
    
    NSDictionary* identities = [RequestModelHelper getModelIdentities: orderNO];
    [JsonControllerSeverHelper startInformRequest:appFrom orderType:orderType department:self.department identities:identities forwardUser:forwardUser apnsMessage:apnsMessage];
}




@end