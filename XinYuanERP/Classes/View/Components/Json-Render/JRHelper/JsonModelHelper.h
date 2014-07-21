
@protocol JRTopViewProtocal;
@protocol JRComponentProtocal;


#define JSON_IMG_PRE @"IMG_"


@interface JsonModelHelper : NSObject



#pragma mark -------

+(void) clearModel: (UIView*)contentView;
+(void) clearModel: (UIView*)contentView keys:(NSArray*)keys;
+(void) clearModel: (UIView*)contentView exceptkeys:(NSArray*)keys;

+(NSMutableDictionary*) getModel: (UIView*)contentView;
+(NSMutableDictionary*) getImagesModels: (UIView*)contentView;

+(void) setModel: (UIView*)contentView model:(NSDictionary*)model;


+(void) renderWithObjectsKeys: (NSDictionary*)objects jrTopView:(id<JRTopViewProtocal>)jrTopView;




#pragma mark - Class Methods

+(void) iterateTopLevelJRComponentProtocalWithValue: (UIView*)contentView handler:(BOOL (^)(id<JRComponentProtocal> jrComponentProtocalView))handler;

+(void) iterateTopLevelJRComponentProtocalWithImageValue: (UIView*)contentView handler:(BOOL (^)(id<JRComponentProtocal> jrComponentProtocalView))handler;


@end
