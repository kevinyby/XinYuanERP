#import "AppServerRequester.h"
#import "AppInterface.h"

@implementation AppServerRequester

/**
 *  Delete the one order in server
 *
 *  @param model      order type
 *  @param department department
 *  @param object     dictioinary with id / orderNO , add identities
 */
+(HTTPRequester*) deleteModel: (NSString*)model department:(NSString*)department identities:(NSDictionary*)identities completeHandler:(void(^)(bool isSuccess))completeHandler
{
    RequestJsonModel* requestModel = [RequestJsonModel getJsonModel];
    requestModel.path = PATH_LOGIC_DELETE(department);
    [requestModel addModels: model, nil];
    if(identities) [requestModel.identities addObject: identities];
    HTTPRequester* requester = DATA.requester;
    [requester startPostRequestWithAlertTips: requestModel completeHandler:^(HTTPRequester *requester, ResponseJsonModel *response, NSHTTPURLResponse *httpURLReqponse, NSError *error) {
        if (completeHandler) completeHandler(response.status);
    }];
    return requester;
}

/**
 *  Read the one order in server
 *
 *  @param model      order type
 *  @param department department
 *  @param object     dictioinary with id / orderNO , add unique column key-value
 */
+(HTTPRequester*) readModel: (NSString*)model department:(NSString*)department objects:(NSDictionary*)objects completeHandler:(void(^)(ResponseJsonModel *response, NSError *error))completeHandler
{
    return [self readModel: model department:department objects:objects fields:nil completeHandler:completeHandler];
}

+(HTTPRequester*) readModel: (NSString*)model department:(NSString*)department objects:(NSDictionary*)objects fields:(NSArray*)fields completeHandler:(void(^)(ResponseJsonModel *response, NSError *error))completeHandler
{
    return [self readModel: model department:department objects:objects fields:fields limits:nil completeHandler:completeHandler];
}

+(HTTPRequester*) readModel: (NSString*)model department:(NSString*)department objects:(NSDictionary*)objects fields:(NSArray*)fields limits:(NSArray*)limits completeHandler:(void(^)(ResponseJsonModel *response, NSError *error))completeHandler
{
    return [self readModel: model department:department objects:objects fields:fields limits:limits sorts:nil completeHandler:completeHandler];
}

+(HTTPRequester*) readModel: (NSString*)model department:(NSString*)department objects:(NSDictionary*)objects fields:(NSArray*)fields limits:(NSArray*)limits sorts:(NSArray*)sorts completeHandler:(void(^)(ResponseJsonModel *response, NSError *error))completeHandler
{
    RequestJsonModel* requestModel = [RequestJsonModel getJsonModel];
    requestModel.path = PATH_LOGIC_READ(department);
    [requestModel addModels: model, nil];
    if (objects) [requestModel addObjects: objects, nil];
    if (fields) [requestModel.fields addObject: fields];
    if (limits) [requestModel.limits addObject: limits];
    if (sorts) [requestModel.sorts addObject: sorts];
    HTTPRequester* requester = DATA.requester;
    [requester startPostRequest:requestModel completeHandler:^(HTTPRequester* requester, ResponseJsonModel *response, NSHTTPURLResponse *httpURLReqponse, NSError *error) {
        if (completeHandler) completeHandler(response , error);
    }];
    return requester;
}


/**
 *  Read the multi order, but same department, in server
 *
 *  @param models      orders type
 *  @param department department or super 
 *  @param objects     dictioinary with id / orderNO , add unique column key-value
 */
+(HTTPRequester*) readModels: (NSArray*)models department:(NSString*)department objects:(NSArray*)objects completeHandler:(void(^)(ResponseJsonModel *response, NSError *error))completeHandler
{
    return [self readModels: models department:department objects:objects fields:nil completeHandler:completeHandler];
}

+(HTTPRequester*) readModels: (NSArray*)models department:(NSString*)department objects:(NSArray*)objects fields:(NSArray*)fields completeHandler:(void(^)(ResponseJsonModel *response, NSError *error))completeHandler
{
    return [self readModels:models department:department objects:objects fields:fields limits:nil completeHandler:completeHandler];
}

+(HTTPRequester*) readModels: (NSArray*)models department:(NSString*)department objects:(NSArray*)objects fields:(NSArray*)fields limits:(NSArray*)limits completeHandler:(void(^)(ResponseJsonModel *response, NSError *error))completeHandler
{
    return [self readModels:models department:department objects:objects fields:fields limits:limits sorts:nil completeHandler:completeHandler];
}

