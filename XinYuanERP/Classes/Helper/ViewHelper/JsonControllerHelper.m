#import "JsonControllerHelper.h"
#import "AppInterface.h"

@implementation JsonControllerHelper


#pragma mark - 

+(NSMutableDictionary*) assembleJsonViewSpecifications: (NSString*)order
{
    NSMutableDictionary* viewSpecifications = [DictionaryHelper deepCopy: [JsonFileManager getJsonFromFile: order]];
    NSMutableDictionary* shareViewSpecifications = [DictionaryHelper deepCopy: [JsonFileManager getJsonFromFile: json_SHARE_FILE]];
    // take share.json as base , combine all the values
    [DictionaryHelper combine: shareViewSpecifications with:viewSpecifications];
    [DictionaryHelper replaceKeys: [shareViewSpecifications objectForKey: JSON_COMPONENTS] keys:@[json_OrderTitle] withKeys:@[order]];
    return shareViewSpecifications;
}

+(NSMutableDictionary*) assembleJsonControllerSpecifications: (NSString*)order
{
    NSString* controllerSuffix = json_FILE_CONTROLLER_SUFIX;
    NSString* controllerFileName = [order stringByAppendingString:controllerSuffix];
    NSMutableDictionary* controllerSpecifications = [DictionaryHelper deepCopy: [JsonFileManager getJsonFromFile: controllerFileName]];
    NSString* shareControllerFilaName = [json_SHARE_FILE stringByAppendingString:controllerSuffix];
    NSMutableDictionary* shareControllerSpecifications = [DictionaryHelper deepCopy: [JsonFileManager getJsonFromFile: shareControllerFilaName]];
    [DictionaryHelper combine: shareControllerSpecifications with:controllerSpecifications];
    return shareControllerSpecifications;
}


#pragma mark - Validate Objects
+(void) validateNotEmptyObjects: (NSArray*)attributes jsonView:(JsonView*)jsonView message:(NSString**)message
{
    for (NSString* attribute in attributes) {
        id value = [(id<JRComponentProtocal>)[jsonView getView: attribute] getValue];
        if (OBJECT_EMPYT(value)) {
            NSString* key = [[attribute componentsSeparatedByString: DOT] lastObject];
            
            BOOL isImage = NO;
            if ([key hasPrefix:JSON_IMG_PRE]){
                key = [key substringFromIndex:4];
                isImage = YES;
            }
            
            NSString* localizeTip = LOCALIZE_KEY(LOCALIZE_CONNECT_KEYS(jsonView.attribute, key));
            if (isImage) localizeTip = [localizeTip stringByAppendingString:LOCALIZE_KEY(@"IMAGE")];
            
            NSString* localizeValue = LOCALIZE_MESSAGE_FORMAT(MESSAGE_ValueCannotEmpty, localizeTip);
            *message = localizeValue;
            break;
        }
    }
}
+(void) validateFormatObjects: (NSDictionary*)attributes jsonView:(JsonView*)jsonView message:(NSString**)message
{
    for (NSString* attribute in attributes) {
        NSString* format = attributes[attribute];
        id value = [(id<JRComponentProtocal>)[jsonView getView: attribute] getValue];
        
        BOOL isRightFormat = NO;
        if ([format isEqualToString: json_CHECK_FORMAT_DIGIT]) {
            if ([value isKindOfClass: [NSNumber class]]) {
                isRightFormat = YES;
            }
        }
        if (! isRightFormat) {
            NSString* localizeFormat = LOCALIZE_KEY(format);
            NSString* key = [[attribute componentsSeparatedByString: DOT] lastObject];
            NSString* localizeTip = LOCALIZE_KEY(LOCALIZE_CONNECT_KEYS(jsonView.attribute, key));
            NSString* localizeValue = LOCALIZE_MESSAGE_FORMAT(MESSAGE_ValueNotMatchFormat, localizeTip, localizeFormat);
            *message = localizeValue;
            break;
        }
    }
}

// attribute are two dimension
+(void) validateShouldEqualsObjects: (NSArray*)attributes jsonView:(JsonView*)jsonView message:(NSString**)message
{
    for (int i = 0; i < attributes.count; i++) {
        NSArray* group = attributes[i];
        
        id compareValue = nil;
        NSString* compareAttribute = nil;
        
        for (NSString* attribute in group) {
            id value = [(id<JRComponentProtocal>)[jsonView getView: attribute] getValue];
            if (!compareValue) {
                compareValue = value;
                compareAttribute = attribute;
            } else {
                if (![compareValue isEqual: value]) {
                    NSString* localizeTip1 = LOCALIZE_KEY(LOCALIZE_CONNECT_KEYS(jsonView.attribute, attribute));
                    NSString* localizeTip2 = LOCALIZE_KEY(LOCALIZE_CONNECT_KEYS(jsonView.attribute, compareAttribute));
                    *message = LOCALIZE_MESSAGE_FORMAT(MESSAGE_ValueNotTheSame, localizeTip1,localizeTip2);
                    return;
                }
            }
        }
    }

}



