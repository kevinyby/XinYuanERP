#import <Foundation/Foundation.h>

@interface JsonOrderCreateHelper : NSObject

+(void) cannotCreateAlert: (NSString*)order causeOrder:(NSString*)orderType department:(NSString*)department identifier:(id)identifier employeeNO:(NSString*)employeeNO objects:(NSDictionary*)objects;

@end