+(HTTPRequester*) readModels: (NSArray*)models department:(NSString*)department objects:(NSArray*)objects fields:(NSArray*)fields limits:(NSArray*)limits sorts:(NSArray*)sorts completeHandler:(void(^)(ResponseJsonModel *response, NSError *error))completeHandler
{
    RequestJsonModel* requestModel = [RequestJsonModel getJsonModel];
    requestModel.path = PATH_LOGIC_READ(department);
    [requestModel addModelsFromArray:models];
    if (objects) [requestModel addObjectsFromArray: objects];
    if (fields) [requestModel.fields addObjectsFromArray: fields];
    if (limits) [requestModel.limits addObjectsFromArray: limits];
    if (sorts) [requestModel.sorts addObjectsFromArray: sorts];
    HTTPRequester* requester = DATA.requester;
    [requester startPostRequest:requestModel completeHandler:^(HTTPRequester* requester, ResponseJsonModel *response, NSHTTPURLResponse *httpURLReqponse, NSError *error) {
        if (completeHandler) completeHandler(response , error);
    }];
    return requester;
}


/*
 * Modify the objects
 *
 */
+(void)modifyModel: (NSString*)model department:(NSString*)department objects:(NSDictionary*)objects identities:(NSDictionary*)identities completeHandler:(void(^)(ResponseJsonModel *response, NSError *error))completeHandler
{
    RequestJsonModel* requestModel = [RequestJsonModel getJsonModel];
    requestModel.path = PATH_LOGIC_MODIFY(department);
    [requestModel addModels: model, nil];
    [requestModel addObjects: objects, nil];
    [requestModel.identities addObject: identities];
    [DATA.requester startPostRequest:requestModel completeHandler:^(HTTPRequester* requester, ResponseJsonModel *response, NSHTTPURLResponse *httpURLReqponse, NSError *error) {
        if (completeHandler) completeHandler(response , error);
    }];
}

+(void)modifySetting: (NSString*)type json:(NSString*)jsonString completeHandler:(void(^)(ResponseJsonModel *response, NSError *error))completeHandler
{
    RequestJsonModel* requestModel = [RequestJsonModel getJsonModel];
    requestModel.path = PATH_SETTING(@"modifyType");
    [requestModel addModels: MODEL_APPSETTINGS, nil];
    [requestModel addObjects: @{@"settings": jsonString}, nil];
    [requestModel.identities addObject: @{@"type":type}];
    [DATA.requester startPostRequest:requestModel completeHandler:^(HTTPRequester* requester, ResponseJsonModel *response, NSHTTPURLResponse *httpURLReqponse, NSError *error) {
        if (completeHandler) completeHandler(response , error);
    }];
}
+(void)readSetting: (NSString*)type completeHandler:(void(^)(ResponseJsonModel *response, NSError *error))completeHandler
{
    RequestJsonModel* requestModel = [RequestJsonModel getJsonModel];
    requestModel.path = PATH_SETTING(@"readType");
    [requestModel addModels: MODEL_APPSETTINGS, nil];
    [requestModel.identities addObject: @{@"type":type}];
    [DATA.requester startPostRequest:requestModel completeHandler:^(HTTPRequester* requester, ResponseJsonModel *response, NSHTTPURLResponse *httpURLReqponse, NSError *error) {
        if (completeHandler) completeHandler(response , error);
    }];
}

/**
 *  Create the one order in server
 *
 *  @param model      order type
 *  @param department department
 *  @param object     dictioinary is the create contents
 */
+(void) createModel: (NSString*)model department:(NSString*)department objects:(NSDictionary*)objects completeHandler:(void(^)(ResponseJsonModel *response, NSError *error))completeHandler
{
    RequestJsonModel* requestModel = [RequestJsonModel getJsonModel];
    requestModel.path = PATH_LOGIC_CREATE(department);
    [requestModel addModels: model, nil];
    [requestModel addObject: objects ];
    [DATA.requester startPostRequest:requestModel completeHandler:^(HTTPRequester* requester, ResponseJsonModel *response, NSHTTPURLResponse *httpURLReqponse, NSError *error) {
        if (completeHandler) completeHandler(response , error);
    }];
}


/**
 *  Apply the order , (When in apply , can be modifiy)
 *
 *
 */
+(void) apply: (NSString*)model department:(NSString*)department identities:(id)identities objects:(NSDictionary*)objects applevel:(NSString*)applevel forwarduser:(NSString*)forwarduser completeHandler:(void(^)(ResponseJsonModel *response, NSError *error))completeHandler
{
    RequestJsonModel* requestModel = [RequestJsonModel getJsonModel];
    requestModel.path = PATH_LOGIC_APPLY(department);
    [requestModel addModels: model, nil];
    if (objects) [requestModel addObject: objects ];
    
    [requestModel.identities addObject: identities];
    [requestModel.parameters setObject: applevel forKey:REQUEST_PARA_APPLEVEL];
    
    if (forwarduser) [requestModel.apns_forwards addObject:forwarduser];
    
    [DATA.requester startPostRequestWithAlertTips: requestModel completeHandler:^(HTTPRequester* requester, ResponseJsonModel *response, NSHTTPURLResponse *httpURLReqponse, NSError *error) {
        if (completeHandler) completeHandler(response , error);
    }];
}





