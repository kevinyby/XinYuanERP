#import "HTTPRequester.h"


@interface HTTPBatchRequester : HTTPRequester

// Choose one of the two : delegate or completeHandler

+(void) startBatchDownloadRequest: (NSArray*)models url:(NSString*)url identifications:(NSArray*)identifications delegate:(id<HTTPRequesterDelegate>)delegate completeHandler:(HTTPRequesterCompleteHandler)completeHandler;

+(void) startBatchUploadRequest: (NSArray*)models url:(NSString*)url identifications:(NSArray*)identifications delegate:(id<HTTPRequesterDelegate>)delegate completeHandler:(HTTPRequesterCompleteHandler)completeHandler;

+(void) startBatchGetRequest: (NSArray*)urls identifications:(NSArray*)identifications delegate:(id<HTTPRequesterDelegate>)delegate completeHandler:(HTTPRequesterCompleteHandler)completeHandler;

@end
