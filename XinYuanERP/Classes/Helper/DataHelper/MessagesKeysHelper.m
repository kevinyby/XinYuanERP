#import "MessagesKeysHelper.h"
#import "AppInterface.h"

@implementation MessagesKeysHelper

// against to server
#define M_DEFAULT @"M_DEFAULT"
#define M_CONNECTOR @","
#define M_FORMATTER @"%@"



#define DUPLICATE_ENTRY @"Duplicate entry"


+(NSString*) parseResponseDescriprions: (ResponseJsonModel*)response
{
    NSString* localizemessage = nil;
    NSString* descriptions = response.descriptions;
    
    // if is the auto exception ...
    NSRange duplicateEntryRange = [descriptions rangeOfString: DUPLICATE_ENTRY];
    NSUInteger duplicateLength = duplicateEntryRange.length;
    NSUInteger duplicateLocation = duplicateEntryRange.location;
    if (duplicateLocation != NSNotFound) {
        NSRange forKeyRange = [descriptions rangeOfString:@"for key"];
        NSString* value = [descriptions substringWithRange:(NSRange){duplicateLocation + duplicateLength, forKeyRange.location - duplicateLocation - duplicateLength}];
        localizemessage = LOCALIZE_MESSAGE_FORMAT(MESSAGE_DuplicateEntry, value);
    
    } else {
        // if not the auto exception ...
        if ([descriptions rangeOfString:M_DEFAULT].location != NSNotFound ||
            [descriptions rangeOfString:M_CONNECTOR].location != NSNotFound ||
            [descriptions rangeOfString:M_FORMATTER].location != NSNotFound)
        {
            localizemessage = descriptions;
            
            if ([descriptions rangeOfString:M_DEFAULT].location != NSNotFound){
                localizemessage = [localizemessage stringByReplacingOccurrencesOfString:M_DEFAULT withString: [self getDefaultMessage:response]];
            }
            
            if ([descriptions rangeOfString:M_CONNECTOR].location != NSNotFound) {
                NSArray* array = [descriptions componentsSeparatedByString:M_CONNECTOR];
                for (NSUInteger i = 0; i < array.count; i++) {
                    NSString* key = array[i];
                    if ([M_DEFAULT isEqualToString: key]) continue;
                    
                    localizemessage = [localizemessage stringByReplacingOccurrencesOfString: key withString: APPLOCALIZE(key)];
                }
            }
            
        // else not formatter
        } else {
            localizemessage = APPLOCALIZE(descriptions);
        }
    }
    
    return localizemessage;
}

+(NSString*) getDefaultMessage: (ResponseJsonModel*)response
{
    NSString* model = [response.models firstObject];
    NSString* action = response.action;
    NSArray* interfaces = [action componentsSeparatedByString:PATH_LOGIC_CONNECTOR];
    if (interfaces.count) {
        NSString* method = [interfaces lastObject];
        return [LOCALIZE_KEY(method) stringByAppendingFormat:@" %@ %@", LOCALIZE_KEY(model), response.status ? LOCALIZE_KEY(@"success"):LOCALIZE_KEY(@"failed")];
    }
    return nil;
}

@end
