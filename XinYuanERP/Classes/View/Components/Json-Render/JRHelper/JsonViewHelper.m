#import "JsonViewHelper.h"
#import "AppInterface.h"

@implementation JsonViewHelper

#pragma mark - Class Methods


+(void) refreshJsonViewLocalizeText: (id<JRTopViewProtocal>)jrTopViewProtocal
{
    UIView* contentView = jrTopViewProtocal.contentView;
    NSString* model = jrTopViewProtocal.attribute;
    
    
    //-------------------- Text Begin -----------------
    // set text for label by key/attribute
    [ViewHelper iterateSubView: contentView classes:@[[UILabel class], [UIButton class]] handler:^BOOL(id jrview) {
        [self setLocalizeText: model view:jrview];
        return NO;
    }];
    
    // set the space to text
    [ViewHelper iterateSubView: contentView classes:@[[JRLabel class], [JRButton class]] handler:^BOOL(id subView) {
        [JsonViewHelper setSpaceBetweenLabelText: subView];
        return NO;
    }];
    //-------------------- Text End -----------------
    
    
    
    
    //-------------------- Auto Locate -----------------
    // relocate JRLabelBaseView Components
    [JsonViewHelper autoLocateJRLabelBaseViewComponents:jrTopViewProtocal];
    //-------------------- Auto Locate -----------------
    
    
    
    //-------------------- English & Vient_Nam Begin -----------------
    // English and Viet_nam after resize , do relocate
    if (![AppViewHelper isCurrentLanguageChinese]) {
//        [JsonViewHelper letterResizeViewsWidthRecursive: jsonContentView];        // TODO: Just resize the nested and jrbase view , the container like view.
        [JsonViewHelper letterRelocateHorAlignViews: jrTopViewProtocal];
        [JsonViewHelper letterRelocateVerticalAlignTextFields: jrTopViewProtocal];
    }
    //-------------------- English & Vient_Nam End -----------------
}

+(void) autoLocateJRLabelBaseViewComponents:(id<JRTopViewProtocal>)jrTopViewProtocal
{
    [JsonViewHelper iterateJRLocalizeLabelView: jrTopViewProtocal.contentView specifications:jrTopViewProtocal.specifications handler:^BOOL(UIView *specView, NSDictionary *specification, BOOL isBaseView) {
        
            // JRLabelBaseView
        if (isBaseView) {
            JRLabelBaseView* jrlableview = (JRLabelBaseView*)specView;
            [self autoLocateJRLabelBaseView: jrlableview frames:specification[JSON_SubRender][k_Frames]];
            
            // JRLocalizeLabel
        } else {
            JRLocalizeLabel* jrLocalizeLabel = (JRLocalizeLabel*)specView;
            [self autoLocateJRLocalizeLabel: jrLocalizeLabel frames:specification[JSON_FRAME]];
        }
        
        return NO;
    }];
}

+(void) autoLocateJRLocalizeLabel: (JRLocalizeLabel*)jrLocalizeLabel frames:(NSArray*)frames
{
    float x = 0.0, y = 0.0, width = 0.0, height = 0.0;
    bool isIgnoreX = NO, isIgnoreY = NO, isIgnoreWidth = NO, isIgnoreHeight = NO;
    [FrameHelper paseIgnores: frames :&x :&y :&width :&height :&isIgnoreX :&isIgnoreY :&isIgnoreWidth :&isIgnoreHeight];
    
    if (isIgnoreWidth) {
        [jrLocalizeLabel adjustWidthToFontText];
    }
}