#pragma mark - Auto Fill TextField In Create Mode
+(void) setupAutoFillComponents: (JsonView*)jsonView config:(NSDictionary*)clientConfig
{
    // COMS_DATE_PATTERNS
    NSDictionary* dataPatternsConfig = clientConfig[kController_DATEPATTERNS];
    // CREATE_AUTOFILL
    NSDictionary* autoFillConfig = clientConfig[kController_CREATE_AUTOFILL];
    // Fill Signin User
    NSArray* fillUserKeyPath = autoFillConfig[kController_CREATE_AUTOFILL_NOWUSER];
    for (NSString* keyPath in fillUserKeyPath) {
        id<JRComponentProtocal> jrview = (id<JRComponentProtocal>)[jsonView getView: keyPath];
        [jrview setValue: DATA.usersNONames[DATA.signedUserName]];
    }
    // Fill Current Date
    NSArray* fillDatesKeyPath = autoFillConfig[kController_CREATE_AUTOFILL_NOWDATE];
    for (NSString* keyPath in fillDatesKeyPath) {
        id<JRComponentProtocal> jrview = (id<JRComponentProtocal>)[jsonView getView: keyPath];
        NSString* pattern = dataPatternsConfig[keyPath] ? dataPatternsConfig[keyPath] : DATE_PATTERN;
        NSString* nowDateStr = [DateHelper stringFromDate: [NSDate date] pattern:pattern];
        [jrview setValue: nowDateStr];
    }
}


#pragma mark - Flip Page
+(void) flipPage: (JsonController*)jsonController isNextPage:(BOOL)isNexPage
{
    if (VIEW.navigator.viewControllers.count < 2) return;
    OrderSearchListViewController* listController = [VIEW.navigator.viewControllers objectAtIndex:VIEW.navigator.viewControllers.count - 2];
    if (! [listController isKindOfClass:[OrderSearchListViewController class]]) return;
    
    if (isNexPage) {
        [listController getNextRow: 0 handler:^(id identification) {
            if (identification) {
                [JsonControllerHelper flipPageAnimation: jsonController.jsonView isNext:isNexPage];
                jsonController.identification = identification;
                [jsonController performSelector: @selector(requestForModelDataFromServer)];
            } else {
                [ACTION alertMessage: LOCALIZE_MESSAGE(MESSAGE_TheLastPage)];
            }
        }];
    } else {
        [listController getPreviousRow: 0 handler:^(id identification) {
            if(identification) {
                [JsonControllerHelper flipPageAnimation: jsonController.jsonView isNext:isNexPage];
                jsonController.identification = identification;
                [jsonController performSelector: @selector(requestForModelDataFromServer)];
            } else {
                [ACTION alertMessage: LOCALIZE_MESSAGE(MESSAGE_TheFirstPage)];
            }
        }];
    }
}
+(void) flipPageAnimation: (UIView*)view isNext:(BOOL)isNext
{
    UIViewAnimationTransition transitionType = isNext ? UIViewAnimationTransitionCurlUp : UIViewAnimationTransitionCurlDown;
    [KATransition runTransition: transitionType forView:view];
}



#pragma mark - Render Mode
+(void) enableDeleteButtonByCheckPermission:(JsonController*)jsonController
{
    BOOL isHavePermission = [PermissionChecker checkSignedUser: jsonController.department order:jsonController.order permission:PERMISSION_DELETE];
    if (isHavePermission) {
        [JsonControllerHelper setUserInterfaceEnable: jsonController.jsonView keys:@[JSON_KEYS(json_NESTED_header, json_BTN_Delete)] enable:YES];
    }
}
+(void) enableExceptionButtonAfterFinalApprovas:(JsonController*)jsonController objects:(NSDictionary*)objects
{
    JRCheckBox* exceptionBTM = ((JRCheckBox*)[jsonController.jsonView getView: JSON_KEYS(json_NESTED_header, json_BTN_Exception)]);
    NSArray* approvalsKeys = [DATA.modelsStructure getModelApprovals: jsonController.order];
    
    BOOL isUserInApprovals = [DATA.signedUserName isEqualToString: objects[PROPERTY_CREATEUSER]];
    BOOL isAllApproved = YES;
    for (NSString* applevel in approvalsKeys) {
        BOOL isApproved = !OBJECT_EMPYT(objects[applevel]);
        
        if (isApproved) {
            if (!isUserInApprovals && [DATA.signedUserName isEqualToString: objects[applevel]]) {
                isUserInApprovals = YES;
            }
        }
        
        isAllApproved = isAllApproved && isApproved;
    }
    if (isAllApproved && isUserInApprovals) {
        [JsonControllerHelper setUserInterfaceEnable: jsonController.jsonView keys:@[JSON_KEYS(json_NESTED_header, json_BTN_Exception)] enable:YES];
        
        jsonController.viewDidDisappearBlock = ^void(BaseController* controller, BOOL animated){
            
            BOOL exception = [objects[PROPERTY_EXCEPTION] boolValue];
            BOOL exceptionBtnValue = [[exceptionBTM getValue] boolValue];
            if (exception != exceptionBtnValue) {
                JsonController* weakjsoncontroller = (JsonController*)controller;
                NSDictionary* idetities = [RequestModelHelper getModelIdentities: weakjsoncontroller.identification];
                NSString* orderType = weakjsoncontroller.order;
                NSString* department = weakjsoncontroller.department;
                [AppServerRequester modifyModel: orderType department:department objects:@{PROPERTY_EXCEPTION:@(exceptionBtnValue)} identities:idetities completeHandler:^(ResponseJsonModel *response, NSError *error) {
                    // ......
                }];
            }
        };
        
    }
}

