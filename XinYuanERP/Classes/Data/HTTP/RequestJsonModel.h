

// --------------------------

#define DOT @"."

#define DOT_MODEL(_model) [NSString stringWithFormat: @".%@", _model]

#define DOT_CONNENT(_department, _model) [NSString stringWithFormat:@"%@%@%@", _department, DOT, _model]

#define DOT_CATEGORY_DOT_MODEL(_department, _model) [NSString stringWithFormat:@"%@%@",DOT, DOT_CONNENT(_department,_model)]

// --------------------------







// --------------------------

#define req_JSON @"JSON"

#define req_MODELS @"MODELS"
#define req_OBJECTS @"OBJECTS"

#define req_FIELDS @"FIELDS"
#define req_JOINS @"JOINS"
#define req_SORTS @"SORTS"
#define req_LIMITS @"LIMITS"

#define req_CRITERIAS @"CRITERIAS"
#define req_IDENTITYS @"IDENTITYS"
#define req_PRECONDITIONS @"PRECONDITIONS"
#define req_PARAMETERS @"PARAMETERS"

#define req_PASSWORDS @"PASSWORDS"
#define req_APNS_CONTENTS @"APNS_CONTENTS"
#define req_APNS_FORWARDS @"APNS_FORWARDS"

// --------------------------







@interface RequestJsonModel : NSObject

@property (nonatomic, strong, getter = getPath) NSString* path;       // for request , a carrier

@property (readonly) NSMutableArray* models;
@property (readonly) NSMutableArray* objects;

@property (readonly, getter = getFields) NSMutableArray* fields;
@property (readonly, getter = getJoins) NSMutableArray* joins;
@property (readonly, getter = getSorts) NSMutableArray* sorts;
@property (readonly, getter = getLimits) NSMutableArray* limits;

@property (readonly) NSMutableArray* criterias;
@property (readonly) NSMutableArray* identities;
@property (readonly) NSMutableArray* preconditions;
@property (readonly) NSMutableDictionary* parameters;

@property (readonly) NSMutableArray* passwords;
@property (readonly) NSMutableArray* apns_contents;
@property (readonly) NSMutableArray* apns_forwards;



+(RequestJsonModel*) getJsonModel ;

-(NSDictionary*)json ;

-(void) feedJSON: (NSDictionary*)json;



#pragma mark -

-(void) addModel:(id)obj ;
-(void) addModelsFromArray: (NSArray*)array;
-(void) addModels: (id)obj, ... NS_REQUIRES_NIL_TERMINATION;

-(void) addObject: (NSDictionary*)object ;
-(void) addObjectsFromArray: (NSArray*)array;
-(void) addObjects: (id)obj, ... NS_REQUIRES_NIL_TERMINATION;

@end
