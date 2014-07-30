#import <Foundation/Foundation.h>

@interface AppDataParserHelper : NSObject

+(NSMutableDictionary*) parseUserPermissions:(NSArray*)permissions ;

+(id) getKeyByObject:(NSDictionary*)dictionary object:(id)object;

@end
