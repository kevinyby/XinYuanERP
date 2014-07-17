#import <Foundation/Foundation.h>


#define res_STATUS @"status"
#define res_ACTION @"action"
#define res_MODELS @"models"
#define res_RESULTS @"results"
#define res_NUMBERS @"numbers"
#define res_EXCEPTION @"exception"
#define res_DENYSTATUS @"denyStatus"
#define res_DESCRIPTIONS @"descriptions"


@interface ResponseJsonModel : NSObject


@property (readonly) id results ;            // may be NSArray or NSDictionary
@property (readonly) NSArray* models;
@property (readonly) NSString* action;
@property (readonly) NSData* binaryData;        // such image download
@property (assign, readonly) int status;
@property (assign, readonly) int numbers;
@property (readonly) NSString* exception;
@property (readonly) NSString* descriptions;
@property (assign, readonly) int denyStatus;



+(ResponseJsonModel*) getJsonModel: (NSData*)data binaryLength:(int)binaryLength ;

@end
