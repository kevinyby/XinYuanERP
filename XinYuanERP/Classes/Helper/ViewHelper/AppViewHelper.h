#import <Foundation/Foundation.h>


#define APP_MESSAGE_PREFIX  @"MESSAGE_"

#define APPLOCALIZE_KEYS(_key, args...) [AppViewHelper localizations:_key, ##args, nil]
#define APPLOCALIZE(_key) [AppViewHelper localization:_key]
#define APPLOCALIZES(_key, _item) [AppViewHelper localization:_key model:_item]



@class JsonView;
@class AppWheelViewController;


@interface AppViewHelper : NSObject

#pragma mark -
+(NSString*) localizations: (NSString*)key, ... NS_REQUIRES_NIL_TERMINATION;
+(NSString*) localization: (NSString*)attribute;
+(NSString*) localization: (NSString*)attribute model:(NSString*)model;
+(NSMutableArray*) getKeyElements: (NSString*)longKey;


+(BOOL) isCurrentLanguageChinese;
+(BOOL) isCurrentLanguageEnglish;


#pragma mark - Refresh Localize By Selected Language

+(void) refreshLocalizeTextBySelectLanguage: (JsonView*)jsonview;


#pragma mark -

+(UIActivityIndicatorView*) showIndicatorInViewAndDisableInteraction: (UIView*)view;
+(UIActivityIndicatorView*) showIndicatorInView: (UIView*)view;
+(UIActivityIndicatorView*) stopIndicatorInViewAndEnableInteraction: (UIView*)view;
+(UIActivityIndicatorView*) stopIndicatorInView: (UIView*)view;


+(AppWheelViewController*) getDepartmentsWheelController;
+(AppWheelViewController*) getOrdersWheelController;

@end