+(NSString*) getCurrentApprovingLevel:(NSString*)orderType valueObjects:(NSDictionary*)valueObjects
{
    NSArray* levels = [DATA.modelsStructure getModelApprovals: orderType];
    
    for (int i = 0; i < levels.count; i++) {
        NSString* currentLevel = levels[i];
        if (OBJECT_EMPYT(valueObjects[currentLevel])) {
            return currentLevel;
        }
    }
    return nil;     // that means all approved
}

+(NSString*) getCurrentHasApprovedLevel:(NSString*)orderType valueObjects:(NSDictionary*)valueObjects
{
    NSString* approvingLevel = [self getCurrentApprovingLevel: orderType valueObjects:valueObjects];
    if (approvingLevel) {
        NSString* currentHasApprovedLevel = [self getPreviousAppLevel: approvingLevel];
        return currentHasApprovedLevel;
    }
    return nil;
}


+(BOOL) isLastAppLevel: (NSString*)orderType applevel:(NSString*)applevel
{
    NSString* lastLevel = [JsonControllerHelper getLastAppLevel: orderType];
    return [applevel isEqualToString: lastLevel];
}

+(NSString*) getLastAppLevel:(NSString*)order
{
    NSString* lastLevel = [[DATA.modelsStructure getModelApprovals: order] lastObject];
    return lastLevel;
}

+(NSString*) getNextAppLevel:(NSString*)applevel
{
    if ([applevel isEqualToString:PROPERTY_CREATEUSER]) {
        return levelApp1;
    } else if ([applevel isEqualToString:levelApp1]) {
        return levelApp2;
    } else if ([applevel isEqualToString:levelApp2]) {
        return levelApp3;
    } else if ([applevel isEqualToString:levelApp3]) {
        return levelApp4;
    }
    return nil;
}
+(NSString*) getPreviousAppLevel:(NSString*)applevel
{
    if ([applevel isEqualToString:levelApp1]) {
        return PROPERTY_CREATEUSER;
    } else if ([applevel isEqualToString:levelApp2]) {
        return levelApp1;
    } else if ([applevel isEqualToString:levelApp3]) {
        return levelApp2;
    } else if ([applevel isEqualToString:levelApp4]) {
        return levelApp3;
    }
    return nil;
}

+(BOOL) isAllApplied: (NSString*)orderType valueObjects:(NSDictionary*)valueObjects
{
    NSArray* approvals = [DATA.modelsStructure getModelApprovals: orderType];
    BOOL isAllApplied = YES;
    for (int i = 0 ; i < approvals.count; i++) {
        NSString* applevel = approvals[i];
        isAllApplied = isAllApplied && !OBJECT_EMPYT(valueObjects[applevel]);
    }
    return isAllApplied;
}





+(void) disableReturnedButton:(JRButton*)returnButton order:(NSString*)order withObjects:(NSDictionary*)objects
{
    NSString* lastHasApproval = [JsonControllerHelper getCurrentHasApprovedLevel: order valueObjects:objects];
    BOOL isAllApproved = [JsonControllerHelper isAllApplied: order valueObjects:objects];
    if ([lastHasApproval isEqualToString:PROPERTY_CREATEUSER] || isAllApproved) {
        [JsonControllerHelper setUserInterfaceEnable: returnButton enable:NO];
    }
}

