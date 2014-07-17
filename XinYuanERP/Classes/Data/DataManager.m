#import "DataManager.h"
#import "ClassesInterface.h"

@implementation DataManager

static DataManager* sharedInstance;

@synthesize appSqlite;
@synthesize modelsStructure;


@synthesize manageObjectModel;
@synthesize manageObjectContext;
@synthesize persistentStoreCoordinator;


- (id)init
{
    self = [super init];
    if (self) {
        appSqlite = [[AppSQLiteManager alloc] init];
        [self initializeSQLiteDatabase];
        
        modelsStructure = [[ModelsStructure alloc] init];
    }
    return self;
}


+(void)initialize {
    if (self == [DataManager class]) {
        sharedInstance = [[DataManager alloc] init];
    }
}
+(DataManager*) getInstance {
    return sharedInstance;
}


-(HTTPRequester *)requester {
    return [[HTTPRequester alloc] init];
}


-(void) initializeSQLiteDatabase
{
    [appSqlite openDataBase];
    [appSqlite createUserTable];
    if ([appSqlite checkIsNoRecord])[appSqlite insertValuesInUser:@"" password:@""];
}


#pragma mark - Core Data Intialize

-(NSManagedObjectModel *)manageObjectModel
{
    if (! manageObjectModel) {
        manageObjectModel = [NSManagedObjectModel mergedModelFromBundles: nil];
    }
    return manageObjectModel;
}

-(NSManagedObjectContext *)manageObjectContext
{
    if (! manageObjectContext) {
        manageObjectContext = [[NSManagedObjectContext alloc] init];
        [manageObjectContext setPersistentStoreCoordinator: self.persistentStoreCoordinator];
    }
    return manageObjectContext;
}

-(NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (! persistentStoreCoordinator) {
        
        persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: self.manageObjectModel];
        
        NSError* error = nil;
        NSString* docs = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        NSString* appDocs = [docs stringByAppendingPathComponent: @"App"];
        NSURL* storeURL = [NSURL fileURLWithPath: [appDocs stringByAppendingPathComponent: @"Models.sqlite"]];
        if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
            NSLog(@"Error : %@ , %@", error, error.userInfo);
        }
    }
    return persistentStoreCoordinator;
}


#pragma mark - Public Methods

-(NSDictionary *)config
{
    return (NSDictionary*)[JsonFileManager getJsonFromFile: @"Config.json"];
}

@end
