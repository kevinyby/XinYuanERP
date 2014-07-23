@interface NSString (Base64)

+(NSString*) base64Encode: (NSString*)plainText;
+(NSString*) base64Decode: (NSString*)base64String;

@end