+(void) enableSubmitButtonsForReturnedStatus:(JsonController *)jsoncontroller order:(NSString*)order withObjects:(NSDictionary*)objects
{
    jsoncontroller.controlMode = JsonControllerModeModify;
    // then enable the Submit Buttons
    NSString* lastHasApproval = [JsonControllerHelper getCurrentHasApprovedLevel: order valueObjects:objects];
    if ([DATA.signedUserName isEqualToString: objects[lastHasApproval]]) {
        
        // Enable and Disable the Submit Buttons For Returned Status
        [JsonControllerHelper enableSubmitButtonsForReturnedStatus: jsoncontroller lastHasApprovalLevel:lastHasApproval];
        
    }
}

+(void) enableSubmitButtonsForReturnedStatus:(JsonController *)jsoncontroller lastHasApprovalLevel:(NSString*)lastHasApprovalLevel
{
    // Enable and Disable the Submit Buttons For Returned Status
    [JsonControllerHelper iterateJsonControllerSubmitButtonsConfig: jsoncontroller  handler:^BOOL(NSString* buttonKey, JRButton *submitBTN, NSString *departmentType, NSString *orderType, NSString *sendNestedViewKey, NSString *appTo, NSString *appFrom, JsonControllerSubmitButtonType buttonType) {
        
        if ([lastHasApprovalLevel isEqualToString: PROPERTY_CREATEUSER]) {
            if (buttonType == JsonControllerSubmitButtonTypeSaveOrUpdate) {
                [submitBTN setTitleColor: [UIColor redColor] forState:UIControlStateNormal];
                [JsonControllerHelper setUserInterfaceEnable: submitBTN enable:YES];
                return YES;
            }
        } else {
            if ([buttonKey rangeOfString: lastHasApprovalLevel].location != NSNotFound) {
                [submitBTN setTitleColor: [UIColor redColor] forState:UIControlStateNormal];
                [JsonControllerHelper setUserInterfaceEnable: submitBTN enable:YES];
                return YES;
            }
            
        }
        
        return NO;
    }];
}

+(void) enableSubmitButtonsForApplyMode: (JsonController*)jsoncontroller withObjects:(NSDictionary*)objects order:(NSString*)order
{
    [JsonControllerHelper iterateJsonControllerSubmitButtonsConfig: jsoncontroller handler:^BOOL(NSString* buttonKey, JRButton *submitBTN, NSString *departmentType, NSString *orderType, NSString *sendNestedViewKey, NSString *appTo, NSString *appFrom, JsonControllerSubmitButtonType buttonType) {
        
        [JsonControllerHelper setUserInterfaceEnable: submitBTN enable:NO];
        
        if (![order isEqualToString: orderType]) {
            return NO;
        }
        
        if (buttonType != JsonControllerSubmitButtonTypeApprove) {
            return NO;;
        }
        
        if (![DATA.signedUserName isEqualToString: objects[PROPERTY_FORWARDUSER]]) {
            return NO;;
        }
        
        NSString* applevel = appFrom;
        NSString* previousLevel = [JsonControllerHelper getPreviousAppLevel: applevel];
        
        if (!OBJECT_EMPYT(objects[applevel])) {
            return NO;;
        }
        
        if (! previousLevel) {
            return NO;;
        }
        
        if (OBJECT_EMPYT(objects[previousLevel])) {
            return NO;;
        }
        
        if (jsoncontroller.controlMode != JsonControllerModeApply) {
            jsoncontroller.controlMode = JsonControllerModeApply;
            [JsonControllerHelper setUserInterfaceEnable: submitBTN enable:YES];
        }
        
        return NO;
    }];
}

+(void) iterateJsonControllerSubmitButtonsConfig: (JsonController*)jsoncontroller handler:(BOOL(^)(NSString* buttonKey, JRButton* submitBTN, NSString* departmentType, NSString* orderType, NSString* sendNestedViewKey,NSString* appTo,NSString* appFrom, JsonControllerSubmitButtonType buttonType))handler
{
    NSString* order = jsoncontroller.order;
    NSString* department = jsoncontroller.department;
    NSArray* submitBTNConfigs = jsoncontroller.specifications[kController_SERVER][kController_SUBMIT_BUTTONGROUP];
    JsonView* jsonView = jsoncontroller.jsonView;
    
    for (int i = 0; i < submitBTNConfigs.count; i++) {
        NSDictionary* oneGroupButtonsConfig = submitBTNConfigs[i];
        NSString* sendNestedViewKey = oneGroupButtonsConfig[kController_SUBMIT_BUTTONS_SENDVIEW];
        NSString* orderType = oneGroupButtonsConfig[kController_SUBMIT_BUTTONS_SENDORDER];
        orderType = orderType ? orderType : order;
        NSString* departmentType = department;
        
        for (NSString* buttonKey in oneGroupButtonsConfig) {
            if ([buttonKey isEqualToString:kController_SUBMIT_BUTTONS_SENDVIEW] || [buttonKey isEqualToString:kController_SUBMIT_BUTTONS_SENDORDER]) continue;  // not button
            
            NSDictionary* buttonConfig = oneGroupButtonsConfig[buttonKey];
            if (! buttonConfig || ! [buttonConfig isKindOfClass:[NSDictionary class]]) continue;
            NSString* appTo = buttonConfig[kController_SUBMIT_BUTTONS_APPTO];
            NSString* appFrom = buttonConfig[kController_SUBMIT_BUTTONS_APPFROM];
            JsonControllerSubmitButtonType buttonType = [buttonConfig[kController_SUBMIT_BUTTONS_TYPE] intValue]; // default JsonControllerSubmitButtonTypeSaveOrUpdate
            
            // get JRButton
            JRButton* submitBTN = [JRComponentHelper getJRButton: [jsonView getView: buttonKey]];
            if (! submitBTN) continue;
            
            if (handler) {
                if(handler(buttonKey, submitBTN, departmentType, orderType, sendNestedViewKey, appTo, appFrom, buttonType)) return;
            }
        }
    }
}

