#import "JRComponentHelper.h"
#import "AppInterface.h"

@implementation JRComponentHelper


+(JRButton*) getJRButton:(UIView*)buttonView
{
    if (! buttonView) {
        return nil;
    }
    
    JRButton* submitBTN = nil;
    
    if ([buttonView isKindOfClass:[JRButton class]]) {
        submitBTN = (JRButton*)buttonView;
    } else if ([buttonView isKindOfClass:[JRButtonBaseView class]]) {
        submitBTN = ((JRButtonBaseView*)buttonView).button;
    }
    return submitBTN;
}

+(JRTextField*) getJRTextField: (UIView*)view
{
    __block JRTextField* jrTextField = nil;
    if ([view isKindOfClass:[JRTextField class]] ) {
        jrTextField = (JRTextField*)view;
    } else {
        [ViewHelper iterateSubView:view class:[JRTextField class] handler:^BOOL(id subView) {
            jrTextField = subView;
            return YES;
        }];
    }
    return jrTextField;
}

#pragma mark -Toogle Buttons
+(void) setupToggleButtons: (JsonView*)jsonView components:(NSArray*)components
{
    JRButtonSetValueBlock setJRButtonValueBlock = ^void(JRButton* button, id value) {
        BOOL result = [value boolValue];
        if (result) {
            [button addSubview: button.imageView];
        } else {
            [button.imageView removeFromSuperview];
        }
    };
    JRButtonGetValueBlock getJRButtonValueBlock = ^id(JRButton* button){
        BOOL result = NO;
        if (button.imageView.superview) result = YES;
        return [NSNumber numberWithBool: result];
    };
    NormalButtonDidClickBlock didClikcButtonAction = ^void(JRButton* button) {
        if (button.imageView.superview) {
            [button.imageView removeFromSuperview];
        } else {
            [button addSubview: button.imageView];
        }
    };
    
    for(NSDictionary* config in components) {
        NSString* buttonKey = config[kTOGGLEButton];
        NSNumber* defaultValue = config[kTOGGLEValue];
        
        JRButton* jrButton = (JRButton*)[jsonView getView:buttonKey];
        
        jrButton.setJRButtonValueBlock = setJRButtonValueBlock;
        jrButton.getJRButtonValueBlock = getJRButtonValueBlock;
        jrButton.didClikcButtonAction = didClikcButtonAction;
        [jrButton setValue: defaultValue];      // set default value
    }
}

#pragma mark -QR Code
+(void) setupQRCodeComponents: (JsonView*)jsonView components:(NSArray*)components
{
    for(NSDictionary* config in components) {
        
        NSString* buttonKey = config[QRButton];
        NSString* imageViewKey = config[QRImage];
        NSArray* contentsKeys = config[QRContentKeys];
        NSArray* tipsKeys = config[QRTipsKeys];
        tipsKeys = tipsKeys ? tipsKeys : contentsKeys;
        float width = config[QRImageWidth] ? [config[QRImageWidth] floatValue] : 600;
        
        JRButton* createQRBTN = (JRButton*)[jsonView getView:buttonKey];
        JRImageView* QRCodeIMGView = (JRImageView*)[jsonView getView:imageViewKey];
        
        createQRBTN.didClikcButtonAction = ^void(JRButton* createQRBTN) {
            
            NSMutableArray* assembleContents = [NSMutableArray array];
            for (NSInteger i = 0; i < contentsKeys.count ; i++) {
                NSString* attribute = [contentsKeys objectAtIndex:i];
                id value = [(((id<JRComponentProtocal>)[jsonView getView:attribute])) getValue];
                value = value ? value : @"";
                [assembleContents addObject:value];
            }
            
            UIImage* image = [QRCodeString QRCodeFrom: assembleContents keys:tipsKeys sizeWidth: width];
            image = [[UIImage alloc] initWithData: UIImageJPEGRepresentation(image, 1)];
            if (image) {
                QRCodeIMGView.image = image;
//                QRCodeIMGView.backgroundColor = [UIColor whiteColor];
            }
        };
        
    }
}

