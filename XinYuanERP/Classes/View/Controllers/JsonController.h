#import "BaseController.h"
#import "JsonControllerSepcification.h"

@class JsonView;
@class JsonDivView;
@class RequestJsonModel;
@class ResponseJsonModel;

@interface JsonController : BaseController

@property (strong) NSString* order;                     // order , model
@property (strong) NSString* department;                // department or category

@property (strong) NSMutableDictionary* specifications;
@property (assign, nonatomic) JsonControllerMode controlMode;

@property (strong) id identification;                   // current model id, for read next/pre page
@property (strong) NSMutableDictionary* valueObjects;          // current model value objects.


-(id) initWithOrder: (NSString*)order department:(NSString*)department;

-(JsonView*) jsonView;
-(BOOL) viewWillAppearShouldRequestServer;


-(void) setupClientEvents;
-(void) setupServerEvents;


#pragma mark - SubClass Optional Override Methods
#pragma mark - read
-(RequestJsonModel*) assembleReadRequest:(NSDictionary*)objects;    // Before send request to get data
-(NSMutableDictionary*) assembleReadResponse: (ResponseJsonModel*)response;     // Done get data
-(void) enableViewsWithReceiveObjects: (NSMutableDictionary*)objects;
-(void) translateReceiveObjects: (NSMutableDictionary*)objects;     // Before the data set to jsonview
-(void) renderWithReceiveObjects: (NSMutableDictionary*)objects;   // do the render
-(void) didRenderWithReceiveObjects: (NSMutableDictionary*)objects; // here , load the images



#pragma mark - create / update
-(NSMutableDictionary*) assembleSendObjects: (NSString*)divViewKey;

-(BOOL) validateSendObjects: (NSMutableDictionary*)objects order:(NSString*)order;// in Create, check the object
-(void) translateSendObjects: (NSMutableDictionary*)objects order:(NSString*)order; // in Create, translate the object

-(RequestJsonModel*) assembleSendRequest: (NSMutableDictionary*)withoutImagesObjects order:(NSString*)order department:(NSString*)department;

-(void) didSuccessSendObjects: (NSMutableDictionary*)objects response:(ResponseJsonModel*)response; // here , send the images
-(void) didFailedSendObjects: (NSMutableDictionary*)objects response:(ResponseJsonModel*)response;



#pragma mark - apply

-(NSString*) getFowardUserForFinalApplyOrder: (NSString*)orderType valueObjects:(NSDictionary*)valueObjects appTo:(NSString*)appTo;

-(void) assembleWillApplyObjects: (NSString*)applevel order:(NSString*)order valueObjects:(NSDictionary*)valueObjects divKey:(NSString*)divKey isNeedRequest:(BOOL*)isNeedRequest objects:(NSDictionary**)objects identities:(NSDictionary**)identities; // -- will apply ... get apply objects , if isNeedRequest == YES and identities != nil, will send request


-(void) didSuccessApplyOrder: (NSString*)orderType appFrom:(NSString*)appFrom appTo:(NSString*)appTo divViewKey:(NSString*)divViewKey forwarduser:(NSString*)forwardUser;

-(void) didFailedApplyOrder: (NSString*)orderType appFrom:(NSString*)appFrom appTo:(NSString*)appTo divViewKey:(NSString*)divViewKey;



@end





