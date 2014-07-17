#import <Foundation/Foundation.h>

@interface DataParserHelper : NSObject

+(NSMutableDictionary*) parseUserPermissions:(NSArray*)permissions ;

+(id) getKeyByObject:(NSDictionary*)dictionary object:(id)object;

@end
