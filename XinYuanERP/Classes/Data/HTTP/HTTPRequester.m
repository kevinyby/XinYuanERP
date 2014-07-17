#import "HTTPRequester.h"
#import "AppInterface.h"

#define BINARY_LENGHT @"Binary-Length"

/**
 *    TODO :  Handle the MD5
 **/


@interface HTTPRequester ()

@property (strong) HTTPRequestBase* internalHttpRequest;

@end


@implementation HTTPRequester
{
    int binaryLength;
}

@synthesize isFailed;

@synthesize delegate;


#pragma mark - HTTPRequestDelegate Methods
-(void) didFailRequestWithError: (HTTPRequestBase*)request error:(NSError*)error {
    
    isFailed = YES;
    
    if (delegate && [delegate respondsToSelector: @selector(didFailRequestWithError:error:)]) {
        [delegate didFailRequestWithError: self error:error];
    }
}

-(void) didSucceedRequest: (HTTPRequestBase*)request response:(NSHTTPURLResponse*)response {
    
    NSDictionary* allHeaders = [response allHeaderFields];
    binaryLength = [[allHeaders objectForKey: BINARY_LENGHT] unsignedIntegerValue] ;
    
    if (delegate && [delegate respondsToSelector: @selector(didSucceedRequest:response:)]) {
        [delegate didSucceedRequest: self response:response];
    }
}

-(void) didReceivePieceData: (HTTPRequestBase*)request data:(NSData*)data {
    
    if (isFailed) return;
    
    if (delegate && [delegate respondsToSelector: @selector(didReceivePieceData:data:)]) {
        [delegate didReceivePieceData: self data:data];
    }
}

-(void) didFinishReceiveData: (HTTPRequestBase*)request data:(NSData*)data{
    
    if (isFailed) return;
    
    ResponseJsonModel* jsonModel = [ResponseJsonModel getJsonModel: data binaryLength:binaryLength] ;
    
    if (delegate && [delegate respondsToSelector:@selector(didFinishReceiveData:data:)]) {
        [delegate didFinishReceiveData: self data:jsonModel];
    }
}



#pragma mark - Public Methods

-(void) startUploadRequest:(NSString*)url parameters:(NSDictionary*)parameters completeHandler:(HTTPRequesterCompleteHandler)completeHandler {
    self.internalHttpRequest = [[HTTPUploader alloc] initWithURLString:url parameters:parameters];
    if (completeHandler) {
        [self startRequester:completeHandler];
    } else {
        [self startRequester ];
    }
}

-(void) startDownloadRequest:(NSString*)url parameters:(NSDictionary*)parameters completeHandler:(HTTPRequesterCompleteHandler)completeHandler {
    [self startPostRequest: url parameters:parameters completeHandler:completeHandler];
}

-(void) startPostRequest:(NSString*)url parameters:(NSDictionary*)parameters completeHandler:(HTTPRequesterCompleteHandler)completeHandler {
    self.internalHttpRequest = [[HTTPPostRequest alloc] initWithURLString:url parameters:parameters];
    if (completeHandler) {
        [self startRequester:completeHandler];
    } else {
        [self startRequester ];
    }
}

-(void) startGetRequest:(NSString*)url completeHandler:(HTTPRequesterCompleteHandler)completeHandler {
    self.internalHttpRequest = [[HTTPGetRequest alloc] initWithURLString:url parameters:nil];
    if (completeHandler) {
        [self startRequester:completeHandler];
    } else {
        [self startRequester ];
    }
}



#pragma mark - Java Server End
-(void) startPostRequestWithAlertTips: (RequestJsonModel*)model completeHandler:(HTTPRequesterCompleteHandler)completeHandler {
    [self startPostRequest: model completeHandler:^(HTTPRequester *requester, ResponseJsonModel *response, NSHTTPURLResponse *httpURLReqponse, NSError *error) {
        if (response.descriptions) {
            [ACTION alertMessage: [MessagesKeysHelper parseResponseDescriprions: response]];
        } else if (response.denyStatus) {
            NSString* model = [response.models firstObject];
            NSString* permission = [[response.action componentsSeparatedByString:PATH_LOGIC_CONNECTOR] lastObject];
            [ACTION alertMessage: LOCALIZE_MESSAGE_FORMAT(@"YouHaveNoPermissionToDo", LOCALIZE_KEY(model), LOCALIZE_KEY(permission))];
        } else if (error){
            [ACTION alertError: error];
        }
        if (completeHandler) completeHandler(self, response, httpURLReqponse, error);
    }];
}
-(void) startPostRequest: (RequestJsonModel*)model completeHandler:(HTTPRequesterCompleteHandler)completeHandler {
    NSString* urlString = nil;
    NSDictionary* parameters = nil;
    if ([model isKindOfClass: [RequestJsonModel class]]) {
        urlString = model.path;
        parameters = [model getJSON];
    } else if ([model isKindOfClass:[NSArray class]]) {
        NSArray* array = (NSArray*)model;
        urlString = MODEL_URL([array firstObject]);
        parameters = @{req_JSON:[CollectionHelper convertJSONObjectToJSONString: [array lastObject]]};
    }
    
    self.internalHttpRequest = [[HTTPPostRequest alloc] initWithURLString:urlString parameters:parameters];
    if (DATA.cookies)[(NSMutableURLRequest*)self.internalHttpRequest.request addValue: DATA.cookies forHTTPHeaderField:HTTP_REQ_HEADER_COOKIE];
    if (completeHandler) {
        [self startRequester:completeHandler];
    } else {
        [self startRequester ];
    }
}

-(void) cancelRequester
{
    [self.internalHttpRequest cancelRequest];
}


#pragma mark - Private Methods

// delegate  startRequest
-(void) startRequester {
    isFailed = NO;
    self.internalHttpRequest.delegate = self;
    [self.internalHttpRequest startRequest];
}

// block startRequest
-(void) startRequester:(void (^)(HTTPRequester* requester, ResponseJsonModel* model, NSHTTPURLResponse* httpURLReqponse, NSError* error) )completeHandler {
    
    isFailed = NO;
    
    [self.internalHttpRequest startRequest:^(HTTPRequestBase* httpRequest, NSURLResponse* response, NSData* data, NSError* connectionError) {
//        NSLog(@"Response Data : %@", [[NSString alloc] initWithData: data encoding:NSUTF8StringEncoding]);
        NSError* error = connectionError;
        if (! data && !error) {
            error = [NSError errorWithDomain: @"" code:400 userInfo:[NSDictionary dictionaryWithObject:@"Network Connection Error" forKey:@"ERROR"]];
        }
        
        NSHTTPURLResponse* httpURLReqponse = (NSHTTPURLResponse*) response;
        NSInteger statusCode = [httpURLReqponse statusCode];
        if ( statusCode >= 400) {
            error = [NSError errorWithDomain: @"" code:400 userInfo:[NSDictionary dictionaryWithObject:@"Server Response Error" forKey:@"ERROR"]];
        }
        
        NSDictionary* allHeaders = [httpURLReqponse allHeaderFields];
        int bytesLength = [[allHeaders objectForKey: BINARY_LENGHT] intValue] ;
        ResponseJsonModel* jsonModel = [ResponseJsonModel getJsonModel: data binaryLength: bytesLength] ;
        if (jsonModel.exception) {
            error = [NSError errorWithDomain: @"" code:400 userInfo:[NSDictionary dictionaryWithObject:LOCALIZE_MESSAGE(@"SeverParseDataError") forKey:@"ERROR"]];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completeHandler) completeHandler(self, jsonModel, httpURLReqponse, error);
        });
        
    }];
}


@end
