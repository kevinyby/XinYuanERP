#import "AppViewHelper.h"
#import "AppInterface.h"

@implementation AppViewHelper

// Return nil when __INDEX__ is beyond the bounds of the array
#define NSArrayObjectMaybeNil(__ARRAY__, __INDEX__) ((__INDEX__ >= [__ARRAY__ count]) ? nil : [__ARRAY__ objectAtIndex:__INDEX__])
// Manually expand an array into an argument list
#define NSArrayToVariableArgumentsList(__ARRAYNAME__)\
NSArrayObjectMaybeNil(__ARRAYNAME__, 0),\
NSArrayObjectMaybeNil(__ARRAYNAME__, 1),\
NSArrayObjectMaybeNil(__ARRAYNAME__, 2),\
NSArrayObjectMaybeNil(__ARRAYNAME__, 3),\
NSArrayObjectMaybeNil(__ARRAYNAME__, 4),\
NSArrayObjectMaybeNil(__ARRAYNAME__, 5),\
NSArrayObjectMaybeNil(__ARRAYNAME__, 6),\
NSArrayObjectMaybeNil(__ARRAYNAME__, 7),\
NSArrayObjectMaybeNil(__ARRAYNAME__, 8),\
NSArrayObjectMaybeNil(__ARRAYNAME__, 9),\
nil


+(NSString*) localizations: (NSString*)key, ... NS_REQUIRES_NIL_TERMINATION
{
    NSMutableArray* keys = [NSMutableArray array];
    va_list list;
    va_start(list, key);
    do {
        [keys addObject: key];
        key = va_arg(list, NSString*);
    } while (key);
    va_end(list);
    
    NSString* attributes = [LocalizeHelper connectKeys: keys];      // with "KEYS.XXX.XXX.XXX" prefix
    return [self localization: attributes];
}

+(NSString*) localization: (NSString*)attribute
{
    return [self localization: attribute model:nil];
}

+(NSString*) localization: (NSString*)attribute model:(NSString*)model
{
    NSString* localizeValue = nil;
    
    // e.g. "MESSAGE_ADMIN.MAIN" -> LOCALIZE_MESSAGE_FORMAT("ADMIN", LOCALIZE_KEY("MAIN"))
    if ([attribute hasPrefix: APP_MESSAGE_PREFIX]) {
        NSString* keys = [attribute stringByReplacingCharactersInRange:(NSRange){0, [APP_MESSAGE_PREFIX length]} withString:@""];
        NSArray* attributeComponents = [keys componentsSeparatedByString:LOCALIZE_KEY_CONNECTOR];
        NSMutableArray* values = [NSMutableArray array];
        for (int i = 1; i < attributeComponents.count; i++) {
            [values addObject: LOCALIZE_KEY(attributeComponents[i])];
        }
        localizeValue = LOCALIZE_MESSAGE_FORMAT([attributeComponents firstObject] , NSArrayToVariableArgumentsList(values));
        
        // e.g. "KEYS.male.employee" -> LOCALIZE_KEY("male") + LOCALIZE_KEY("employee")
    } else if ([attribute hasPrefix: LOCALIZE_KEYS_PREFIX]) {
        
        NSString* connectKeys = [attribute stringByReplacingCharactersInRange:(NSRange){0, [LOCALIZE_KEYS_PREFIX length]} withString:@""];
        NSMutableArray* attributeComponents = [AppViewHelper getKeyElements: connectKeys];
        NSMutableArray* values = [NSMutableArray array];
        for (int i = 0; i < attributeComponents.count; i++) {
            [values addObject: LOCALIZE_KEY(attributeComponents[i])];
        }
        
        
        NSString* connector = [self isCurrentLanguageEnglish] ? @" " : @"";
        localizeValue = [values componentsJoinedByString:connector];
        
        // e.g. "department" -> "Employee.department"
    } else {
        localizeValue = LOCALIZE_KEY(LOCALIZE_CONNECT_KEYS(model, attribute));
    }
    
    return localizeValue;
}