+(void) renderControllerModeWithSpecification: (JsonController*)jsonController
{
    if (jsonController.controlMode == JsonControllerModeNull) return;
    
    JsonView* jsonview = jsonController.jsonView;
    if (! jsonview)  return;

    JsonControllerMode controllerMode = jsonController.controlMode;
    NSDictionary* clientConfig = jsonController.specifications[kController_CLIENT];
    
    // render controll mode by config
    [JsonControllerHelper renderControlWithMode: controllerMode jsonTopView:jsonview config:clientConfig[kController_CONTROL_MODE]];
}

+(void) renderControlWithMode: (JsonControllerMode)mode jsonTopView:(id<JRTopViewProtocal>)jsonTopView config:(NSDictionary*)config
{
    [self switchControl: jsonTopView mode:json_DEFAULT_MODE config:config];
    
    if (mode == JsonControllerModeCreate) {
        [self switchControl: jsonTopView mode:json_CREAT_MODE config:config];
    } else if (mode == JsonControllerModeRead) {
        [self switchControl: jsonTopView mode:json_READ_MODE config:config];
    } else if (mode == JsonControllerModeApply) {
        [self switchControl: jsonTopView mode:json_APPLY_MODE config:config];
    } else if (mode == JsonControllerModeModify) {
        [self switchControl: jsonTopView mode:json_MODIFY_MODE config:config];
    }
}
+(void) switchControl: (id<JRTopViewProtocal>)jsonTopView mode:(NSString*)mode config:(NSDictionary*)config
{
    // share.json
    NSDictionary* shareModeConfig = [config objectForKey: mode];
    [self setUserInterfaceEnable: jsonTopView keys:shareModeConfig[json_ENABLE] enable:YES];
    [self setUserInterfaceEnable: jsonTopView keys:shareModeConfig[json_UNENABLE] enable:NO];
    
    // subclass.json
    NSDictionary* subModeConfig = [config objectForKey: [mode stringByAppendingString: json_MODE_SUB]];
    [self setUserInterfaceEnable: jsonTopView keys:subModeConfig[json_ENABLE] enable:YES];
    [self setUserInterfaceEnable: jsonTopView keys:subModeConfig[json_UNENABLE] enable:NO];
}

+(void) setUserInterfaceEnable: (id<JRTopViewProtocal>)jsonTopView keys:(NSArray*)keys enable:(BOOL)enable
{
    for (NSString* key in keys) {
        UIView* view = [jsonTopView getView: key];
        if (view) {
            [self setUserInterfaceEnable: view enable:enable];
        }
    }
}

+(void) setUserInterfaceEnable: (UIView*)view enable:(BOOL)enable
{
    if ([view isKindOfClass:[UIControl class]]) {
        ((UIControl*)view).enabled = enable;
    }
    
    else
    
    if ([view isKindOfClass:[JRButtonBaseView class]]) {
        ((JRButtonBaseView*)view).button.enabled = enable;
        
    }
    
    else
    
    if ([view isKindOfClass:[JRLabelCommaTextFieldButtonView class]]) {
        ((JRLabelCommaTextFieldButtonView*)view).button.enabled = enable;
    }
    
    else
    
    if ([view isKindOfClass: [JRLabelTextFieldView class]]) {
        ((JRLabelTextFieldView*)view).textField.enabled = enable;
    }
    
    else
    
    if ([view isKindOfClass: [JRLabelTextView class]]) {
        ((JRLabelTextView*)view).textView.editable = enable;
    }
    else
    
    if ([view isKindOfClass: [JRLabelCommaTextFieldView class]]) {
        ((JRLabelCommaTextFieldView*)view).textField.enabled = enable;
    }
    
    
    else
    
    if ([view isKindOfClass: [JRLabelCommaTextView class]]){
        ((JRLabelCommaTextView*)view).textView.editable = enable;
    }
    
    else
    
    if ([view isKindOfClass:[JRTableView class]]){       // editable no , but can drag
        ((JRTableView*)view).tableViewBaseCanEditIndexPathAction = ^BOOL(TableViewBase* tableview, NSIndexPath* indexPath) {
            return  enable;
        };
    }
    
    else
    
    if ([view isKindOfClass:[JRRefreshTableView class]]) {
        ((JRRefreshTableView*)view).tableView.tableViewBaseCanEditIndexPathAction = ^BOOL(TableViewBase* tableview, NSIndexPath* indexPath) {
            return  enable;
        };
    }
    
    else
    
    {
        view.userInteractionEnabled = enable;
        
    }
}



