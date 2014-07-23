#import "HTTPUploader.h"
#import "NSString+Base64.h" // in _Base64.h Module


#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_4_3
#define RANDOM(x) arc4random_uniform(x)
#else
#define RANDOM(x) arc4random() % x
#endif


#define ASCII_Begin 33
#define ASCII_Over 126

#define BoundaryLength 30
#define Math_Random  RANDOM(10000000) * 0.0000001  // [0, 1)


@implementation HTTPUploader

/**
 *  @parameter
 *      @required content:
 *          NSData with key UPLOAD_Data
 *          NSString with key UPLOAD_FileName
 *      @optional content:
 *          NSString with key UPLOAD_MIMEType
 *          NSDictionary with key UPLOAD_FormParameters , can add html <form> </from> data in it.
 **/
-(void) applyRequest:(NSMutableURLRequest*)request parameters:(NSDictionary*)parameters {
    [request setHTTPMethod:@"POST"];
    [self setUploadData: request parameters:parameters];
}

- (NSString *)generateBoundaryString
{
    CFUUIDRef       uuid;
    CFStringRef     uuidStr;
    NSString *      result;
    
    uuid = CFUUIDCreate(NULL);
    assert(uuid != NULL);
    
    uuidStr = CFUUIDCreateString(NULL, uuid);
    assert(uuidStr != NULL);
    
    result = [NSString stringWithFormat:@"Boundary-%@", uuidStr];
    
    CFRelease(uuidStr);
    CFRelease(uuid);
    
    return result;
}

-(void) setUploadData: (NSMutableURLRequest*)request parameters:(NSDictionary*)parameters {
    //2014-07-08 modified by wudan

    assert(parameters.count > 1);
    assert(request != nil);
    
    NSString*           fileName;
    NSString*           boundaryStr;
    NSString*           contentType;
    NSString*           bodyPerfixStr;
    NSString*           bodySuffixStr;
    NSData*             uploadData;
    NSData*             extraFormData;
    unsigned long long  fileLengthNum;
    unsigned long long  bodyLength;
    
    NSDictionary* formParameters;
    
    fileName = [parameters objectForKey:UPLOAD_FileName];
    uploadData = [parameters objectForKey: UPLOAD_Data];                    // required !!
    contentType = [parameters objectForKey: UPLOAD_MIMEType];               // image/jpeg ...
    formParameters = [parameters objectForKey: UPLOAD_FormParameters];
    
    assert(fileName != nil);
    assert(uploadData != nil);
    
    boundaryStr = [self generateBoundaryString];
    assert(boundaryStr != nil);
    
    bodyPerfixStr = [NSString stringWithFormat:
                     @
                     // empty preamble
                     "\r\n"
                     "--%@\r\n"
                     "Content-Disposition: form-data; name=\"file\"; filename=\"%@\"\r\n"
                     "Content-Type: %@\r\n"
                     "\r\n",
                     boundaryStr,
                     fileName,       // +++ very broken for non-ASCII
                     contentType
                     ];
    
    assert(bodyPerfixStr != nil);
    
    bodySuffixStr = [NSString stringWithFormat:
                     @
                     "\r\n"
                     "--%@\r\n"
                     "Content-Disposition: form-data; name=\"uploadButton\"\r\n"
                     "\r\n"
                     "Upload File\r\n"
                     "--%@--\r\n"
                     "\r\n"
                     //empty epilogue
                     ,
                     boundaryStr, 
                     boundaryStr
                     ];
    
    assert(bodySuffixStr != nil);
    
    NSData* bodyPerfixData = [bodyPerfixStr dataUsingEncoding:NSISOLatin2StringEncoding];
    assert(bodyPerfixData != nil);
    NSData* bodySuffixData = [bodySuffixStr dataUsingEncoding:NSISOLatin2StringEncoding];
    assert(bodySuffixData != nil);
    // extra data might be nil
    extraFormData = [self appendParameters:formParameters boundary:boundaryStr];
    unsigned long long extraFormLength = 0;
    if (extraFormData) extraFormLength = [extraFormData length];
    
    fileLengthNum = (unsigned long long) [uploadData length];
    bodyLength =
            (unsigned long long) [bodyPerfixData length]
            + fileLengthNum
            + extraFormLength
            + (unsigned long long) [bodySuffixData length];
    
    
//    NSString* boundaryCharacters = [HTTPUploader randomCharactersByCount: BoundaryLength];
//    NSString* boundary = [NSString stringWithFormat: @"----%@", boundaryCharacters];
    
    // set header
    NSString *headerContentType = [NSString stringWithFormat: @"multipart/form-data; boundary=\"%@\"",boundaryStr];
    [request setValue: headerContentType forHTTPHeaderField:@"Content-Type"];

    [request setValue:[NSString stringWithFormat:@"%llu",(unsigned long long)777777] forHTTPHeaderField:@"Content-Length"];
    // set body
    NSMutableData* body = [NSMutableData dataWithCapacity: 0];
    
    // first , set the basic
//    [body appendData: [[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSISOLatin2StringEncoding]];
//    [body appendData:[[NSString stringWithFormat: @"Content-Disposition: form-data; name=\"file\"; filename=\"%@\"\r\n", fileName] dataUsingEncoding:NSISOLatin2StringEncoding]];
//    [body appendData: [[NSString stringWithFormat: @"Content-Type: %@\r\n\r\n", contentType] dataUsingEncoding:NSISOLatin2StringEncoding]];
//    
//    // second , set uploadData
//    [body appendData: uploadData];
//    
//    // second , set the other parameters in this post form
//    [self appendParametersTo: body parameters: formParameters boundary:boundary];
//    
//    // third , set end tails
//    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [body appendData:bodyPerfixData];
    [body appendData:uploadData];
    [body appendData:extraFormData];
    [body appendData:bodySuffixData];
    
    [request setHTTPBody: body];
}

-(NSData*) appendParameters:(NSDictionary*)parameters boundary:(NSString*)boundary {
    if (!parameters || parameters.count == 0) return nil;
    
    NSMutableString* parameterString = [NSMutableString stringWithCapacity:0];
    for(NSString* key in parameters) {
        NSString* value = parameters[key];
        [parameterString appendFormat: @"--%@\r\nname=\"%@\"\r\n\r\n%@\r\n", boundary, key, value];
    }
    NSMutableData* parametersData = [NSMutableData dataWithData: [parameterString dataUsingEncoding: NSISOLatin2StringEncoding]];
    return parametersData;
}


+(NSString*) randomCharactersByCount: (int)count {
    NSMutableString* result = [[NSMutableString alloc] initWithCapacity: count];
    
    for (int i=0; i<count; i++) {
        int randomNumber = Math_Random * (ASCII_Over - ASCII_Begin + 1) + ASCII_Begin;
        [result appendFormat: @"%c", randomNumber];
    }
    
    return [NSString base64Encode: result];
}

@end