/**
 *  Send the apns inform
 *
 *  @param username      username to inform
 *  @param contents      contents to inform
 */
+(void) sendInform: (NSString*)username contents:(NSDictionary*)contents completeHandler:(void(^)(ResponseJsonModel *response, NSError *error))completeHandler
{
    RequestJsonModel* requestModel = [RequestJsonModel getJsonModel];
    requestModel.path = PATH_SETTING_INFORM;
    [requestModel.apns_forwards addObject: username];
    [requestModel.apns_contents addObject: contents];
    [DATA.requester startPostRequest:requestModel completeHandler:^(HTTPRequester* requester, ResponseJsonModel *response, NSHTTPURLResponse *httpURLReqponse, NSError *error) {
        if (completeHandler) completeHandler(response , error);
    }];
}







/**
 *      images : image's NSData
 *      paths  : the paths u want to save in the server end
 *      path as identification
 */
+(void) saveImages: (NSArray*)images paths:(NSArray*)paths completeHandler:(void(^)(id identification, ResponseJsonModel *response, NSError *error, BOOL isFinish))completeHandler
{
    NSMutableArray* parameters = [NSMutableArray array];
    for (int i = 0; i < images.count; i++) {
        NSData* imageData = images[i];
        NSString* path = paths[i];
        NSDictionary* param = @{UPLOAD_Data: imageData, UPLOAD_FileName: path} ;
        [parameters addObject: param];
    }
    
    __block int count = 0;
    int totalCount = parameters.count;
    // send
    [HTTPBatchRequester startBatchUploadRequest:parameters url:IMAGE_URL(UPLOAD) identifications:paths delegate:nil completeHandler:^(HTTPRequester *requester, ResponseJsonModel *model, NSHTTPURLResponse *httpURLReqponse, NSError *error) {
        count++;
        BOOL isFinish = count == totalCount;
        if (completeHandler) completeHandler(requester.identification, model, error, isFinish);
    }];
}

/**
 *  Download the images
 */
+(void) getImages: (NSArray*)imagePaths completeHandler:(void(^)(id identification, UIImage* image, NSError *error, BOOL isFinish))completeHandler
{
    NSMutableArray* parameters = [NSMutableArray array];
    for (int i = 0; i < imagePaths.count; i++) {
        NSString* path = imagePaths[i];
        NSDictionary* param = @{@"PATH": path, @"ThumbnailPrefered": @(1)} ;
        [parameters addObject: param];
    }
    
    __block int count = 0;
    int totalCount = imagePaths.count;
    // send
    [HTTPBatchRequester startBatchDownloadRequest:parameters url:IMAGE_URL(DOWNLOAD) identifications:imagePaths delegate:nil completeHandler:^(HTTPRequester *requester, ResponseJsonModel *model, NSHTTPURLResponse *httpURLReqponse, NSError *error) {
        count++;
        BOOL isFinish = count == totalCount;
        UIImage* image = [UIImage imageWithData: model.binaryData];
        if (completeHandler) completeHandler(requester.identification, image, error, isFinish);
    }];

}

+(void) getImage: (NSString*)imagePath completeHandler:(void(^)(id identification, UIImage* image, NSError *error))completeHandler
{
    // send
    [DATA.requester startDownloadRequest: IMAGE_URL(DOWNLOAD) parameters:@{@"PATH":imagePath} completeHandler:^(HTTPRequester *requester, ResponseJsonModel *model, NSHTTPURLResponse *httpURLReqponse, NSError *error) {
        UIImage* image = [UIImage imageWithData: model.binaryData];
        if (completeHandler) completeHandler(requester.identification, image, error);
    }];
}

+(void) deleteImagesFolder:(NSString*)folderPath completeHandler:(void(^)(HTTPRequester *requester, ResponseJsonModel *model, NSHTTPURLResponse *httpURLReqponse, NSError *error))completeHandler
{
    DLOG(@"Delete FolderPath ++++++ : %@", folderPath);
    [DATA.requester startPostRequest:IMAGE_URL(@"delete") parameters:@{@"Folder": folderPath} completeHandler:^(HTTPRequester *requester, ResponseJsonModel *model, NSHTTPURLResponse *httpURLReqponse, NSError *error) {
        if (completeHandler) {
            completeHandler(requester, model, httpURLReqponse, error);
        }
    }];
}

@end
