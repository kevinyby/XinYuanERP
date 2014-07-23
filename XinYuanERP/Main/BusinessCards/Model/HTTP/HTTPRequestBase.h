/*
 *
 * A wrapper of HTTP Post Request
 * When initial , URL String and parameters(can be null) is needed
 * Delegate is needed if you need the response header and data .
 *
 */

#define HTTP_RES_HEADER_COOKIE @"Set-Cookie"
#define HTTP_REQ_HEADER_COOKIE @"cookie"

#import <Foundation/Foundation.h>

@protocol HTTPRequestDelegate;

@interface HTTPRequestBase : NSObject <NSURLConnectionDataDelegate>

@property (weak) id<HTTPRequestDelegate> delegate;

@property (strong) NSString* identification ;
@property (readonly) NSURLRequest* request;


// initial methods
-(id) initWithURLString: (NSString*)urlString parameters:(NSDictionary*)parameters ;

-(id)initWithURLString: (NSString*)urlString parameters:(NSDictionary*)parameters timeoutInterval:(NSTimeInterval)timeoutInterval ;



-(void) startRequest ;
-(void) cancelRequest ;
-(void) startRequest: (void (^)(HTTPRequestBase* httpRequest, NSURLResponse* response, NSData* data, NSError* connectionError))completeHandler ;

-(void) startAsynchronousRequest: (void (^)(NSURLResponse* response, NSData* data, NSError* connectionError))completeHandler ;



#pragma mark - SubClass Overwrite Methods
-(void) applyRequest:(NSMutableURLRequest*)request parameters:(NSDictionary*)parameters;

@end



/**
 *
 *   HTTPRequestDelegate
 *
 */

@protocol HTTPRequestDelegate <NSObject>

@optional

-(void) didFailRequestWithError: (HTTPRequestBase*)request error:(NSError*)error ;
-(void) didSucceedRequest: (HTTPRequestBase*)request response:(NSHTTPURLResponse*)response;
-(void) didReceivePieceData: (HTTPRequestBase*)request data:(NSData*)data ;
-(void) didFinishReceiveData: (HTTPRequestBase*)request data:(NSData*)data;

@end
