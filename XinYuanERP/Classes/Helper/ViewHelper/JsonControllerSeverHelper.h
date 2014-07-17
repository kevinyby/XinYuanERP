#import <Foundation/Foundation.h>

@interface JsonControllerSeverHelper : NSObject


+(void) startReturnOrderRequest: (NSString*)orderType department:(NSString*)department valueObjects:(NSDictionary*)valueObjects identities:(NSDictionary*)identities;



+(void) startInformRequest: (NSString*)actionKey orderType:(NSString*)orderType department:(NSString*)department identities:(NSDictionary*)identities forwardUser:(NSString*)forwardUser apnsMessage:(NSString*)apnsMessage;





@end
