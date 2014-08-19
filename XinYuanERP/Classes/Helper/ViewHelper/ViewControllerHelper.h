#import <Foundation/Foundation.h>

@class JsonView;
@class JRButton;

@interface ViewControllerHelper : NSObject

+(CGRect) getLandscapeBounds;

+(void) filterDictionaryEmptyElement: (NSMutableDictionary*)dictionary ;


+(UIViewController*) getPreviousViewControllerBeforePushSelf ;


#pragma mark -

+(void) popApprovalView: (NSString*)app department:(NSString*)department order:(NSString*)order selectAction:(void(^)(NSString* number))selectAction cancelAction:(void(^)(id sender))cancelAction sendAction:(void(^)(id sender, NSString* number))sendAction;


#pragma mark -

+(NSString*) getOrderType: (NSString*)orderOrBill;

+(NSString*) getUserName: (NSString*)number;

+(NSMutableArray*) getUserNumbersNames: (NSArray*)numbers;

@end
