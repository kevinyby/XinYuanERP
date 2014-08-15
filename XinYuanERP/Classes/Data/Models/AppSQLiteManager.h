#import "SQLiteManager.h"

@interface AppSQLiteManager : SQLiteManager


#pragma mark - User Table

- (void) createUserTable;

-(BOOL) checkIsNoRecord;

-(NSArray*) selectFirstUserNameAndPassword ;

- (void) insertValuesInUser: (NSString*)username password:(NSString*)password;

-(void) updateUsername: (NSString*)username;

-(void) updatePassword:(NSString*)password;




@end
