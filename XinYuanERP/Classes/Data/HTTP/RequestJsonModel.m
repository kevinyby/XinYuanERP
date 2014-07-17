#import "RequestJsonModel.h"
#import "AppInterface.h"    

@implementation RequestJsonModel
{
    NSMutableDictionary* contents;
}

@synthesize path;


@synthesize models;
@synthesize objects;

@synthesize joins;
@synthesize sorts;
@synthesize fields;
@synthesize limits;

@synthesize criterias;
@synthesize identities;
@synthesize preconditions;
@synthesize parameters;

@synthesize passwords;
@synthesize apns_contents;
@synthesize apns_forwards;


+(RequestJsonModel*) getJsonModel {
    return [[RequestJsonModel alloc] init];
}

-(NSDictionary*) getJSON {
    // make sure the models.count == objects.count
    int diffMO = models.count - objects.count;
    for (int i = 0; i < diffMO; i++) [self addObject: [NSDictionary dictionary]];
    
    // make sure critial.count == models.count
    if (criterias.count != 0) {
        int diff = models.count - criterias.count;
        for (int i = 0; i < diff ; i++) [self.criterias addObject: @{}];
    }
    
    // make sure limits.count == models.count
    if (limits.count != 0) {
        int diff = models.count - limits.count;
        for (int i = 0; i < diff ; i++) [self.limits addObject: @[]];
    }
    
    // make sure limits.count == models.count
    if (sorts.count != 0) {
        int diff = models.count - sorts.count;
        for (int i = 0; i < diff ; i++) [self.sorts addObject: @[]];
    }
    
#ifdef DEBUG
    NSString* jsonStrings = [CollectionHelper convertJSONObjectToJSONString: contents compress: NO];
#else
    NSString* jsonStrings = [CollectionHelper convertJSONObjectToJSONString: contents];
#endif
    
    return [NSDictionary dictionaryWithObject:jsonStrings forKey:req_JSON];
}


- (id)init
{
    self = [super init];
    if (self) {
        // self
        contents = [NSMutableDictionary dictionaryWithCapacity: 0];
        
        // contents
        models = [NSMutableArray arrayWithCapacity: 0];
        objects = [NSMutableArray arrayWithCapacity: 0];
        [contents setObject: models forKey:req_MODELS];
        [contents setObject: objects forKey:req_OBJECTS];
    }
    return self;
}


// --
-(void) addModel:(id)obj {
    if (!obj) return;
    id newObj = DOT_MODEL(obj);
    [models addObject: newObj];
}
-(void) addModelsFromArray: (NSArray*)array
{
    for (int i = 0; i < array.count; i++) {
        id obj = array[i];
        [self addModel: obj];
    }
}
-(void) addModels: (id)obj, ... {
    [self addModel: obj];
    
    va_list params;
    va_start(params, obj);
    id arg = nil;
    while ((arg = va_arg(params, id))) {        // use nil to teminate the loop
        [self addModel: arg];
    }
    va_end(params);
}


// --
-(void) addObject: (NSDictionary*)obj {
    if (!obj) return;
    [objects addObject: obj];
}
-(void) addObjectsFromArray: (NSArray*)array
{
    for (int i = 0; i < array.count; i++) {
        NSDictionary* obj = array[i];
        [self addObject: obj];
    }
}
-(void) addObjects: (id)obj, ... {
    [self addObject:obj];
    
    va_list params;
    va_start(params, obj);
    id arg = nil;
    while ((arg = va_arg(params, id))) {
        [self addObject: arg];
    }
    va_end(params);
}



#pragma mark - Private Override Methods

-(NSString*) getPath {
    return MODEL_URL(path);
}

-(NSMutableArray*) getFields {
    if (! [contents objectForKey: req_FIELDS]) {
        fields = [NSMutableArray arrayWithCapacity: 0];
        [contents setObject: fields forKey:req_FIELDS];
    }
    return fields;
}

-(NSMutableArray*) getJoins {
    if (! [contents objectForKey: req_JOINS]) {
        joins = [NSMutableArray arrayWithCapacity: 0];
        [joins addObject: [NSDictionary dictionary]];
        [contents setObject: joins forKey:req_JOINS];
    }
    return joins;
}

-(NSMutableArray*) getSorts {
    if (! [contents objectForKey: req_SORTS]) {
        sorts = [NSMutableArray arrayWithCapacity: 0];
        [contents setObject: sorts forKey:req_SORTS];
    }
    return sorts;
}

-(NSMutableArray*) getLimits {
    if (! [contents objectForKey: req_LIMITS]) {
        limits = [NSMutableArray arrayWithCapacity: 0];
        [contents setObject: limits forKey:req_LIMITS];
    }
    return limits;
}

-(NSMutableArray*) criterias {
    if (! [contents objectForKey: req_CRITERIAS]) {
        criterias = [NSMutableArray arrayWithCapacity: 0];
        [contents setObject: criterias forKey:req_CRITERIAS];
    }
    return criterias;
}

-(NSMutableArray*) identities {
    if (! [contents objectForKey: req_IDENTITYS]) {
        identities = [NSMutableArray arrayWithCapacity: 0];
        [contents setObject: identities forKey:req_IDENTITYS];
    }
    return identities;
}

-(NSMutableArray*) preconditions {
    if (! [contents objectForKey: req_PRECONDITIONS]) {
        preconditions = [NSMutableArray arrayWithCapacity: 0];
        [contents setObject: preconditions forKey:req_PRECONDITIONS];
    }
    return preconditions;
}

-(NSMutableDictionary*) parameters {
    if (! [contents objectForKey: req_PARAMETERS]) {
        parameters = [NSMutableDictionary dictionaryWithCapacity: 0];
        [contents setObject: parameters forKey:req_PARAMETERS];
    }
    return parameters;
}

-(NSMutableArray*) passwords {
    if (! [contents objectForKey: req_PASSWORDS]) {
        passwords = [NSMutableArray arrayWithCapacity: 0];
        [contents setObject: passwords forKey:req_PASSWORDS];
    }
    return passwords;
}

-(NSMutableArray*) apns_contents {
    if (! [contents objectForKey: req_APNS_CONTENTS]) {
        apns_contents = [NSMutableArray arrayWithCapacity: 0];
        [contents setObject: apns_contents forKey:req_APNS_CONTENTS];
    }
    return apns_contents;
}

-(NSMutableArray*) apns_forwards {
    if (! [contents objectForKey: req_APNS_FORWARDS]) {
        apns_forwards = [NSMutableArray arrayWithCapacity: 0];
        [contents setObject: apns_forwards forKey:req_APNS_FORWARDS];
    }
    return apns_forwards;
}


@end