+(void) autoLocateJRLabelBaseView: (JRLabelBaseView*)jrlableview frames:(NSArray*)frames
{
    NSArray* subViews = jrlableview.subviews;
    for (int i = 0; i < subViews.count; i++) {
        UIView* view = subViews[i];
        NSArray* values = [frames safeObjectAtIndex: i];
        
        float x = 0.0, y = 0.0, width = 0.0, height = 0.0;
        bool isIgnoreX = NO, isIgnoreY = NO, isIgnoreWidth = NO, isIgnoreHeight = NO;
        [FrameHelper paseIgnores: values :&x :&y :&width :&height :&isIgnoreX :&isIgnoreY :&isIgnoreWidth :&isIgnoreHeight];
        
        // JRLabelBaseView
        if (view == jrlableview.label && isIgnoreWidth) {
            [jrlableview.label adjustWidthToFontText];                      // Width
        }
        
        // JRLabelButtonView
        if ([jrlableview isKindOfClass:[JRLabelButtonView class]]) {
            JRLabelButtonView* jrlabelButtonView = (JRLabelButtonView*)jrlableview;
            if (view == jrlabelButtonView.label && isIgnoreX) {             // X
                
                // when behide the label
                if ([jrlabelButtonView.label originX] < [jrlabelButtonView.button originX]){
                    [jrlabelButtonView.button setOriginX: [jrlabelButtonView.label sizeWidth]];
                }
                
            }
        }
        
        // JRLabelTextFieldView
        if ([jrlableview isKindOfClass:[JRLabelTextFieldView class]]) {
            JRLabelTextFieldView* jrLabelTextField = (JRLabelTextFieldView*)jrlableview;
            if (view == jrLabelTextField.textField && isIgnoreX) {          // X
                
                // when behide the label
                if ([jrLabelTextField.label originX] <= [jrLabelTextField.textField originX]) {
                    [jrLabelTextField.textField setOriginX: [jrLabelTextField.label sizeWidth] + [FrameTranslater convertCanvasWidth: 8]];
                }
                
                
            }
        }
        
        // JRLabelCommaView
        if ([jrlableview isKindOfClass: [JRLabelCommaView class]]) {
            JRLabelCommaView* labelCommaView = (JRLabelCommaView*)jrlableview;
            if (view == labelCommaView.commaLabel && isIgnoreX) {           // X
                
                [labelCommaView.commaLabel setOriginX: [jrlableview.label sizeWidth]];
                
            }
            
            if (view == labelCommaView.commaLabel && isIgnoreHeight) {      // Height
                
                [labelCommaView.commaLabel setSizeHeight: [jrlableview.label sizeHeight]];
                
            }
        }
        
        // JRLabelCommaTextFieldView
        if ([jrlableview isKindOfClass: [JRLabelCommaTextFieldView class]]) {
            JRLabelCommaTextFieldView* labelCommaTextField = (JRLabelCommaTextFieldView*)jrlableview;
            
            if (view == labelCommaTextField.label && isIgnoreHeight) {      // Height
                
                [labelCommaTextField.label setSizeHeight: [labelCommaTextField.textField sizeHeight]];
                
            }
            
            if (view == labelCommaTextField.commaLabel && isIgnoreHeight) {     // Height
                
                [labelCommaTextField.commaLabel setSizeHeight: [labelCommaTextField.label sizeHeight]];
                
            }
            
            if (view == labelCommaTextField.textField && isIgnoreX) {           // X
                
                [labelCommaTextField.textField setOriginX: [labelCommaTextField.commaLabel sizeWidth] + [labelCommaTextField.commaLabel originX]];
                
            }
        }
        
        // JRLabelCommaTextFieldButtonView
        if ([jrlableview isKindOfClass:[JRLabelCommaTextFieldButtonView class]]) {
            JRLabelCommaTextFieldButtonView* labelCommaTextFieldView = (JRLabelCommaTextFieldButtonView*)jrlableview;
            if (view == labelCommaTextFieldView.button && isIgnoreX) {          // X
                
                [labelCommaTextFieldView.button setOriginX: [labelCommaTextFieldView.textField sizeWidth] + [labelCommaTextFieldView.textField originX]];
                
            }
        }
        
        
        // JRImageLabelCommaTextView
        if ([jrlableview isKindOfClass:[JRImageLabelCommaTextView class]]) {
            JRImageLabelCommaTextView* jrimageLableCommanTextView = (JRImageLabelCommaTextView*)jrlableview;
            if (view == jrimageLableCommanTextView.textView) {
                JRImageView* imageView = jrimageLableCommanTextView.imageView;
                if (isIgnoreX) [view setOriginX: [imageView originX]];
                if (isIgnoreY) [view setOriginY: [imageView originY]];
                if (isIgnoreWidth) [view setSizeWidth: [imageView sizeWidth]];
                if (isIgnoreHeight) [view setSizeHeight: [imageView sizeHeight]];
            }
        }
        
    }
    
    
    
}



+(void) iterateJRLocalizeLabelView: (UIView*)superView specifications:(NSDictionary*)specifications handler:(BOOL (^)(UIView* subView, NSDictionary* spec, BOOL isBaseView))handler
{
    Class labelBaseClazz = [JRLabelBaseView class];
    Class localizeClazz = [JRLocalizeLabel class];
    for (UIView* subView in [superView subviews]) {
        
        if ([subView conformsToProtocol:@protocol(JRViewProtocal)]) {
            id<JRViewProtocal> jrView = (id<JRViewProtocal>)subView;
            NSString* attribute = jrView.attribute;
            NSDictionary* spec = specifications[JSON_COMPONENTS][attribute];
            
            BOOL isBaseView = [subView isKindOfClass:labelBaseClazz];
            if ( isBaseView || [subView isKindOfClass:localizeClazz]) {
                if (handler(subView, spec, isBaseView)) return;
            } else {
                [self iterateJRLocalizeLabelView: subView specifications:spec handler:handler];
            }
        }
        
    }
}

