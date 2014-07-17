#import <Foundation/Foundation.h>

#define ACTION [ActionManager getInstance]

@class AdministratorAction;

@interface ActionManager : NSObject

@property (strong) AdministratorAction* adminAction;

+(ActionManager*) getInstance ;

-(void) initialiazeAdministerProcedure ;
-(void) destroyReleaseableProcedure ;


-(void) alertError: (id)message ;
-(void) alertWarning: (NSString*)message ;
-(void) alertMessage: (NSString*)message ;

@end
