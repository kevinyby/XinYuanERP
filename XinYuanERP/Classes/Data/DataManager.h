#import <Foundation/Foundation.h>

#define DATA [DataManager getInstance]

@class HTTPRequester;
@class ModelsStructure;
@class AppSQLiteManager;

@interface DataManager : NSObject


// core data begin

@property (nonatomic, strong, readonly) NSManagedObjectModel* manageObjectModel;
@property (nonatomic, strong, readonly) NSManagedObjectContext* manageObjectContext;
@property (nonatomic, strong, readonly) NSPersistentStoreCoordinator* persistentStoreCoordinator;

// core data end

@property (strong) NSString* cookies;
@property (assign) int signedUserId;
@property (strong) NSString* signedUserName;
@property (strong) NSString* signedUserPassword;
@property (strong) NSMutableDictionary* usersNONames;
@property (strong) NSMutableDictionary* usersNOLevels;
@property (strong) NSMutableDictionary* usersNOApproval;
@property (strong) NSMutableDictionary* usersNOResign;
@property (strong) NSMutableDictionary* usersNOPermissions;
@property (strong) NSMutableDictionary* clientNONames;

@property (strong) NSMutableDictionary* approvalSettings;

@property (strong) NSMutableArray* productCategorys;


@property (readonly) AppSQLiteManager* appSqlite;

@property (readonly) HTTPRequester* requester;

@property (readonly) ModelsStructure* modelsStructure;


+(DataManager*) getInstance ;


#pragma mark - Public Methods

-(NSDictionary*) config;

@end
