#import "AppSQLiteManager.h"

@implementation AppSQLiteManager

#pragma mark - User Table

-(void)createUserTable
{
    /*BOOL status = */[self executeSQL: "create table if not exists User (id integer primary key autoincrement, username text , password text)"];
}

-(void) insertValuesInUser: (NSString*)username password:(NSString*)password
{
    const char* usernamChar = [username cStringUsingEncoding:NSUTF8StringEncoding];
    const char* passwordChar = [password cStringUsingEncoding:NSUTF8StringEncoding];
    
    char *sql = "insert into User(username,password) values (?, ?)";
    
    [self executeUpdateInsertSQL: sql handle:^(sqlite3_stmt *statement) {
        sqlite3_bind_text(statement, 1, usernamChar, -1, NULL);
        sqlite3_bind_text(statement, 2, passwordChar, -1, NULL);
    }];
}


-(void) updateUsername: (NSString*)username
{
    [self updateColumn: @"username" value:username];
}

-(void) updatePassword:(NSString*)password
{
    [self updateColumn: @"password" value:password];
}

-(void) updateColumn:(NSString*)column value:(NSString*)value
{
    const char* valueChar = [value cStringUsingEncoding:NSUTF8StringEncoding];
    const char *sql = [[NSString stringWithFormat: @"update User set %@ = (?) WHERE id = (SELECT MIN(id) FROM User)", column] UTF8String];
    [self executeUpdateInsertSQL: sql handle:^(sqlite3_stmt *statement) {
        sqlite3_bind_text(statement, 1, valueChar, -1, NULL);
    }];
}


-(NSArray*) selectFirstUserNameAndPassword {
    __block NSString* name = @"";
    __block NSString* pass = @"";
    [self executeSelectSQL: "SELECT username,password FROM User WHERE ID = 1" handle:^(sqlite3_stmt *statement) {
        char * username = (char *)sqlite3_column_text(statement, 0);
        char * password = (char*)sqlite3_column_text(statement, 1);
        if (username != NULL ) name = [[NSString alloc] initWithCString:username encoding:NSUTF8StringEncoding];
        if (password != NULL ) pass = [[NSString alloc] initWithCString:password encoding:NSUTF8StringEncoding];
    }];
    return @[name,pass];
}


-(BOOL) checkIsNoRecord
{
    __block int _id = 0;
    [self executeSelectSQL: "SELECT id FROM User WHERE ID = (SELECT MAX(ID) FROM User)" handle:^(sqlite3_stmt *statement) {
        _id = sqlite3_column_int(statement, 0);
    }];
    
    return _id == 0;
}

@end
