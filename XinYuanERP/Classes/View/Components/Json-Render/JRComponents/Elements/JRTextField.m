#import "JRTextField.h"
#import "AppInterface.h"

@interface JRTextField ()
{
    UIView* tapOverlayView;
}

@end

@implementation JRTextField
{
    NSString* _attribute ;
}

#pragma mark - JRComponentProtocal Methods

-(void) initializeComponents: (NSDictionary*)config
{
}

-(NSString*) attribute
{
    return _attribute;
}

-(void) setAttribute: (NSString*)attribute
{
    _attribute = attribute;
}


-(void) subRender: (NSDictionary*)dictionary {
    // is password
    BOOL isPassword = [[dictionary objectForKey: k_JR_PASSWORD] boolValue];
    if (isPassword) [self setSecureTextEntry: YES];
    
    // border style
    if (dictionary[k_JR_BORDERSTYLE]) self.borderStyle = [dictionary[k_JR_BORDERSTYLE] integerValue];
    
    // color , to clear color , set color with ""
    if (dictionary[JSON_BGCOLOR]){
        UIColor* color = [ColorHelper parseColor: dictionary[JSON_BGCOLOR]];
        if (! color) self.backgroundColor = [UIColor clearColor];
    }
    
    // enable or no
    if (dictionary[k_JR_ENABLE]) {
        self.enabled = [dictionary[k_JR_ENABLE] boolValue];
    }
    
    // value is number or not
    if (dictionary[k_JR_ISNUMBER]) {
        self.isNumberValue = [dictionary[k_JR_ISNUMBER] boolValue];
    }
    
    // value is boolean or not , and supply their localize keys
    if ([dictionary[k_JR_ISBOOL] boolValue]) {
        [JRTextField setTextFieldBoolValueAction:self keys:dictionary[k_JR_BOOLKEYS] titleKey:dictionary[k_JR_TITLE_KEY]];
    }
    
    else
    
    // value is members
    if (dictionary[k_JR_ISNAME_NUMBER]) {
        self.isNameNumberValue = [dictionary[k_JR_ISNAME_NUMBER] boolValue];
        self.memberType = dictionary[k_JR_MEMBERTYPE];
        
        self.textFieldDidClickAction = ^void(JRTextField* nameNOTextfield) {
            PickerModelTableView* pickView = [PickerModelTableView popupWithModel:nameNOTextfield.memberType willDimissBlock:nil];
            pickView.titleHeaderViewDidSelectAction = ^void(JRTitleHeaderTableView* headerTableView, NSIndexPath* indexPath){
                
                FilterTableView* filterTableView = (FilterTableView*)headerTableView.tableView.tableView;
                NSIndexPath* realIndexPath = [filterTableView getRealIndexPathInFilterMode: indexPath];
                
                NSString* employeeNO = [filterTableView realContentForIndexPath: realIndexPath];
                [nameNOTextfield setValue: employeeNO];
                [PickerModelTableView dismiss];
            };
        };
    }
    
    else
    
    if (dictionary[k_JR_ISENUM]) {
        self.isEnumerateValue = [dictionary[k_JR_ISENUM] boolValue];
        self.enumerateValues = dictionary[k_JR_ENUMVALUES];
        self.enumerateValuesLocalizeKeys = dictionary[k_JR_ENUMLOCALIZES];
        
        self.textFieldDidClickAction = ^void(JRTextField* jrTextField) {
            NSString* titleKey = jrTextField.attribute;
            if (!titleKey) {
                if ([jrTextField.superview conformsToProtocol:@protocol(JRViewProtocal)]) {
                    titleKey = [((id<JRViewProtocal>)jrTextField.superview) attribute];
                }
            }
            if (titleKey) {
                JsonView* jsonView = [JsonViewHelper getJsonViewBySubview: jrTextField];
                NSString* model = jsonView.attribute;
                titleKey = [model stringByAppendingFormat:@".%@", titleKey];
            }
            [PopupTableHelper showPopTableView: jrTextField titleKey:titleKey dataSources:[LocalizeHelper localize:jrTextField.enumerateValuesLocalizeKeys]];
        };
    }
    
    // image
    UIImage* image = [UIImage imageNamed:[dictionary objectForKey: k_JR_Image]];
    if (image) {
        self.backgroundColor = [UIColor clearColor];
        self.borderStyle = UITextBorderStyleNone;
        self.background = image;
        
        // set size, by image
        [self setSize: [FrameTranslater convertCanvasSize: image.size]];
    }
    
    // when set background , set a left inset , make it look good
    if (image || dictionary[k_JR_LEFTINSET]) {
        float leftPadding = 5 ;         // default
        if (dictionary[k_JR_LEFTINSET]) leftPadding = [dictionary[k_JR_LEFTINSET] floatValue];
        UIView *paddingView = [[UIView alloc] initWithFrame: CGRectMake(0, 0,  [FrameTranslater convertCanvasWidth: leftPadding], 0)];
        self.leftView = paddingView;
        self.leftViewMode = UITextFieldViewModeAlways;
    }
    
}