+(void) setLocalizeText: (NSString*)model view:(id<JRViewProtocal>)jrview
{
    if (! [jrview conformsToProtocol:@protocol(JRComponentProtocal)]) return ;
    NSString* attribute = jrview.attribute;
    if (! attribute) return ;                                   // nil ? return
    
    NSString* localizeValue = APPLOCALIZES( attribute, model);
    NSString* connectKeys = LOCALIZE_CONNECT_KEYS(model, attribute);
    if ([localizeValue isEqualToString: connectKeys]) {
        localizeValue = nil;
    }
    
        // JRGradientLabel
    if ([jrview isKindOfClass:[JRGradientLabel class]]) {
        JRGradientLabel* label = (JRGradientLabel*)jrview;
        [label setText: localizeValue];
        
        // JRLocalizeLabel
    } else if ([jrview isKindOfClass:[JRLocalizeLabel class]]) {
        JRLocalizeLabel* label = (JRLocalizeLabel*)jrview;
        CGPoint oCenter = label.center;
        
        [label setText: localizeValue];     // will change the center
        
        if (label.isReserveCenter) label.center = oCenter;
        
        // JRButton
    } else if ([jrview isKindOfClass:[JRButton class]]) {
        JRButton* button = (JRButton*)jrview;
        [button setTitle: localizeValue forState:UIControlStateNormal];
        
        // fix the dot ... contents
        CGSize txtSize = [button.titleLabel.text sizeWithFont:button.titleLabel.font];
        if (txtSize.width > button.titleLabel.bounds.size.width) {
            [button.titleLabel setAdjustsFontSizeToFitWidth: YES];
        }
    }
}


+(void) letterResizeViewsWidthRecursive: (UIView*)jsonContentView
{
    [ViewHelper iterateSubView: jsonContentView class:[JsonDivView class] handler:^BOOL(id subView) {
        [ViewHelper resizeWidthBySubviewsOccupiedWidth: subView];
        return NO;
    }];
    
}

+(void) letterRelocateHorAlignViews: (id<JRTopViewProtocal>)jrTopViewProtocal
{
    NSArray* horizontalAlignments = [jrTopViewProtocal.specifications objectForKey: JSON_LETTER_HORVIEWS];
    for (NSArray* alignElements in horizontalAlignments) {
        NSMutableArray* alignmentViews = [NSMutableArray arrayWithCapacity:alignElements.count];
        for (int i = 0; i < alignElements.count; i++) {
            NSString* key = alignElements[i];
            UIView* view = [jrTopViewProtocal getView: key];
            if (view) [alignmentViews addObject:view];
        }
        [JsonViewHelper relocateHorizontalAlignViews: alignmentViews];
    }
}

+(void) relocateHorizontalAlignViews: (NSArray*)nestedViews
{
    for (int i = 0; i < nestedViews.count; i++) {
        JsonDivView* view = nestedViews[i];
        float occupied = [view sizeWidth]+[view originX];
        if (i != nestedViews.count -1) {
            JsonDivView* nextView = nestedViews[i+1];
            if ( occupied > [nextView originX]) {
                [nextView setOriginX: occupied + 1];
            }
        }
    }
}

+(void) letterRelocateVerticalAlignTextFields: (id<JRTopViewProtocal>)jrTopViewProtocal
{
    NSArray* enVerticalAlignTextFields = [jrTopViewProtocal.specifications objectForKey: JSON_LETTER_VERTEXTFIELDS];
    for (id keys in enVerticalAlignTextFields) {
        NSMutableArray* alignLabelTextFields = [NSMutableArray array];
        
        // get aligns (Specified fileds)
        if ([keys isKindOfClass:[NSArray class]]) {
            
            for (NSString* attribute in keys) {
                UIView* view = [jrTopViewProtocal getView: attribute];
                // JRLabelCommaTextFieldView
                if ([view isKindOfClass:[JRLabelCommaTextFieldView class]]) {
                    [alignLabelTextFields addObject: view];
                }
            }
            
        }
        else
        // get aligns (Specified JsonDivView)
        if ([keys isKindOfClass:[NSString class]]) {
            UIView* view = [jrTopViewProtocal getView: keys];
            [ViewHelper iterateSubView: view class:[JRLabelCommaTextFieldView class] handler:^BOOL(id subView) {
                [alignLabelTextFields addObject: subView];
                return NO;
            }];
        }
        
        // set aligns
        [self relocateVerticalAlignTextFields: alignLabelTextFields];
    }
}
+(void) relocateVerticalAlignTextFields:(NSArray*)alignLabelTextFields
{
    float longestX = [JsonViewHelper getTheLongestTextFieldOriginX: alignLabelTextFields];
    for (JRLabelCommaTextFieldView* commaTextField in alignLabelTextFields) {
        float subtract = longestX - [commaTextField.textField originX];
        [commaTextField addSizeWidth: subtract];
        [commaTextField.textField setOriginX: longestX];
        
        // Label Comma TextField Button
        if ([commaTextField isKindOfClass:[JRLabelCommaTextFieldButtonView class]]) {
            JRLabelCommaTextFieldButtonView* labelCommaTextFieldView = (JRLabelCommaTextFieldButtonView*)commaTextField;
            [labelCommaTextFieldView.button setOriginX: [labelCommaTextFieldView.textField sizeWidth] + [labelCommaTextFieldView.textField originX]];
        }
    }
}
+(float) getTheLongestTextFieldOriginX: (NSArray*)textFields
{
    float longestX = 0.0f;
    for (JRLabelCommaTextFieldView* subview in textFields) {
        float x = [subview.textField originX];
        longestX = longestX < x ? x : longestX;
    }
    return longestX;
}

