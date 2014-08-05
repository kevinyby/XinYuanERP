#import "BaseController.h"

#define APNSEditControllerJSONDivTag 11911
#define APNS_RESULTS_USERS @"USERS"
#define APNS_RESULTS_PARAMETERS @"PARAMETERS"


@class TableHeaderAddButtonView;


@interface GeneralEditController : BaseController

@property (strong) NSString* apnsType;


@property (strong, readonly) TableHeaderAddButtonView* apnsSettingsTableView;


// Custom
@property (copy) void(^APNSDidGetDataFromServerAction)(GeneralEditController* controller, NSDictionary* results);
@property (copy) NSMutableDictionary*(^APNSGetDataSendToServerAction)(GeneralEditController* controller);


#pragma mark - Public Methods
-(void) initializeTableHeaderAddButtonView;


-(void) setDataToViews: (NSArray*)users parameters:(NSDictionary*)parameters;
-(void) getViewsDataTo: (NSMutableDictionary*)results;



@end