+(NSMutableArray*) getKeyElements: (NSString*)longKey
{
    // @"ad.(ttt.fff).aaa.(ooo.ppp).mmm.(a.b)" - [ad, ttt.fff, aaa, ooo.ppp, mmmm, a.b]
    NSMutableArray* result = [NSMutableArray array];
    __block NSMutableString* mutableString = [[NSMutableString alloc] init];
    __block BOOL isInBracket = NO;
    [StringHelper iterateString: longKey handler:^BOOL(int index, unichar character) {
        NSString* element =  [NSString stringWithFormat:@"%C", character];
        
        if (![result containsObject: mutableString]) {
            [result addObject: mutableString];
        }
        
        if ([element isEqualToString:@"("]) {
            isInBracket = YES;
            return NO;
        }
        if ([element isEqualToString: @")"]) {
            isInBracket = NO;
            mutableString = [[NSMutableString alloc] init];
            return NO;
        }
        
        if (isInBracket) {
            [mutableString appendString: element];
            
        } else {
            
            if ([element isEqualToString: @"."]) {
                mutableString = [[NSMutableString alloc] init];
            } else {
                [mutableString appendString: element];
            }
            
        }
        
        return NO;
    }];
    
    [result removeObject:@""];
    return result;
}

+(BOOL) isCurrentLanguageChinese
{
    return [[[NSUserDefaults standardUserDefaults] objectForKey: PREFERENCE_LANGUAGE] hasPrefix: @"zh"];
}

+(BOOL) isCurrentLanguageEnglish
{
    return [[[NSUserDefaults standardUserDefaults] objectForKey: PREFERENCE_LANGUAGE] hasPrefix: @"en"];
}



#pragma mark - Refresh Localize By Selected Language

+(void) refreshLocalizeTextBySelectLanguage: (JsonView*)jsonview
{
    NSArray* localizeLanguages = [LocalizeHelper localize: LANGUAGES];
    [PopupViewHelper popSheet: LOCALIZE_MESSAGE(MESSAGE_SelectALanguage) inView:[ViewHelper getTopView] actionBlock:^(UIView *popView, NSInteger index) {
        if (index >= 0 && index < LANGUAGES.count) {
            NSString* languageSelected = LANGUAGES[index];
            // Set Preference Language
            [[NSUserDefaults standardUserDefaults] setObject: languageSelected forKey: PREFERENCE_LANGUAGE];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            [CategoriesLocalizer setCurrentLanguage: languageSelected];
            [JsonViewHelper refreshJsonViewLocalizeText: jsonview];
        }
    } buttonTitles: localizeLanguages];
}



#pragma mark -

+(UIActivityIndicatorView*) showIndicatorInViewAndDisableInteraction: (UIView*)view
{
    view.userInteractionEnabled = NO;
    return [self showIndicatorInView: view];
}

+(UIActivityIndicatorView*) showIndicatorInView: (UIView*)view
{
    UIActivityIndicatorView* indicator = [ViewHelper getIndicatorInView: view];
    [indicator startAnimating];
    return indicator;
}

+(UIActivityIndicatorView*) stopIndicatorInViewAndEnableInteraction: (UIView*)view
{
    view.userInteractionEnabled = YES;
    return [self stopIndicatorInView: view];
}

+(UIActivityIndicatorView*) stopIndicatorInView: (UIView*)view
{
    UIActivityIndicatorView* indicator = [ViewHelper getIndicatorInView: view];
    [indicator stopAnimating];
    return indicator;
}



+(AppWheelViewController*) getDepartmentsWheelController
{
    AppWheelViewController* controller = [[AppWheelViewController alloc] init];
    controller.config = DATA.config[@"WHEELS"][@"1"];
    return controller;
}

+(AppWheelViewController*) getOrdersWheelController
{
    AppWheelViewController* controller = [[AppWheelViewController alloc] init];
    controller.config = DATA.config[@"WHEELS"][@"2"];
    return controller;
}

@end
