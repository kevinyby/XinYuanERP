#import "HTTPBatchRequester.h"
#import "ClassesInterface.h"

@interface BatchOperation : NSBlockOperation

@property (assign, readonly)  BOOL executing;
@property (assign, readonly)  BOOL finished;

@end


@implementation BatchOperation

@synthesize executing;
@synthesize finished;

-(BOOL)isConcurrent {
    return YES;
}

-(BOOL)isExecuting {
    return executing;
}

-(BOOL)isFinished {
    return finished;
}

- (void)finish
{
    [self willChangeValueForKey:@"isExecuting"];
    [self willChangeValueForKey:@"isFinished"];
    
    executing = NO;
    finished = YES;
    
    [self didChangeValueForKey:@"isExecuting"];
    [self didChangeValueForKey:@"isFinished"];
}


@end










@interface HTTPBatchRequester ()

@property (assign) BatchOperation* batchOperation;

@end

@implementation HTTPBatchRequester

#pragma mark - Override Super's HTTPRequestDelegate Methods

-(void) didFailRequestWithError: (HTTPRequestBase*)request error:(NSError*)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        [super didFailRequestWithError:request error:error];
    });
    
    [self.batchOperation finish];
    self.batchOperation = nil;
}

-(void) didSucceedRequest: (HTTPRequestBase*)request response:(NSHTTPURLResponse*)response {
    dispatch_async(dispatch_get_main_queue(), ^{
        [super didSucceedRequest: request response:response];
    });
}

-(void) didReceivePieceData: (HTTPRequestBase*)request data:(NSData*)data {
    dispatch_async(dispatch_get_main_queue(), ^{
        [super didReceivePieceData:request data:data];
    });
}

-(void) didFinishReceiveData: (HTTPRequestBase*)request data:(NSData*)data{
    dispatch_async(dispatch_get_main_queue(), ^{
        [super didFinishReceiveData: request data:data];
    });
    [self.batchOperation finish];
    self.batchOperation = nil;
}

#pragma mark - Override Super's Public Methods
-(void) cancelRequester
{
    [super cancelRequester];
    
    [self.batchOperation finish];
    [self.batchOperation cancel];
    self.batchOperation = nil;
}



#pragma mark - NetWork Methods

+(void) startBatchDownloadRequest: (NSArray*)parameters url:(NSString*)url identifications:(NSArray*)identifications delegate:(id<HTTPRequesterDelegate>)delegate completeHandler:(HTTPRequesterCompleteHandler)completeHandler
{
    BatchOperation* operation = [[BatchOperation alloc] init];
    NSArray* requesters = [self obtainRequesters: operation count:parameters.count identifications:identifications delegate:delegate];
    
    NSOperationQueue* operationQueue = [[NSOperationQueue alloc] init];
    [operationQueue setMaxConcurrentOperationCount: 3];
    [operation addExecutionBlock:^{
        NSRunLoop* loop = [NSRunLoop currentRunLoop];
        for (int i = 0; i < parameters.count; i++) {
            NSDictionary* parameter = [parameters objectAtIndex: i];
            HTTPBatchRequester* batchRequester = [requesters objectAtIndex: i];
            [batchRequester startDownloadRequest:url parameters:parameter completeHandler:completeHandler];
        }
        [loop run];
    }];
    [operationQueue addOperation: operation];
    
}


+(void) startBatchUploadRequest: (NSArray*)models url:(NSString*)url identifications:(NSArray*)identifications delegate:(id<HTTPRequesterDelegate>)delegate completeHandler:(HTTPRequesterCompleteHandler)completeHandler
{
    if ([models count] == 0)  return;
    
    BatchOperation* operation = [[BatchOperation alloc] init];
    NSArray* requesters = [self obtainRequesters: operation count:models.count identifications:identifications delegate:delegate];
    
    NSOperationQueue* operationQueue = [[NSOperationQueue alloc] init];
    [operationQueue setMaxConcurrentOperationCount: 3];
    [operation addExecutionBlock:^{
        NSRunLoop* loop = [NSRunLoop currentRunLoop];
        for (int i = 0; i < models.count; i++) {
            NSDictionary* model = [models objectAtIndex: i];
            HTTPBatchRequester* batchRequester = [requesters objectAtIndex: i];
            [batchRequester startUploadRequest: url parameters:model completeHandler:completeHandler];
        }
        [loop run];
    }];
    [operationQueue addOperation: operation];

}


+(void) startBatchGetRequest: (NSArray*)urls identifications:(NSArray*)identifications delegate:(id<HTTPRequesterDelegate>)delegate completeHandler:(HTTPRequesterCompleteHandler)completeHandler
{
    BatchOperation* operation = [[BatchOperation alloc] init];
    NSArray* requesters = [self obtainRequesters: operation count:urls.count identifications:identifications delegate:delegate];
    
    NSOperationQueue* operationQueue = [[NSOperationQueue alloc] init];
    [operationQueue setMaxConcurrentOperationCount: 3];
    [operation addExecutionBlock:^{
        NSRunLoop* loop = [NSRunLoop currentRunLoop];
        for (int i = 0; i < urls.count; i++) {
            NSString* url = [urls objectAtIndex: i];
            HTTPBatchRequester* batchRequester = [requesters objectAtIndex: i];
            [batchRequester startGetRequest: url completeHandler:completeHandler];
        }
        [loop run];
    }];
    [operationQueue addOperation: operation];
    
}



#pragma mark - Private Methods

+(NSArray*) obtainRequesters: (BatchOperation*)operation count:(int)count identifications:(NSArray*)identifications delegate:(id<HTTPRequesterDelegate>)delegate
{
    NSMutableArray* requests = [NSMutableArray array];
    for (int i = 0; i < count; i++) {
        HTTPBatchRequester* batchRequester = [[HTTPBatchRequester alloc] init];
        id identification = [identifications objectAtIndex:i ];
        batchRequester.delegate = delegate;
        batchRequester.identification = identification;
        batchRequester.batchOperation = operation;
        [requests addObject: batchRequester];
    }
    return requests;
}

@end