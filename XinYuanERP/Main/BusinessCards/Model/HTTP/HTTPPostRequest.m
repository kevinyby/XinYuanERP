#import "HTTPPostRequest.h"

@implementation HTTPPostRequest

#pragma mark - Overwrite Methods
-(void) applyRequest:(NSMutableURLRequest*)request parameters:(NSDictionary*)parameters {
    NSMutableData* requestData = [NSMutableData data];
    
    NSDictionary* formParameters = [parameters objectForKey: POST_FormParameters];
    NSData* postNSData = [parameters objectForKey: POST_Data];
    
    if (! formParameters && ! postNSData) formParameters = parameters;          // if no POST_Data & POST_FormParameters specified , regard it as  formParameters;
    
    if (formParameters) {
        
        NSMutableString* parameterString = [NSMutableString stringWithCapacity:0];
        
        BOOL andFlag = NO;
        for(NSString* key in formParameters) {
            NSString* value = [formParameters objectForKey: key];
            if(!andFlag) {
                [parameterString appendFormat: @"%@=%@", key, value];
                andFlag = YES;
            } else {
                [parameterString appendFormat: @"&%@=%@", key, value];
            }
        }
        
        [requestData appendData: [parameterString dataUsingEncoding: NSUTF8StringEncoding]];
        [request setValue: @"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    }
    
    if (postNSData) [requestData appendData: postNSData];
    
    
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody: requestData];
}

@end