-(id) getValue {
    NSString* value = self.text;
    
    if (self.isNumberValue) {
        NSNumberFormatter* formatter = [[NSNumberFormatter alloc] init];
        formatter.numberStyle = NSNumberFormatterDecimalStyle;
        NSNumber* number = [formatter numberFromString: value];
        return number;
        
    } else if (self.isBooleanValue) {
        BOOL booleanResult = [value isEqualToString:LOCALIZE_KEY([self.booleanValuesLocalizeKeys lastObject])];
        return [NSNumber numberWithBool: booleanResult];
        
    } else if (self.isEnumerateValue) {
        NSArray* localizes = [LocalizeHelper localize: self.enumerateValuesLocalizeKeys];
        NSInteger index = [localizes indexOfObject: value];
        if (index != NSNotFound) {
            return [self.enumerateValues objectAtIndex: index];
        }
        
    } else if (self.isNameNumberValue) {
        return [JRComponentHelper getNumberInConnectNameNumber: value];
    }
    
    
    // ...
    if ([value isKindOfClass:[NSString class]]) {
        value = [value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    }
    
    return value;
}

-(void) setValue: (id)value {
    NSString* text = value;
    if (self.isNumberValue) {
        
        if ([value isKindOfClass:[NSNumber class]]) {
            text = [value stringValue];
        }
        
    } else if (self.isBooleanValue) {
        
        if ([value isKindOfClass:[NSNumber class]]) {
            BOOL booleanResult = [value boolValue];
            text = booleanResult ? LOCALIZE_KEY([self.booleanValuesLocalizeKeys lastObject]) : LOCALIZE_KEY([self.booleanValuesLocalizeKeys firstObject]);
        }
        
    } else if (self.isEnumerateValue) {
        
        NSInteger index = [self.enumerateValues indexOfObject: value];
        if (index != NSNotFound) {
           text = LOCALIZE_KEY([self.enumerateValuesLocalizeKeys objectAtIndex: index]);
        }
        
    } else if (self.isNameNumberValue) {
        text = [JRComponentHelper getConnectedNameNumber: self.memberType number:value];
    }
    
    
    // ...
    if ([text isKindOfClass: [NSNumber class]]) {
        text = [((NSNumber*)text) stringValue];
//        text = [NSString stringWithFormat: @"%.5f", [text floatValue]];
//        text = [JRTextField convertFloatNumberToString: (NSNumber*)text];
    }
    
    self.text = text;
}


#pragma mark -

-(void)setTextFieldDidClickAction:(JRTextFieldDidClickAction)didClickAction
{
    _textFieldDidClickAction = didClickAction;

    if (didClickAction) {
        if (! tapOverlayView) {
            tapOverlayView = [[UIView alloc] initWithFrame: self.frame];
            UITapGestureRecognizer* tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget: self action:@selector(tapAction:)];
            [tapOverlayView addGestureRecognizer: tapGestureRecognizer];
        }
        [self.superview addSubview: tapOverlayView];
    } else {
        [tapOverlayView removeFromSuperview];
    }
}

-(void) tapAction: (UITapGestureRecognizer *)tapGesture {
    if (self.textFieldDidClickAction) self.textFieldDidClickAction(self);
}

-(void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    if (tapOverlayView && tapOverlayView.superview) {
        tapOverlayView.frame = frame;
    }
}

//validateInput
-(BOOL)textFieldValidate
{
    BOOL result = [self.inputValidator validateInput:self];
    if (!result) {
        [Utility showAlert:self.inputValidator.errorMsg];
    }
    return result;
}


#pragma mark - Class Methods

+(void) setTextFieldBoolValueAction: (JRTextField*)textField keys:(NSArray*)keys titleKey:(NSString*)titleKey
{
    textField.isBooleanValue = YES;
    textField.booleanValuesLocalizeKeys = keys;
    textField.textFieldDidClickAction = ^void(JRTextField* textField) {  [PopupTableHelper showPopTableView: textField titleKey:titleKey dataSources: [LocalizeHelper localize: textField.booleanValuesLocalizeKeys]]; };
}



+(NSString*) convertFloatNumberToString: (NSNumber*)number
{
    NSString* text = [NSString stringWithFormat: @"%.5f", [number floatValue] ];
    
    int zeroCount = 0;
    if ([text rangeOfString: @"."].location != NSNotFound) {
        int dotIndex = [text rangeOfString: @"."].location;
        for (int i = text.length - 1; i > dotIndex; i--) {
            char c = [text characterAtIndex: i];
            NSString* s = [NSString stringWithFormat: @"%c", c];
            if ([s isEqualToString: @"0"]) {
                zeroCount ++ ;
            }
        }
    }
    
    NSString* result = [text substringWithRange: NSMakeRange(0, text.length - zeroCount)];
    return result;
}


@end
