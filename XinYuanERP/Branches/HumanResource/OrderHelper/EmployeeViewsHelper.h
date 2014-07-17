#import <Foundation/Foundation.h>

@class JsonView;
@class JsonDivView;

@interface EmployeeViewsHelper : NSObject

+(void) setNameByEmployeeNumber: (NSMutableDictionary*)dictioanry;


#pragma mark -

+(JsonView*) popupJsonView:(NSString*)file key:(NSString*)key dissmiss:(void(^)(UIView* view))block;

@end
