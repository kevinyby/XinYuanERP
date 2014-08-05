//
//  KKConnectionOperation.m
//  XinYuanERP
//
//  Created by Xinyuan4 on 14-7-24.
//  Copyright (c) 2014年 Xinyuan4. All rights reserved.
//

#import "KKConnectionOperation.h"

#define TimeOutInterval  15

@interface KKConnectionOperation()

@property(nonatomic, readwrite, retain) NSURLRequest *request;
@property(nonatomic, readwrite, retain) NSMutableData* responseData;
@property(nonatomic, readwrite, retain) NSURLResponse* response;
@property(nonatomic, readwrite, retain) NSURLConnection* connection;

@property(atomic, readwrite, assign) BOOL finished;
@property(atomic, readwrite, assign) BOOL executing;

@property (readwrite, nonatomic, strong) NSError *error;

@property(nonatomic, readwrite, strong) NSRecursiveLock *lock;

/*for batchRequest*/
@property (nonatomic, strong) dispatch_queue_t completionQueue;
@property (nonatomic, strong) dispatch_group_t completionGroup;


@end

@implementation KKConnectionOperation


- (instancetype)initWithRequest:(NSURLRequest *)urlRequest {
    NSParameterAssert(urlRequest);
    
    self = [super init];
    if (!self) {
		return nil;
    }
    
    self.lock = [[NSRecursiveLock alloc] init];
    self.lock.name = @"com.kkconnection.lock";
    
    self.request = urlRequest;
    
    return self;
}

+ (void)networkRequestThreadEntryPoint:(id)__unused object {
    @autoreleasepool {
        NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
        [runLoop run];
    }
}

+ (NSThread *)networkRequestThread {
    static NSThread *_networkRequestThread = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _networkRequestThread = [[NSThread alloc] initWithTarget:self selector:@selector(networkRequestThreadEntryPoint:) object:nil];
        [_networkRequestThread start];
    });
    
    return _networkRequestThread;
}

- (void)setCompletionBlockWithSuccess:(void (^)(KKConnectionOperation* operation,NSData* responseData))success
                              failure:(void (^)(KKConnectionOperation* operation,NSError *error))failure
{
    [self.lock lock];
    __weak typeof(self) weakSelf = self;
    self.completionBlock = ^ {
        if (weakSelf.error) {
            if (failure) {
                failure(weakSelf,weakSelf.error);
                
            }
        } else {
            if (success) {
                success(weakSelf,weakSelf.responseData);
            }
        }
    };
    [self.lock unlock];
}


- (void)start
{
    [self.lock lock];
    if ([self isCancelled])
    {
        [self willChangeValueForKey:@"isFinished"];
        self.finished = YES;
        [self didChangeValueForKey:@"isFinished"];
        return;
    }
    
    [self willChangeValueForKey:@"isExecuting"];
    [self performSelector:@selector(operationDidStart) onThread:[[self class] networkRequestThread] withObject:nil waitUntilDone:NO];
    self.executing = YES;
    [self didChangeValueForKey:@"isExecuting"];
    [self.lock unlock];
}

- (void)operationDidStart
{
    [self.lock lock];
    self.connection =[[NSURLConnection alloc] initWithRequest:self.request
                                                     delegate:self
                                             startImmediately:NO];
    [self.connection scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    [self.connection start];
    [self.lock unlock];
}

- (void)operationDidFinish
{
    [self.lock lock];
    [self willChangeValueForKey:@"isFinished"];
    [self willChangeValueForKey:@"isExecuting"];
    
    self.executing = NO;
    self.finished = YES;
    
    [self didChangeValueForKey:@"isExecuting"];
    [self didChangeValueForKey:@"isFinished"];
    [self.lock unlock];
}

- (void)cancel
{
    [self.lock lock];
    [super cancel];
    if (self.connection)
    {
        [self.connection cancel];
        self.connection = nil;
    }
    
    [self.lock unlock];
}

- (BOOL)isConcurrent {
    return YES;
}

- (BOOL)isExecuting {
    return self.executing;
}

- (BOOL)isFinished {
    return self.finished;
}


#pragma mark - NSURLConnection Delegate

- (void)connection:(NSURLConnection *)aConnection didReceiveResponse:(NSURLResponse *)response
{
    self.response = response;
}

- (void)connection:(NSURLConnection *)aConnection didReceiveData:(NSData *)data
{
    [self.responseData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)aConnection
{
    NSLog(@"connectionDidFinishLoading in main thread?: %d", [NSThread isMainThread]);
    self.connection = nil;
    self.completionBlock();
    [self operationDidFinish];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    self.connection = nil;
    self.responseData = nil;
    self.error = error;
    self.completionBlock();
    [self operationDidFinish];
}

#pragma mark - BatchRequest

+ (NSArray *)batchOfRequestOperations:(NSArray *)operations
                        progressBlock:(void (^)(NSUInteger numberOfFinishedOperations, NSUInteger totalNumberOfOperations,KKConnectionOperation* operation))progressBlock
                      completionBlock:(void (^)(NSArray *operations))completionBlock
{
    if (!operations || [operations count] == 0) {
        return @[[NSBlockOperation blockOperationWithBlock:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completionBlock) {
                    completionBlock(@[]);
                }
            });
        }]];
    }
    
    __block dispatch_group_t group = dispatch_group_create();
    NSBlockOperation *batchedOperation = [NSBlockOperation blockOperationWithBlock:^{
        dispatch_group_notify(group, dispatch_get_main_queue(), ^{
            if (completionBlock) {
                completionBlock(operations);
            }
        });
    }];
    
    for (KKConnectionOperation *operation in operations) {
        operation.completionGroup = group;
        void (^originalCompletionBlock)(void) = [operation.completionBlock copy];
        __weak __typeof(operation)weakOperation = operation;
        operation.completionBlock = ^{
            __strong __typeof(weakOperation)strongOperation = weakOperation;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wgnu"
            dispatch_queue_t queue = strongOperation.completionQueue ?: dispatch_get_main_queue();
#pragma clang diagnostic pop
            dispatch_group_async(group, queue, ^{
                if (originalCompletionBlock) {
                    originalCompletionBlock();
                }
                
                NSUInteger numberOfFinishedOperations = [[operations indexesOfObjectsPassingTest:^BOOL(id op, NSUInteger __unused idx,  BOOL __unused *stop) {
                    return [op isFinished];
                }] count];
                
                if (progressBlock) {
                    progressBlock(numberOfFinishedOperations, [operations count], strongOperation);
                }
                
                dispatch_group_leave(group);
            });
        };
        
        dispatch_group_enter(group);
        [batchedOperation addDependency:operation];
    }
    
    return [operations arrayByAddingObject:batchedOperation];
}


@end
