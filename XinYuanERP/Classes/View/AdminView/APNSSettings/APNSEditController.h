#import "BaseController.h"

#define APNSEditControllerJSONDivTag 11911
#define APNS_RESULTS_USERS @"USERS"
#define APNS_RESULTS_PARAMETERS @"PARAMETERS"


@class TableHeaderAddButtonView;


@interface APNSEditController : BaseController

@property (strong) NSString* apnsType;


@property (strong, readonly) TableHeaderAddButtonView* apnsSettingsTableView;


// Custom
@property (copy) void(^APNSDidGetDataFromServer)(APNSEditController* controller, NSDictionary* results);
@property (copy) NSMutableDictionary*(^APNSGetDataSendToServer)(APNSEditController* controller);


#pragma mark - Public Methods
-(void) setDataToViews: (NSArray*)users parameters:(NSDictionary*)parameters;
-(void) getViewsDataTo: (NSMutableDictionary*)results;


@end
