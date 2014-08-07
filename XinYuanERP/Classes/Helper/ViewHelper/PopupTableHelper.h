#import <Foundation/Foundation.h>


@class JsonView;
@class JRButton;
@class JRTextField;
@class JRButtonsHeaderTableView;


#define POPUP_TABLEVIEW_TAG 110110

@interface PopupTableHelper : NSObject


#pragma mark - New Interface
+(void) setupPopTableViewsInJsonView:(JsonView*)jsonView config:(NSDictionary*)config;

+(void) setupPopTableView: (JRTextField*)textField type:(NSString*)type;

+(JRButtonsHeaderTableView*) showUpJobLevelPopTableView: (JRTextField*)jrTextField;

+(JRButtonsHeaderTableView*) showPopTableView: (JRTextField*)textField titleKey:(NSString*)titleKey dataSources:(NSArray*)dataSources;
+(JRButtonsHeaderTableView*) showPopTableView: (JRTextField*)textField titleKey:(NSString*)titleKey dataSources:(NSArray*)dataSources realDataSources:(NSArray*)realDataSources;

+(void) dissmissCurrentPopTableView;


// to get back JRButtonsHeaderTableView you should use viewWithTag:POPUP_TABLEVIEW_TAG ....
+(UIView*) getCommonPopupTableView;


+(NSMutableArray*) getJobPositionDataSoucesFromSettingsString: (NSString*)jobPositionString;

@end
