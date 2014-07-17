#import <Foundation/Foundation.h>
#import "HTTPRequestBase.h"

@class RequestJsonModel;
@class ResponseJsonModel;
@class HTTPRequester;


typedef void (^HTTPRequesterCompleteHandler)(HTTPRequester* requester, ResponseJsonModel* response, NSHTTPURLResponse* httpURLReqponse, NSError* error);

@protocol HTTPRequesterDelegate <NSObject>

-(void) didFinishReceiveData: (HTTPRequester*)request data:(ResponseJsonModel*)data;
-(void) didFailRequestWithError: (HTTPRequester*)request error:(NSError*)error ;

@optional
-(void) didSucceedRequest: (HTTPRequester*)request response:(NSHTTPURLResponse*)response;
-(void) didReceivePieceData: (HTTPRequester*)request data:(NSData*)data ;


@end


@interface HTTPRequester : NSObject <HTTPRequestDelegate>

@property (assign, readonly) BOOL isFailed;

@property (strong) id<HTTPRequesterDelegate> delegate;
@property (strong) id identification;

/**
 @param parameters
 key @"UPLOAD_Data"                 for data to upload          (NSData)
 key @"UPLOAD_FileName"             for FileName and FilePath   (NSString)
 key @"UPLOAD_MIMEType"             for Mime Type               (NSString)
 key @"UPLOAD_FormParameters"       for Form(<form>) Parameters (NSDictionary)
 */
-(void) startUploadRequest:(NSString*)url parameters:(NSDictionary*)parameters completeHandler:(HTTPRequesterCompleteHandler)completeHandler ;

-(void) startDownloadRequest:(NSString*)url parameters:(NSDictionary*)parameters completeHandler:(HTTPRequesterCompleteHandler)completeHandler ;

-(void) startPostRequest:(NSString*)url parameters:(NSDictionary*)parameters completeHandler:(HTTPRequesterCompleteHandler)completeHandler ;

-(void) startGetRequest:(NSString*)url completeHandler:(HTTPRequesterCompleteHandler)completeHandler ;



#pragma mark - Java Server End
-(void) startPostRequestWithAlertTips: (RequestJsonModel*)model completeHandler:(HTTPRequesterCompleteHandler)completeHandler ;
-(void) startPostRequest: (RequestJsonModel*)model completeHandler:(HTTPRequesterCompleteHandler)completeHandler ;

-(void) cancelRequester;



@end


