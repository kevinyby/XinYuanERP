#import "HTTPGetRequest.h"

@implementation HTTPGetRequest

#pragma mark - Overwrite Methods
-(void) applyRequest:(NSMutableURLRequest*)request parameters:(NSDictionary*)parameters {
    [request setHTTPMethod:@"GET"];
}

-(NSURL*) getURL: (NSString*)urlString parameters:(NSDictionary*)parameters {
    NSMutableString* parameterString = [NSMutableString stringWithString: urlString];
    
    for(NSString* key in parameters) {
        NSString* value = [parameters objectForKey: key];
        
        if ([parameterString rangeOfString: @"?"].location != NSNotFound) {
            [parameterString appendFormat: @"&%@=%@", key, value];
        } else {
            [parameterString appendFormat: @"?%@=%@", key, value];
        }
    }
    
    NSString* encodeURL = [parameterString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL* url = [NSURL URLWithString: encodeURL];
    
    return url;
}

@end