#pragma mark - Images Names and Datas
+(void) loadImagesToJsonView: (JsonController*)jsonController objects:(NSDictionary*)objects
{
    // get images paths
    NSMutableDictionary* imagePathsRepository = [JsonControllerHelper getImagesPathsInController:jsonController];
    NSArray* imagePaths = [imagePathsRepository allValues];
    
    // show indicator
    NSArray* loadJRImageViewAttributes = jsonController.specifications[kController_IMAGES][kController_IMAGES_LOAD];
    for (int i = 0; i < loadJRImageViewAttributes.count; i++) {
        JRImageView* imageView = (JRImageView*)[jsonController.jsonView getView: [loadJRImageViewAttributes objectAtIndex: i]];
        [AppViewHelper showIndicatorInView: imageView];
    }
    
    // request
    [AppServerRequester getImages: imagePaths completeHandler:^(id identification, UIImage *image, NSError *error, BOOL isFinish) {
        for (NSString* attribute in imagePathsRepository) {
            NSString* imagePath = imagePathsRepository[attribute];
            if ([identification isEqualToString: imagePath]) {
                JRImageView* imageView = (JRImageView*)[jsonController.jsonView getView: attribute];
                [imageView setValue: image];
                if (!image) {
                    DLOG(@"No Image : %@", imagePath);
                }
                // hide indicator
                [AppViewHelper stopIndicatorInView: imageView];
            }
        }
    }];
}

+(void) getImagesDatasAndPaths: (JsonController*)jsonController datas:(NSMutableArray*)datasRepository thumbnailDatas:(NSMutableArray*)thumbnailDatas paths:(NSMutableArray*)pathsRepository thumbnailPaths:(NSMutableArray*)thumbnailPaths attributes:(NSArray*)attributes uiImages:(NSArray*)uiImages
{
    NSString* order = jsonController.order;
    NSString* department = jsonController.department;
    NSDictionary* imageNamesConfigs = jsonController.specifications[kController_IMAGES][kController_IMAGES_NAMES];
    NSDictionary* imageDatasConfigs = jsonController.specifications[kController_IMAGES][kController_IMAGES_DATAS];

    for (int i = 0; i < attributes.count; i++) {
        
        UIImage* image = uiImages[i];
        NSString* attribute = attributes[i];
        
        if (!image.isNewGenerated) {
            continue;
        }
        
        // Paths
        NSDictionary* nameConfig = imageNamesConfigs[attribute];
        
        if (!nameConfig) {
            for (NSString* nameconfigKey in imageNamesConfigs) {
                if ([JRComponentHelper isJRAttributesTheSame: nameconfigKey with:attribute]) {
                    nameConfig = imageNamesConfigs[nameconfigKey];
                    break;
                }
            }
        }
        
        NSString* fullPath = [self getImageNamePathWithConfig: nameConfig order:order department:department jsoncontroller:jsonController];
        [pathsRepository addObject: fullPath];
        
        
        // Data
        NSDictionary* dataConfig = [imageDatasConfigs objectForKey:attribute];
        
        // fixed orientation
        BOOL isFix = YES;
        if (dataConfig[kController_IMAGE_FIX_ORIENTATION]) isFix = [dataConfig[kController_IMAGE_FIX_ORIENTATION] boolValue];
        if (isFix) image = [UIImage fixOrientation: image];
        NSData* imageData = nil;
        // png and jpeg
        BOOL isPNGData = [dataConfig[kController_IMAGE_DATA_IS_PNG] boolValue];
        if (isPNGData) {
            imageData = UIImagePNGRepresentation(image);
        } else {
            float jpgCompressQuality = [dataConfig[kController_JPG_CompressionQuality] floatValue];
            if (jpgCompressQuality == 0) jpgCompressQuality = 1;
            imageData = UIImageJPEGRepresentation(image, jpgCompressQuality);
        }
        [datasRepository addObject: imageData];
        
        
        // Thumbnail paths and data
        NSString* thumbnailImagePath = [self appendThumbnailPath: fullPath];
        [thumbnailPaths addObject: thumbnailImagePath];
        
        UIImage* thumbnailImage = [ImageHelper resizeImage: image scale:0.2];
        // fixed orientation
        thumbnailImage = [UIImage fixOrientation: thumbnailImage];
        NSData* thumbnailImageData = nil;
        // png and jpeg
        if (isPNGData) {
            thumbnailImageData = UIImagePNGRepresentation(thumbnailImage);
        } else {
            thumbnailImageData = UIImageJPEGRepresentation(thumbnailImage, 0.5);
        }
        [thumbnailDatas addObject: thumbnailImageData];
        
    }
}

