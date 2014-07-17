#import "SQLiteManager.h"

@interface AppSQLiteManager : SQLiteManager


- (void) createUserTable;

-(NSArray*) selectFirstUser ;
- (NSArray*) selectLastUser ;

- (void) insertValuesInUser: (NSString*)username password:(NSString*)password;

-(void) insertPassword:(NSString*)password;

-(void) insertUsername: (NSString*)username;

-(void) updateUsername: (NSString*)username;

-(void) updatePassword:(NSString*)password;

-(BOOL) checkIsNoRecord;



@end
