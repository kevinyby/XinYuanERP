#import "AppDataHelper.h"
#import "AppInterface.h"

@implementation AppDataHelper


+(void) refreshServerBasicData: (void(^)(BOOL isSuccess))completeHandler
{
    RequestJsonModel* model = [RequestJsonModel getJsonModel];
    model.path = PATH_SETTING(@"refresh");
    [DATA.requester startPostRequest:model completeHandler:^(HTTPRequester* requester, ResponseJsonModel *response, NSHTTPURLResponse *httpURLReqponse, NSError *error) {
        BOOL isSuccess = response.status;
        if (isSuccess)  {
            [AppDataHelper dealWithSignedBasicData: response.results];
        }
        if (completeHandler) {
            completeHandler(isSuccess);
        }
    }];
}

+(void) dealWithSignedBasicData: (NSArray*)objects
{
    NSError* error = nil ;
    if (!objects || !objects.count) {
        NSData* data = [NSData dataWithContentsOfFile: [FileManager.documentsPath stringByAppendingPathComponent: SignedInBasicDataPath ]];
        objects = data ? [NSJSONSerialization JSONObjectWithData: data options:NSJSONReadingAllowFragments error:&error] : nil;
    }
    
    if (!objects) return;
    
    NSData* objectsData = [NSJSONSerialization dataWithJSONObject: objects options:NSJSONWritingPrettyPrinted error:&error];
    if (objectsData) {
        [FileManager writeDataToFile: [FileManager.documentsPath stringByAppendingPathComponent: SignedInBasicDataPath ] data:objectsData];
    }
    
    NSMutableDictionary* usersNONames = [NSMutableDictionary dictionary];
    NSMutableDictionary* usersNOLevels = [NSMutableDictionary dictionary];
    NSMutableDictionary* usersNOApproval = [NSMutableDictionary dictionary];
    NSMutableDictionary* usersNOResign  = [NSMutableDictionary dictionary];
    
    NSMutableDictionary* clientNONames = [NSMutableDictionary dictionary];
    
    // employee and client infos
    NSArray* employeeResults = [objects firstObject];
    NSArray* clientResults = objects[1];
    
    for (NSArray* values in employeeResults) {
        if (values.count == 0) continue;
        NSString* employeeNO = values[0];
        [usersNONames setObject: values[1] forKey:employeeNO];
        [usersNOLevels setObject: values[2] forKey:employeeNO];
        [usersNOApproval setObject: values[3] forKey:employeeNO];
        [usersNOResign setObject: values[4] forKey:employeeNO];
    }
    
    for (NSArray* values in clientResults) {
        if (values.count == 0) continue;
        [clientNONames setObject: values[1] forKey:values[0]];
    }
    
    // approval settings
    NSString* setttingJSON = [objects[2] firstObject];
    NSData* settingData = [setttingJSON dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary* settingsTemp = nil;
    if (settingData != nil) settingsTemp = [NSJSONSerialization JSONObjectWithData: settingData options:NSJSONReadingAllowFragments error:&error];
    NSMutableDictionary* settings = [DictionaryHelper deepCopy: settingsTemp];
    
    @synchronized(DATA) {
        DATA.usersNONames = usersNONames;
        DATA.usersNOLevels = usersNOLevels;
        DATA.usersNOApproval = usersNOApproval;
        DATA.usersNOResign = usersNOResign;
        DATA.clientNONames = clientNONames;
        DATA.approvalSettings = settings;
    }
}



#pragma mark -

+(NSMutableArray*) getAllUserCategoryWheels
{
    NSMutableArray* wheels = [ArrayHelper deepCopy: [DATA.modelsStructure getAllCategories]];
    [wheels addObject: WHEEL_TRACE_STATUS_FILE];
    // ..... OR ADD SOMETHING ELSE
    
    return  [self sortWheels: wheels];
}

+(NSMutableArray*) getUserCategoryWheels: (NSString*)username
{
    NSArray* temp = [[DATA.usersNOPermissions objectForKey:  username] objectForKey: CATEGORIES];
    
    NSMutableArray* wheels = [NSMutableArray array];
    
    // filter , in debug mode, remove it in production
    NSArray* allCategoryWheels = [self getAllUserCategoryWheels];
    for (NSString* cateory in temp) {
        if ([allCategoryWheels containsObject:cateory]) [wheels addObject:cateory];
    }
    
    return  [self sortWheels: wheels];
}

+(NSMutableArray*) sortWheels: (NSArray*)wheels
{
    NSArray* sortedCategoriesWheels = DATA.config[@"WHEELS"][@"SORTED_Categories"];
    return [ArrayHelper reRangeContents: wheels frontContents:sortedCategoriesWheels];
}


+(NSMutableArray*) getUserModelWheels: (NSString*)username department:(NSString*)department
{
    NSDictionary* userOrdersPermissions = [[[DATA.usersNOPermissions objectForKey: username] objectForKey: PERMISSIONS] objectForKey: department];
    NSMutableArray* userOrdersWheels = [NSMutableArray array];
    for (NSString* key in userOrdersPermissions) if ([userOrdersPermissions[key] count]) [userOrdersWheels addObject: key];
    
    // filter , in debug mode, remove it in production
    NSArray* allOrdersInDepartment = [DATA.modelsStructure getOrders: department withBill:NO];
    for (NSString* order in [userOrdersPermissions allKeys]) {
        if (! [allOrdersInDepartment containsObject:order]) [userOrdersWheels removeObject: order];
    }
    
    // remove the contains
    [DATA.modelsStructure removeInsertModelsIn: userOrdersWheels];
    
    NSArray* sortedOrdersWheels = DATA.config[@"WHEELS"][@"SORTED_Models"][department];
    return [ArrayHelper reRangeContents:userOrdersWheels frontContents:sortedOrdersWheels];
}


#pragma mark - APNS Contents Generator
+ (NSMutableDictionary*) getApnsContents: (NSString*)department order:(NSString*)order identities:(NSDictionary*)identities forwardUser:(NSString*)forwardUser alert:(NSString*)alert 
{
    NSMutableDictionary* apnsContents = [self getApnsContents:alert sound:nil badge:-1];
    
    // Custom Information
    NSMutableDictionary* informations = [NSMutableDictionary dictionary];
    if (department) [informations setObject: DOT_CONNENT(department, order)  forKey:APNS_INFOS_CATEGORY_MODEL];
    
    if (identities) [informations setObject: identities forKey:APNS_INFOS_ID];
    
    [informations setObject: DATA.signedUserName forKey:APNS_INFOS_USER_FROM];
    if (forwardUser) [informations setObject: forwardUser forKey:APNS_INFOS_USER_TO];
    
    NSString* informationsJson = [CollectionHelper convertJSONObjectToJSONString: informations];
    [apnsContents setObject:informationsJson forKey:REQUEST_APNS_INFOS];
    
    return apnsContents;
}

+ (NSMutableDictionary*) getApnsContents: (NSString*)alert sound:(NSString*)sound badge:(NSInteger)badge
{
    NSMutableDictionary* apnsContents = [NSMutableDictionary dictionary];
    if (alert) [apnsContents setObject:alert forKey:REQUEST_APNS_ALERT];
    if (sound) [apnsContents setObject: sound forKey:REQUEST_APNS_SOUND];
    if (badge >= 0) [apnsContents setObject: @(badge) forKey:REQUEST_APNS_BADGE];
    return apnsContents;
}



@end
