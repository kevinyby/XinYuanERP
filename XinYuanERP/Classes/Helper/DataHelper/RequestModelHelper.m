#import "RequestModelHelper.h"
#import "AppInterface.h"

@implementation RequestModelHelper

+ (NSDictionary*) getModelIdentities: (id)identification
{
    NSDictionary* identities = nil;
    if ([identification isKindOfClass:[NSDictionary class]]) {         // identities (for customized)
        identities = identification;
    } else if ([identification isKindOfClass:[NSNumber class]]) {      // id (for all models)
        identities = @{PROPERTY_IDENTIFIER: identification};
    } else if ([identification isKindOfClass: [NSString class]]) {     // orderNO (for orders)
        identities = @{PROPERTY_ORDERNO : identification};
    }
    return identities;
}

+ (id) getModelIdentification: (NSDictionary*)identities
{
    id identification = identities;
    
    if (identities.count == 1) {
        
        if (identities[PROPERTY_IDENTIFIER]) {
            identification = identities[PROPERTY_IDENTIFIER];
        } else if (identities[PROPERTY_ORDERNO]) {
            identification = identities[PROPERTY_ORDERNO];
        }
        
    }
    return identification;
}


+ (NSString*)criterialBetweenDate: (NSDate*)fromDate toDate:(NSDate*)toDate
{
    NSString* fromString = [DateHelper stringFromDate: fromDate pattern:PATTERN_DATE_TIME];
    NSString* toString = [DateHelper stringFromDate: toDate pattern:PATTERN_DATE_TIME];
    return [self criterialBetween: fromString to:toString];
}


+ (NSString*)criterialBetween: (NSString*)fromString to:(NSString*)toString
{
    if(OBJECT_EMPYT(fromString)||OBJECT_EMPYT(toString)) return nil;
    return [NSString stringWithFormat:@"%@%@%@%@",CRITERIAL_BT,fromString,CRITERIAL_BTAND,toString];
}


@end