#pragma mark - Photo
+(void) setupPhotoPickerComponents: (JsonView*)jsonview config:(NSDictionary*)config
{
    for (NSString* key in config) {
        NSString* attribute = config[key];
        UIView* buttonView = [jsonview getView: key];
        UIView* imageView = [jsonview getView: attribute];
        if ([buttonView isKindOfClass:[JRButton class]] && [imageView isKindOfClass:[JRImageView class]]) {
            JRButton* jrbutton = (JRButton*)buttonView;
            JRImageView* jrImageView =(JRImageView*)imageView;
            [self setupPhotoPickerWithInteractivView: jrbutton completeHandler:^void(UIImagePickerController* controller, UIImage* image) {
                jrImageView.image = image;
            }];
        }
    }
}

+(void) setupPhotoPickerWithInteractivView:(JRButton*)button completeHandler:(void(^)(UIImagePickerController* controller, UIImage* image))completeHandler
{
    button.didClikcButtonAction = ^void(JRButton* button) {
        if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            AppImagePickerController* imagePickerController = [[AppImagePickerController alloc] init];
            imagePickerController.didFinishPickingImage = completeHandler;
            [VIEW.navigator.topViewController presentViewController:imagePickerController animated:YES completion: NULL];
        }
    };
}

#pragma mark - Photos Preview
static NSMutableArray* mwPhotos;
+(void) setupPreviewImageComponents: (JsonController*)jsonController config:(NSDictionary*)config
{
    // preview
    JsonView* jsonview = jsonController.jsonView;
    for (NSString* attribute in config) {
        UIView* view = [jsonview getView: attribute];
        
        if ([view isKindOfClass:[JRImageView class]]) {
            __weak JRImageView* jrimageView = (JRImageView*)view;
            
            
            jrimageView.didClickAction = ^void(JRImageView* imageView) {
                // get div 'NESTED' super view
                JsonDivView* divView = (JsonDivView*)imageView;
                while (divView) {
                    divView = (JsonDivView*)divView.superview;
                    if ([divView isKindOfClass:[JsonDivView class]] && [divView.attribute rangeOfString:@"INCREMENT_"].location != NSNotFound) {
                        break;
                    }
                }
                NSString* nestedKey = divView.attribute;
                
                
                if (! jrimageView.image) return;
                
                if (/*jsonController.controlMode == JsonControllerModeCreate || */jsonController.controlMode == JsonControllerModeNull) {
                    [JRComponentHelper previewImagesWithBrowseImageView: imageView config:[config objectForKey: attribute]];
                } else {
                    [JRComponentHelper previewImagesWithMWPhotoBrowser: jsonController currentAttribute:imageView.attribute divViewKey:nestedKey];
                }
            };
        }
    }
}
+ (void) previewImagesWithBrowseImageView: (JRImageView*)jrimageView config:(NSDictionary*)config
{
    float x = 0 ;
    // config --- Begin
    if (config[kController_IMAGES_PREVIEWS_X]) {
        x = [config[kController_IMAGES_PREVIEWS_X] floatValue];
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            if (config[kController_IMAGES_PREVIEWS_IPhoneRation]) {
                float ratio = [config[kController_IMAGES_PREVIEWS_IPhoneRation] floatValue];
                x *= ratio;
            }
        }
    }
    // config --- End
    [BrowseImageView browseImage: jrimageView adjustSize: [FrameTranslater convertCanvasWidth: x]];
}
+ (void) previewImagesWithMWPhotoBrowser: (JsonController*)jsonController currentAttribute:(NSString*)currentAttribute divViewKey:(NSString*)divViewKey
{
    MWPhotoBrowser* photoBrowser = [[MWPhotoBrowser alloc] initWithDelegate:(id<MWPhotoBrowserDelegate>)self];
    photoBrowser.zoomPhotosToFill = NO;
    photoBrowser.displayActionButton = YES;
    photoBrowser.displayNavArrows = NO;
    photoBrowser.wantsFullScreenLayout = YES;
    
    // animation
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:photoBrowser];
//    nc.modalTransitionStyle = ((arc4random() % 30) + 1) % 5 == 0 ?  UIModalTransitionStylePartialCurl : UIModalTransitionStyleCrossDissolve ;
    [[ViewHelper getTopViewController] presentModalViewController:navigationController animated:YES];
    
    // data sources
    if (! mwPhotos) {
        mwPhotos = [NSMutableArray array];
    } else {
        [mwPhotos removeAllObjects];
    }
    
    NSArray* loadJRImageViewAttributes = jsonController.specifications[kController_IMAGES][kController_IMAGES_LOAD];
    NSMutableDictionary* loadImagePathsRepository = [JsonControllerHelper getImagesPathsInController: jsonController];
    
    NSArray* previewImageViewAttributes = [jsonController.specifications[kController_IMAGES][kController_IMAGES_PREVIEWS] allKeys];
    previewImageViewAttributes = [ArrayHelper reRangeContents: previewImageViewAttributes frontContents:loadJRImageViewAttributes];
    
    for (NSUInteger i = 0; i < previewImageViewAttributes.count; i++) {
        NSString* attribute = previewImageViewAttributes[i];
        
        MWPhoto* mwPhoto = nil;
        
        if (jsonController.controlMode == JsonControllerModeCreate) {
            UIImage* image = ((JRImageView*)[jsonController.jsonView getView:attribute]).image;
            if (image) {
                mwPhoto = [[MWPhoto alloc] initWithImage: image];
            }
        } else {
            NSString* loadPath = loadImagePathsRepository[attribute];
            mwPhoto = [[MWPhoto alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@?%@",IMAGE_URL(DOWNLOAD),loadPath]]];
        }
        
        if (mwPhoto) {
            [mwPhotos addObject: mwPhoto];
        }
        
        // set current image index
        if ([self isContainsMutilpleSameKeys: currentAttribute in:loadJRImageViewAttributes]) {
            
            NSString* fullKey = [divViewKey stringByAppendingFormat:@".%@", currentAttribute];
            if ([attribute isEqualToString: fullKey]) {
                [photoBrowser setCurrentPhotoIndex: mwPhotos.count - 1];
            }
            
        } else {
            if ([self isJRAttributesTheSame: currentAttribute with:attribute]) {
                [photoBrowser setCurrentPhotoIndex: mwPhotos.count - 1];
            }
        }
        
    }
}

+(BOOL) isContainsMutilpleSameKeys: (NSString*)accruteAttribute in:(NSArray*)loadJRImageViewAttributes
{
    int count =0 ;
    for (NSString* key in loadJRImageViewAttributes) {
        if ([JRComponentHelper isJRAttributesTheSame:accruteAttribute with:key]) {
            count ++ ;
        }
    }
    return count >= 2;
}

+ (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser
{
    return mwPhotos.count;
}
+ (id<MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index
{
    return [mwPhotos objectAtIndex:index];
}



#pragma mark - Signature
+(void) setupSignaturePicker: (JsonView*)jsonView config:(NSDictionary*)config
{
    for (NSString* viewKey in config) {
        NSString* imageViewKey = [config objectForKey: viewKey];
        
        // Signature
        JRImageView* signatureIMGView = (JRImageView*)[jsonView getView:imageViewKey];
        
        
        UIView* interactiveView = [jsonView getView:viewKey];  // JRButton , JRTextField, JRImageView not go in
        while (interactiveView && !([interactiveView isKindOfClass:[JRButton class]] || [interactiveView isKindOfClass:[JRLocalizeLabel class]] || [interactiveView isKindOfClass:[JRTextField class]] || [interactiveView isKindOfClass:[JRImageView class]] )) {
            for (UIView* subView in interactiveView.subviews) {
                if ([subView isKindOfClass:[JRButton class]] || [subView isKindOfClass:[JRLocalizeLabel class]] ||[subView isKindOfClass:[JRTextField class]] || [subView isKindOfClass:[JRImageView class]]) {
                    interactiveView = subView;
                    break;
                }
            }
        }
        
        if ([interactiveView isKindOfClass:[JRButton class]]) {
            ((JRButton*)interactiveView).didClikcButtonAction = ^void(JRButton* bt) {
                [JRComponentHelper popSignatureView: signatureIMGView];
            };
            
        } else if ([interactiveView isKindOfClass:[JRLocalizeLabel class]]) {
            ((JRLocalizeLabel*)interactiveView).jrLocalizeLabelDidClickAction = ^void(JRLocalizeLabel* lb) {
                [JRComponentHelper popSignatureView: signatureIMGView];
            };
        } else if ([interactiveView isKindOfClass:[JRTextField class]]) {
            ((JRTextField*)interactiveView).textFieldDidClickAction = ^void(JRTextField* tx) {
                [JRComponentHelper popSignatureView: signatureIMGView];
            };
        } else if ([interactiveView isKindOfClass:[JRImageView class]]) {

            JRImageView* imageView = (JRImageView*)interactiveView;
            JRImageViewDidClickAction previewAction = imageView.didClickAction;
            
            ((JRImageView*)interactiveView).didClickAction = ^void(JRImageView* img) {
                if (img.image) {
                    if (previewAction) previewAction(img);
                } else {
                    [JRComponentHelper popSignatureView: img];
                }
            };
            
        }
        
    }
}


#pragma mark - Date

static const char* CONST_DataPickerType = "PickerType";
+(void) setupDatePickerComponents: (JsonView*)jsonview pickers:(NSArray*)pickers patterns:(NSDictionary*)patterns
{
    for (int i = 0; i < pickers.count; i ++) {
        NSString* keyPath = pickers[i];
        UIView* view = [jsonview getView: keyPath];
        
        for (UIView* subView in view.subviews) {
            if ([subView isKindOfClass:[JRTextField class]]) {
                JRTextField* tapElement = (JRTextField*)subView;
                
                NSString* patternStr = patterns[keyPath];
                objc_setAssociatedObject(tapElement, CONST_DataPickerType, patternStr, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
                tapElement.textFieldDidClickAction = ^void(JRTextField* textFieldObj) {
                    [JRComponentHelper showDatePicker: textFieldObj];
                };
            }
            
            else
            
            if ([subView isKindOfClass:[UIButton class]]) {
                UIButton* tapElement = (UIButton*)subView;
                if (!tapElement.enabled) continue;
                
                NSString* patternStr = patterns[keyPath];
                objc_setAssociatedObject(tapElement, CONST_DataPickerType, patternStr, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
                [tapElement addTarget: [JRComponentHelper class] action:@selector(showDatePicker:) forControlEvents:UIControlEventTouchUpInside];
            }
        }

    }
}


+(void) showDatePicker: (UIView*)obj
{
    // get pattern
    NSString* pattern = objc_getAssociatedObject(obj, CONST_DataPickerType);
    if (! pattern) pattern = DATE_PATTERN;
    
    // get textField
    UITextField* textField = nil;
    UIView* superView = obj.superview;
    for (UIView* subView in superView.subviews) {
        if ([subView isKindOfClass:[UITextField class]]) {
            textField = (UITextField*)subView;
        }
    }
    ActionDateDoneBlock doneBlock = ^(NSDate *selectedDate, id origin) {
        textField.text = [DateHelper stringFromDate:selectedDate pattern:pattern];
        [textField resignFirstResponder];
    };
    ActionDateCancelBlock cancelBlock = ^{
        [textField resignFirstResponder];
    };
    
    NSDate* date = [DateHelper dateFromString:textField.text pattern:pattern];
    date = date == nil ? [NSDate date] : date;
    
    // picker mode
    UIDatePickerMode pickerMode = UIDatePickerModeDate;     // default date
    if ([pattern isEqualToString: DATE_TIME_PATTERN]) {
        pickerMode = UIDatePickerModeDateAndTime;
    } else if ([pattern isEqualToString: DATE_CLOCK_PATTERN]){
        pickerMode = UIDatePickerModeTime;
    }
    [ActionSheetDatePicker showPickerWithTitle:@"" datePickerMode:pickerMode selectedDate:date doneBlock:doneBlock cancelBlock:cancelBlock origin:textField];
}

//
+(void) tranlateDateComponentToVisual:(NSMutableDictionary*)objects patterns:(NSDictionary*)patterns
{
    for (NSString* keyPath in patterns) {
        NSString* pattern = patterns[keyPath];
        
        NSString* key = [[keyPath componentsSeparatedByString:@"."] lastObject];
        NSString* value = objects[key];
        
        if (! OBJECT_EMPYT(value)) {
            [objects setObject:[DateHelper stringFromString:value fromPattern:DATE_TIME_PATTERN toPattern:pattern] forKey:key];
        }
    }
}

+(void) tranlateDateComponentToSend: (JsonView*)jsonview patterns:(NSDictionary*)patterns objects:(NSMutableDictionary*)objects
{
    for (NSString* keyPath in patterns) {
        NSString* pattern = patterns[keyPath];
        
        NSString* key = [[keyPath componentsSeparatedByString:@"."] lastObject];
        NSString* value = objects[key];
        
        if (! OBJECT_EMPYT(value)) {
            NSString* standarFormat = [DateHelper stringFromString:value fromPattern:pattern toPattern:DATE_TIME_PATTERN];
            [objects setObject: standarFormat forKey:key];
        }
    }
}


#pragma mark -
//
+(void) translateNumberToName:(NSMutableDictionary*)objects attributes:(NSArray*)attributes
{
    for (NSString* key in attributes) {
        NSString* number = objects[key];
        if (! OBJECT_EMPYT(number)) {
            NSString* name = DATA.usersNONames[number];
            if (name) [objects setObject: name forKey:key];
        }
    }
}



#pragma mark - Pop Signature View
+(void) popSignatureView: (UIImageView*)containerImageView
{
    JsonView* signatureJsonView =  (JsonView*)[JsonViewRenderHelper renderFile:@"Components" specificationsKey:@"SignatureViewWithButtons"];
    signatureJsonView.scrollEnabled = NO;
    JRSignatureView* signatureView = (JRSignatureView*)[signatureJsonView getView:@"SignatureView"];
    JRButton* cancelBTN = (JRButton*)[signatureJsonView getView:@"Sign_Cancel"];
    JRButton* saveBTN = (JRButton*)[signatureJsonView getView:@"Sign_Save"];
    JRButton* clearBTN = (JRButton*)[signatureJsonView getView:@"Sign_Clear"];
    __weak JRSignatureView* weaksignatureView = signatureView;
    clearBTN.didClikcButtonAction = ^void(id sender) {
        [weaksignatureView erase];
    };
    cancelBTN.didClikcButtonAction = ^void(id sender) {
//        containerImageView.image = nil;
        [PopupViewHelper dissmissCurrentPopView];
    };
    saveBTN.didClikcButtonAction = ^void(id sender) {
        if (weaksignatureView.signatureImage) containerImageView.image = weaksignatureView.signatureImage;
        [PopupViewHelper dissmissCurrentPopView];
    };
    
    [PopupViewHelper popView: signatureJsonView willDissmiss: nil];
}





#pragma mark - Class Mthods

#define STAFFNAMENO_Ecap1      @"("
#define STAFFNAMENO_Ecap2      @")"
+(NSString*) getNameByNumber: (NSString*)type number:(NSString*)number
{
    NSString* name = number;
    if (!type || [type isEqualToString: MODEL_EMPLOYEE]) {
        name = DATA.usersNONames[number];
        
    } else if ([type isEqualToString: MODEL_VENDOR]) {
        
    } else if ([type isEqualToString: MODEL_CLIENT]) {
        
    }
    return name;
}
+(NSString*) getConnectedNameNumber: (NSString*)type number:(NSString*)number
{
    NSString* name = [self getNameByNumber: type number:number];
    if ([name isEqualToString: number]) {
        return name;
    } else {
        return [name stringByAppendingFormat:@"%@%@%@", STAFFNAMENO_Ecap1, number, STAFFNAMENO_Ecap2];
    }
}
+(NSString*) getNumberInConnectNameNumber: (NSString*)connectNameNumber
{
    NSString* number = [StringHelper stringBetweenString: connectNameNumber start:STAFFNAMENO_Ecap1 end:STAFFNAMENO_Ecap2];
    return number;
}


#pragma mark -
+(NSString*) getJRAttributePathLastKey:(NSString*) attribute
{
    if ([attribute rangeOfString:DOT].location != NSNotFound) {
        attribute = [[attribute componentsSeparatedByString:DOT] lastObject];
    }
    return attribute;
}
+(BOOL) isJRAttributesTheSame: (NSString*)attribute with:(NSString*)contrastAttribute
{
    attribute = [self getJRAttributePathLastKey: attribute];
    contrastAttribute = [self getJRAttributePathLastKey: contrastAttribute];
    return [attribute isEqualToString:contrastAttribute];
}

@end
