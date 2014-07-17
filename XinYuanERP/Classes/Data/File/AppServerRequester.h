#import <Foundation/Foundation.h>

@class HTTPRequester;
@class ResponseJsonModel;

@interface AppServerRequester : NSObject

+(HTTPRequester*) deleteModel: (NSString*)model department:(NSString*)department identities:(NSDictionary*)identities completeHandler:(void(^)(bool isSuccess))completeHandler;







+(HTTPRequester*) readModel: (NSString*)model department:(NSString*)department objects:(NSDictionary*)objects completeHandler:(void(^)(ResponseJsonModel *response, NSError *error))completeHandler;
+(HTTPRequester*) readModel: (NSString*)model department:(NSString*)department objects:(NSDictionary*)objects fields:(NSArray*)fields completeHandler:(void(^)(ResponseJsonModel *response, NSError *error))completeHandler;
+(HTTPRequester*) readModel: (NSString*)model department:(NSString*)department objects:(NSDictionary*)objects fields:(NSArray*)fields limits:(NSArray*)limits completeHandler:(void(^)(ResponseJsonModel *response, NSError *error))completeHandler;
+(HTTPRequester*) readModel: (NSString*)model department:(NSString*)department objects:(NSDictionary*)objects fields:(NSArray*)fields limits:(NSArray*)limits sorts:(NSArray*)sorts completeHandler:(void(^)(ResponseJsonModel *response, NSError *error))completeHandler;






+(HTTPRequester*) readModels: (NSArray*)models department:(NSString*)department objects:(NSArray*)objects completeHandler:(void(^)(ResponseJsonModel *response, NSError *error))completeHandler;
+(HTTPRequester*) readModels: (NSArray*)models department:(NSString*)department objects:(NSArray*)objects fields:(NSArray*)fields completeHandler:(void(^)(ResponseJsonModel *response, NSError *error))completeHandler;
+(HTTPRequester*) readModels: (NSArray*)models department:(NSString*)department objects:(NSArray*)objects fields:(NSArray*)fields limits:(NSArray*)limits completeHandler:(void(^)(ResponseJsonModel *response, NSError *error))completeHandler;
+(HTTPRequester*) readModels: (NSArray*)models department:(NSString*)department objects:(NSArray*)objects fields:(NSArray*)fields limits:(NSArray*)limits sorts:(NSArray*)sorts completeHandler:(void(^)(ResponseJsonModel *response, NSError *error))completeHandler;






// ------
+(void)modifyModel: (NSString*)model department:(NSString*)department objects:(NSDictionary*)objects identities:(NSDictionary*)identities completeHandler:(void(^)(ResponseJsonModel *response, NSError *error))completeHandler;






// ------
+(void)modifySetting: (NSString*)type json:(NSString*)jsonString completeHandler:(void(^)(ResponseJsonModel *response, NSError *error))completeHandler;
+(void)readSetting: (NSString*)type completeHandler:(void(^)(ResponseJsonModel *response, NSError *error))completeHandler;






// ------
+(void) createModel: (NSString*)model department:(NSString*)department objects:(NSDictionary*)objects completeHandler:(void(^)(ResponseJsonModel *response, NSError *error))completeHandler;







// can be optimize  -------
+(void) apply: (NSString*)model department:(NSString*)department identities:(id)identities objects:(NSDictionary*)objects applevel:(NSString*)applevel forwarduser:(NSString*)forwarduser completeHandler:(void(^)(ResponseJsonModel *response, NSError *error))completeHandler;
// can be optimize  -------






+(void) sendInform: (NSString*)username contents:(NSDictionary*)contents completeHandler:(void(^)(ResponseJsonModel *response, NSError *error))completeHandler;





// save images ------- 
+(void) saveImages: (NSArray*)images paths:(NSArray*)paths completeHandler:(void(^)(id identification, ResponseJsonModel *response, NSError *error, BOOL isFinish))completeHandler;
+(void) getImages: (NSArray*)imagePaths completeHandler:(void(^)(id identification, UIImage* image, NSError *error, BOOL isFinish))completeHandler;
+(void) getImage: (NSString*)imagePath completeHandler:(void(^)(id identification, UIImage* image, NSError *error))completeHandler;


+(void) deleteImagesFolder:(NSString*)folderPath completeHandler:(void(^)(HTTPRequester *requester, ResponseJsonModel *model, NSHTTPURLResponse *httpURLReqponse, NSError *error))completeHandler
;


@end