#pragma mark -
+(void) setSpaceBetweenLabelText: (id)subView
{
    if ([subView isKindOfClass:[JRButton class]]) {
        JRButton* button = (JRButton*)subView;
        NSString* newString = button.titleLabel.text;
        
        // chinese
        if ([AppViewHelper isCurrentLanguageChinese]) {
            NSString* cnSpace = button.cnSpace;
            if (cnSpace.length > 0) {
                newString = [StringHelper separate: newString spaceMeta:cnSpace];
            }
            
        // english and viet_nam
        } else {
            NSString* enSpace = button.enSpace;
            if (enSpace.length > 0 ) {
                newString = [StringHelper separate: newString spaceMeta:enSpace];
            }
        }
        

        [button setTitle: newString forState:UIControlStateNormal];
        
    } else if ([subView isKindOfClass:[JRLabel class]]) {
        JRLabel* label = (JRLabel*)subView;
        NSString* newString = label.text;
        
        // chinese
        if ([AppViewHelper isCurrentLanguageChinese]) {
            NSString* cnSpace = label.cnSpace;
            if (cnSpace.length > 0) {
                newString = [StringHelper separate: newString spaceMeta:cnSpace];
            }
            
        // english and viet_nam
        } else {
            NSString* enSpace = label.enSpace;
            if (enSpace.length > 0 ) {
                newString = [StringHelper separate: newString spaceMeta:enSpace];
            }
        }

        if (! [label.text isEqualToString: newString])label.text = newString;
    }
}

#pragma mark - Label Font
TextFormatter* textFormatter = nil;
+(TextFormatter*) textFormatter
{
    if (!textFormatter) {
        textFormatter = [[TextFormatter alloc] init];
    }
    return textFormatter;
}

+(void) setLabelFontAttribute: (UILabel*)label config:(NSDictionary*)dictionary
{
    [self.textFormatter execute: dictionary onObject: label];

    label.font = [self getFontWithConfig: dictionary];
}

#pragma mark - Font
+(UIFont*) getFontWithConfig:(NSDictionary*)dictionary
{
    NSString* fontName = [dictionary objectForKey: JSON_FONT_NAME];
    NSNumber* fontSize = [dictionary objectForKey: JSON_FONT_SIZE];
    fontName = fontName ? fontName : @"Arial";
    int size = fontSize ? [fontSize integerValue] : 18 ;
    return [UIFont fontWithName:fontName size: [FrameTranslater convertFontSize: size]];
}

+(void) setViewSharedAttributes: (UIView*)component config: (NSDictionary*)config
{
    if (config[JSON_TAG]) component.tag = [config[JSON_TAG] integerValue];
    if (config[JSON_BGCOLOR]) [ColorHelper setBackGround: component color:config[JSON_BGCOLOR]];
    if (config[JSON_BORDER]) {
        float boderWidth = [config[JSON_BORDERWIDTH] floatValue];
        boderWidth = boderWidth == 0 ? 1.0f : boderWidth;
        [ColorHelper setBorder: component color:config[JSON_BORDER] width:boderWidth];
    }
    if (config[JSON_RADIUS]) {
        component.layer.cornerRadius = [config[JSON_RADIUS] floatValue];
        component.layer.masksToBounds = YES;
    }
    
}




+(JsonView*) getJsonViewBySubview: (UIView*)subView
{
    JsonView* jsonview = (JsonView*)[subView superview];
    
    while (jsonview && ![jsonview isKindOfClass:[JsonView class]]) jsonview = (JsonView*)[jsonview superview];
    
    return jsonview;
}




@end
