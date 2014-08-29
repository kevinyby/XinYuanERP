#import "ResponseJsonModel.h"
#import "AppInterface.h"

@implementation ResponseJsonModel

@synthesize status;
@synthesize action;
@synthesize models;
@synthesize results;
@synthesize numbers;
@synthesize exception;
@synthesize denyStatus;
@synthesize binaryData;
@synthesize descriptions;



+(ResponseJsonModel*) getJsonModel: (NSData*)data binaryLength:(int)binaryLength {
    if (data == nil) return nil;
    return [[ResponseJsonModel alloc] initWithData: data binaryLength:binaryLength] ;
}


-(id)initWithData: (NSData*)data binaryLength:(int)binaryLength {
    self = [super init];
    
    if (self) {
        int totalLength = data.length;
        int jsonLenght = totalLength - binaryLength;
        
        
        if (binaryLength != 0) binaryData = [NSData dataWithBytes:(const void *)[data bytes] length:binaryLength] ;
        NSData* jsonData = [NSData dataWithBytesNoCopy:(void *)[data bytes] + binaryLength length:jsonLenght freeWhenDone:NO];
        
        NSError *error = nil;
//        NSString* jsonString = [[NSString alloc] initWithData: jsonData encoding:NSUTF8StringEncoding];
//        NSDictionary* dictionary = [jsonString objectFromJSONString];
        NSDictionary* dictionary = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableLeaves|NSJSONReadingAllowFragments error:&error];
        if (error) {
            binaryData = [NSData dataWithData:jsonData];
        } else {
            [self renderWithDictionary: dictionary];
        }
    }
    return self ;
}

-(id)initWithDictionary: (NSDictionary*)dictionary {
    self = [super init];
    if (self) {
        [self renderWithDictionary: dictionary];
    }
    return self;
}

-(void) renderWithDictionary: (NSDictionary*)dictionary {
    models = [dictionary objectForKey: res_MODELS];
    action = [dictionary objectForKey: res_ACTION];
    results = [dictionary objectForKey: res_RESULTS];
    exception = [dictionary objectForKey: res_EXCEPTION];
    exception = OBJECT_EMPYT(exception) ? nil : exception; // cause we need it to judge error or not.
    descriptions = [dictionary objectForKey: res_DESCRIPTIONS];
    status = [[dictionary objectForKey: res_STATUS] intValue];
    numbers = [[[dictionary objectForKey: res_NUMBERS] firstObject] intValue];
    denyStatus = [[dictionary objectForKey: res_DENYSTATUS] intValue];
}


@end
