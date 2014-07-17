#import <Foundation/Foundation.h>

@interface AdministratorAction : NSObject

-(void) savePermissions: (NSString*)username permissions:(NSString*)permission categories:(NSString*)categories completeHandler:(void (^)(NSError* errorObj))completeHandler ;

-(void) saveExpiredDate: (NSString*)department order:(NSString*)order identifier:(id)identifier date:(NSDate*)date completeHandler:(void (^)(NSError* errorObj))completeHandler ;


+(void) initializeAdministrator;

@end
