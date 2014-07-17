#import "AppSQLiteManager.h"

@implementation AppSQLiteManager


-(void) selectUserTable
{
    sqlite3* database = self.SQLiteInstance;
    
    const char *selectSql="select id , username, password from User";
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(database, selectSql, -1, &statement, nil)==SQLITE_OK) {
        NSLog(@"select ok.");
    } else {
        NSLog(@"select error.");
    }
    while (sqlite3_step(statement)==SQLITE_ROW) {
        int _id=sqlite3_column_int(statement, 0);
        char *username=(char *)sqlite3_column_text(statement, 1);
        char *password = (char*)sqlite3_column_text(statement, 2);
        NSLog(@"row>>id %i, username %s, password %s",_id, username, password);
    } 
    sqlite3_finalize(statement);
}


#pragma mark - Public Methods

-(void)createUserTable
{
    char *createSql = "create table if not exists User (id integer primary key autoincrement, username text , password text)";
    
    int status = [self execute: createSql];
    
    if (!status) {
//        NSLog(@"create user table suffully");
    } else {
//        NSLog(@"create user table failed");
    }
}

-(void) insertValuesInUser: (NSString*)username password:(NSString*)password
{
    sqlite3* database = self.SQLiteInstance;
    const char* usernamChar = [username cStringUsingEncoding:NSUTF8StringEncoding];
    const char* passwordChar = [password cStringUsingEncoding:NSUTF8StringEncoding];
    
    char *sql = "insert into User(username,password) values (?, ?)";
    sqlite3_stmt *stmt;
    if (sqlite3_prepare_v2(database, sql, -1, &stmt, nil) == SQLITE_OK) {
        sqlite3_bind_text(stmt, 1, usernamChar, -1, NULL);
        sqlite3_bind_text(stmt, 2, passwordChar, -1, NULL);
    }
    if (sqlite3_step(stmt) != SQLITE_DONE)  NSLog(@"Something is Wrong!");
    sqlite3_finalize(stmt);
}

-(void) insertUsername: (NSString*)username
{
    sqlite3* database = self.SQLiteInstance;
    const char* usernamChar = [username cStringUsingEncoding:NSUTF8StringEncoding];
    
    char *sql = "insert into User(username) values (?)";
    sqlite3_stmt *stmt;
    if (sqlite3_prepare_v2(database, sql, -1, &stmt, nil) == SQLITE_OK) {
        sqlite3_bind_text(stmt, 1, usernamChar, -1, NULL);
    }
    if (sqlite3_step(stmt) != SQLITE_DONE)  NSLog(@"Something is Wrong!");
    sqlite3_finalize(stmt);
}

-(void) insertPassword:(NSString*)password
{
    sqlite3* database = self.SQLiteInstance;
    const char* passwordChar = [password cStringUsingEncoding:NSUTF8StringEncoding];
    
    char *sql = "insert into User(password) values (?)";
    sqlite3_stmt *stmt;
    if (sqlite3_prepare_v2(database, sql, -1, &stmt, nil) == SQLITE_OK) {
        sqlite3_bind_text(stmt, 1, passwordChar, -1, NULL);
    }
    if (sqlite3_step(stmt) != SQLITE_DONE)  NSLog(@"Something is Wrong!");
    sqlite3_finalize(stmt);
}


-(void) updateUsername: (NSString*)username
{
    sqlite3* database = self.SQLiteInstance;
    const char* usernamChar = [username cStringUsingEncoding:NSUTF8StringEncoding];
    
    char *sql = "update User set username = (?) WHERE id = (SELECT MIN(id) FROM User)";
    sqlite3_stmt *stmt;
    if (sqlite3_prepare_v2(database, sql, -1, &stmt, nil) == SQLITE_OK) {
        sqlite3_bind_text(stmt, 1, usernamChar, -1, NULL);
    }
    int type = sqlite3_step(stmt);
    if (type != SQLITE_DONE)  NSLog(@"Something is Wrong! %d" , type);
    sqlite3_finalize(stmt);
}

-(void) updatePassword:(NSString*)password
{
    sqlite3* database = self.SQLiteInstance;
    const char* passwordChar = [password cStringUsingEncoding:NSUTF8StringEncoding];
    
    char *sql = "update User set password = (?) WHERE id = (SELECT MIN(id) FROM User)";
    sqlite3_stmt *stmt;
    if (sqlite3_prepare_v2(database, sql, -1, &stmt, nil) == SQLITE_OK) {
        sqlite3_bind_text(stmt, 1, passwordChar, -1, NULL);
    }
    int type = sqlite3_step(stmt);
    if (type != SQLITE_DONE)  NSLog(@"Something is Wrong! %d" , type);
    sqlite3_finalize(stmt);
}


-(NSArray*) selectFirstUser {
    sqlite3* database = self.SQLiteInstance;
    
    const char *selectSql="SELECT * FROM User WHERE ID = 1";
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(database, selectSql, -1, &statement, nil)==SQLITE_OK) {
//        NSLog(@"select ok.");
    } else {
        NSLog(@"select error.");
    }
    char *username = NULL;
    char *password = NULL;
    if (sqlite3_step(statement)==SQLITE_ROW) {
//        int _id = sqlite3_column_int(statement, 0);
        username = (char *)sqlite3_column_text(statement, 1);
        password = (char*)sqlite3_column_text(statement, 2);
//        NSLog(@"row>>id %i, username %s, password %s",_id, username, password);
    }
    NSString* name = @"";
    NSString* pass = @"";
    if (username != NULL ) name = [[NSString alloc] initWithCString:username encoding:NSUTF8StringEncoding];
    if (password != NULL ) pass = [[NSString alloc] initWithCString:password encoding:NSUTF8StringEncoding];

    sqlite3_finalize(statement);
    
    return @[name,pass];
}


-(NSArray*) selectLastUser
{
    sqlite3* database = self.SQLiteInstance;
    
    const char *selectSql="SELECT * FROM User WHERE ID = (SELECT MAX(ID) FROM User)";
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(database, selectSql, -1, &statement, nil)==SQLITE_OK) {
//        NSLog(@"select ok.");
    } else {
        NSLog(@"select error.");
    }
    char *username = NULL;
    char *password = NULL;
    if (sqlite3_step(statement)==SQLITE_ROW) {
        int _id = sqlite3_column_int(statement, 0);
        username = (char *)sqlite3_column_text(statement, 1);
        password = (char*)sqlite3_column_text(statement, 2);
        NSLog(@"row>>id %i, username %s, password %s",_id, username, password);
    }
    NSString* name = @"";
    NSString* pass = @"";
    if (username != NULL ) name = [[NSString alloc] initWithCString:username encoding:NSUTF8StringEncoding];
    if (password != NULL ) pass = [[NSString alloc] initWithCString:password encoding:NSUTF8StringEncoding];
    sqlite3_finalize(statement);
    
    
    return @[name,pass];
}

-(BOOL) checkIsNoRecord
{
    sqlite3* database = self.SQLiteInstance;
    
    const char *selectSql="SELECT id FROM User WHERE ID = (SELECT MAX(ID) FROM User)";
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(database, selectSql, -1, &statement, nil)==SQLITE_OK) {
//        NSLog(@"select ok.");
    } else {
        NSLog(@"select error.");
    }
    int _id = 0;
    while (sqlite3_step(statement)==SQLITE_ROW) {
        _id = sqlite3_column_int(statement, 0);
    }
    sqlite3_finalize(statement);
    
    return _id == 0;
}

@end
