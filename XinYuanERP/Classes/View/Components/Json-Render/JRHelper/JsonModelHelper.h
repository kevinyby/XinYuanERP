
@protocol JRTopViewProtocal;

#define JSON_IMG_PRE @"IMG_"

@interface JsonModelHelper : NSObject

#pragma mark - Class Methods

+(void) clearModel: (UIView*)contentView;
+(void) clearModel: (UIView*)contentView keys:(NSArray*)keys;
+(void) clearModel: (UIView*)contentView exceptkeys:(NSArray*)keys;

+(NSMutableDictionary*) getModel: (UIView*)contentView;
+(NSMutableDictionary*) getImagesModels: (UIView*)contentView;

+(void) setModel: (UIView*)contentView model:(NSDictionary*)model;


+(void) renderWithObjectsKeys: (NSDictionary*)objects jrTopView:(id<JRTopViewProtocal>)jrTopView;


@end