+(NSMutableDictionary*) getImagesPathsInController: (JsonController*)jsonController
{
    return [self getImagesPathsInController: jsonController attributes:jsonController.specifications[kController_IMAGES][kController_IMAGES_LOAD]];
}

+(NSMutableDictionary*) getImagesPathsInController: (JsonController*)jsonController attributes:(NSArray*)attributes
{
    NSString* order = jsonController.order;
    NSString* department = jsonController.department;
    
    NSDictionary* imageNamesConfigs = jsonController.specifications[kController_IMAGES][kController_IMAGES_NAMES];
    
    NSMutableDictionary* imagePaths = [NSMutableDictionary dictionary];
    for (int i = 0; i < attributes.count; i++) {
        NSString* attribute = attributes[i];
        NSDictionary* nameConfig = imageNamesConfigs[attribute];
        
        if (!nameConfig) {
            for (NSString* nameconfigKey in imageNamesConfigs) {
                if ([JRComponentHelper isJRAttributesTheSame: nameconfigKey with:attribute]) {
                    nameConfig = imageNamesConfigs[nameconfigKey];
                    break;
                }
            }
        }
        
        NSString* fullPath = [self getImageNamePathWithConfig: nameConfig order:order department:department jsoncontroller:jsonController];
        [imagePaths setObject: fullPath forKey:attribute];
    }
    return imagePaths;
}

+(NSString*) getImageNamePathWithConfig:(NSDictionary*)config order:(NSString*)order department:(NSString*)department jsoncontroller:(JsonController*)jsoncontroller
{
    NSString* prefix = config[kController_IMGNAME_PRE];
    NSString* suffix = config[kController_IMGNAME_SUF];
    if (!prefix) prefix = @"";
    if (!suffix) suffix = @".JPG";
    NSArray* mainnames = config[kController_IMGNAME_MAIN];
    return [self getImageNamePath: order department:department jsoncontroller:jsoncontroller mainnames:mainnames pprefix:prefix suffix:suffix];
}

+(NSString*) getImageNamePath: (NSString*)order department:(NSString*)department jsoncontroller:(JsonController*)jsoncontroller mainnames:(NSArray*)mainnames pprefix:(NSString*)pprefix suffix:(NSString*)suffix
{
    NSString* directory = [self getImagesHomeFolder: order department:department];       // HumanResource/Employee/
    NSString* mainPathsAndName = [self getImageNamePath: jsoncontroller mainnames:mainnames prefix:pprefix suffix:suffix ];
    NSString* wholeName = [directory stringByAppendingPathComponent: mainPathsAndName];
    NSString* result =  wholeName;
    return result;
}

+(NSString*) getImageNamePath: (JsonController*)jsoncontroller mainnames:(NSArray*)mainnames prefix:(NSString*)prefix suffix:(NSString*)suffix
{
    NSMutableArray* mainNamesContents = [self assembleMainNamePaths: jsoncontroller mainnames:mainnames];
    
    // connect with the prefix and suffix
    NSString* name = [mainNamesContents lastObject];
    NSString* realName = name;
    if (prefix) realName = [prefix stringByAppendingString: name];
    if (suffix) realName = [realName stringByAppendingString: suffix];
    if (realName != name) [mainNamesContents replaceObjectAtIndex: mainNamesContents.count-1 withObject:realName];
    
    NSString* result = [mainNamesContents componentsJoinedByString:@"/"];
    return result;
}
+(NSString*)getImagesHomeFolder: (NSString*)order department:(NSString*)department
{
    return [NSString stringWithFormat:@"IMAGES/%@/%@/", department, order];
}

