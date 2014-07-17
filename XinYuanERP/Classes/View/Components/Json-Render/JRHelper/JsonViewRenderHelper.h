
@interface JsonViewRenderHelper : NSObject



+(UIView*) renderFile:(NSString*)fileName specificationsKey:(NSString*)specificationsKey;

+(UIView*) render: (NSString*)attribute specifications:(NSDictionary*)specifications;



#pragma mark -


@end
