#import <Foundation/Foundation.h>

@class ResponseJsonModel;

@interface MessagesKeysHelper : NSObject

+(NSString*) parseResponseDescriprions: (ResponseJsonModel*)response;

@end