// the main name array (folder and name (the last on is name) )
// "MAINNAME": ["employeeNO","employeeNO"]  -> /employeeNO/employeeNO
// "MAINNAME": ["employeeNO*employeeNO"]    -> /employeeNO_employeeNO
+(NSMutableArray*) assembleMainNamePaths: (JsonController*)jsoncontroller mainnames:(NSArray*)mainnames
{
    NSMutableArray* contents = [NSMutableArray array];
    for (int i = 0; i < mainnames.count; i++) {
        NSString* attribute = mainnames[i];
        NSString* value = @"";
        
        // connect with "*"
        NSString* connectMainNameFlag = @"*";
        if ([attribute rangeOfString:connectMainNameFlag].location != NSNotFound) {
            NSMutableArray* connectNames = [NSMutableArray array];
            NSArray* assembles = [attribute componentsSeparatedByString:connectMainNameFlag];
            for (int i = 0; i < assembles.count; i++) {
                NSString* subName = [self getValueByAttribute: jsoncontroller attribute: assembles[i]];
                if (subName) [connectNames addObject: subName];
            }
            value = [connectNames componentsJoinedByString:@"_"];
            
            // no connect with "*"
        } else {
            value = [self getValueByAttribute: jsoncontroller attribute: attribute];
        }
        if (value){
            [contents addObject:value];
        }
    }
    return contents;
}

+(id) getValueByAttribute: (JsonController*)jsoncontroller attribute:(NSString*)attribute
{
    NSString* key = [JRComponentHelper getJRAttributePathLastKey: attribute];
    id value = nil;
    value = [((id<JRComponentProtocal>)[jsoncontroller.jsonView getView:attribute]) getValue];
    
    if (!value) {
        value = jsoncontroller.valueObjects[key];
    }
    
    if (!value) {
        value = attribute;
    }
    return value;
}

#pragma mark - Util Image Name Convenience
+(NSString*) appendThumbnailPath: (NSString*)imagePath
{
    NSMutableArray* paths = [NSMutableArray arrayWithArray: [imagePath pathComponents]];
    [paths insertObject: IMAGE_THUMBNAILS_PATH atIndex:paths.count - 1];
    return [paths componentsJoinedByString: @"/"];
}


// attribute is NSString or NSArray, return value is NSString or NSArray
+(id) getImageNamePathWithOrder: (NSString*)order attribute:(id)attribute jsoncontroller:(JsonController*)jsoncontroller
{
    NSString* department = [DATA.modelsStructure getCategory: order];
    NSMutableDictionary* controllerSpecifications = [JsonControllerHelper assembleJsonControllerSpecifications: order];
    
    if ([attribute isKindOfClass: [NSArray class]]) {
        NSArray* attributes = (NSArray*)attribute;
        NSMutableArray* results = [NSMutableArray array];
        for (int i = 0; i < attributes.count; i++) {
            NSString* key = [attributes objectAtIndex:i];
            NSString* photoPath = [JsonControllerHelper getImageNamePathWithConfig: controllerSpecifications[kController_IMAGES][kController_IMAGES_NAMES][key] order:order department:department jsoncontroller:jsoncontroller];
            [results addObject: photoPath];
        }
        return results;
    } else if ([attribute isKindOfClass: [NSString class]]) {
        NSString* key = attribute;
        NSString* photoPath = [JsonControllerHelper getImageNamePathWithConfig: controllerSpecifications[kController_IMAGES][kController_IMAGES_NAMES][key] order:order department:department jsoncontroller:jsoncontroller];
        return photoPath;
    }
    return nil;
}





#pragma mark - Util Methods






#pragma mark - 

+(NSMutableDictionary*) differObjects:(NSDictionary*)oldObjects objects:(NSDictionary*)objects
{
    NSArray* array = @[levelApp1, levelApp2, levelApp3, levelApp4, PROPERTY_CREATEUSER, PROPERTY_CREATEDATE];
    NSMutableDictionary* dictionary = [NSMutableDictionary dictionary];
    for (NSString* key in objects) {
        if ([array containsObject: key]) {
            continue;
        }
        
        id newValue = objects[key];
        id oldValue = oldObjects[key];
        
        if (! ([newValue isKindOfClass:[NSNumber class]] || [newValue isKindOfClass:[NSString class]])) {
            continue;
        }
        
        // check
        BOOL isEqual = YES;
        if ([newValue isKindOfClass: [NSString class]] && [oldValue isKindOfClass: [NSNumber class]]) {
            if (! [newValue isEqualToString: [oldValue stringValue]]) {
                isEqual = NO;
            }
        }
        else
        if ([oldValue isKindOfClass: [NSString class]] && [newValue  isKindOfClass: [NSNumber class]]) {
            if (! [oldValue isEqualToString: [newValue stringValue]]) {
                isEqual = NO;
            }
        }
        else
        if (! [newValue isEqual: oldValue]) {
            isEqual = NO;
        }
        
        // then
        if (! isEqual) {
            [dictionary setObject: newValue forKey:key];
        }
    }
    return dictionary.count ? dictionary : nil;
}

@end
