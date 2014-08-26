#import <Foundation/Foundation.h>
#import "JsonController.h"

@class JRButton;
@protocol JRTopViewProtocal;

@interface JsonControllerHelper : NSObject


#pragma mark - JsonView Specifications and JsonController Specifications
+(NSMutableDictionary*) assembleJsonViewSpecifications: (NSString*)order;

+(NSMutableDictionary*) assembleJsonControllerSpecifications: (NSString*)order;


#pragma mark - Validate Objects
+(void) validateNotEmptyObjects: (NSArray*)attributes jsonView:(JsonView*)jsonView message:(NSString**)message;
    
+(void) validateShouldEqualsObjects: (NSArray*)attributes jsonView:(JsonView*)jsonView message:(NSString**)message;

+(void) validateFormatObjects: (NSDictionary*)attributes jsonView:(JsonView*)jsonView message:(NSString**)message;


#pragma mark - Auto Fill TextField In Create Mode
+(void) setupAutoFillComponents: (JsonView*)jsonView config:(NSDictionary*)clientConfig;



#pragma mark - Flip Page
+(void) flipPage: (JsonController*)jsonController isNextPage:(BOOL)isNexPage;





#pragma mark - Render Mode(Local Mode)/Objects(Server Response Objects)
+(void) enableDeleteButtonByCheckPermission:(JsonController*)jsonController;
+(void) enableExceptionButtonAfterFinalApprovas:(JsonController*)jsoncontroller objects:(NSDictionary*)objects;



+(void) disableReturnedButton:(JRButton*)returnButton order:(NSString*)order withObjects:(NSDictionary*)objects;

+(void) enableSubmitButtonsForApplyMode: (JsonController*)jsoncontroller withObjects:(NSDictionary*)objects order:(NSString*)order;



+(void) iterateJsonControllerSubmitButtonsConfig: (JsonController*)jsoncontroller handler:(BOOL(^)(NSString* buttonKey, JRButton* submitBTN, NSString* departmentType, NSString* orderType, NSString* sendNestedViewKey,NSString* appTo,NSString* appFrom, JsonControllerSubmitButtonType buttonType))handler;


+(void) renderControllerModeWithSpecification: (JsonController*)jsonController;


+(void) setUserInterfaceEnable: (id<JRTopViewProtocal>)jsonTopView keys:(NSArray*)keys enable:(BOOL)enable;
+(void) setUserInterfaceEnable: (UIView*)view enable:(BOOL)enable;
    


#pragma mark - Filter Upload Images Names and Datas

+(void) feedUploadAttributes: (NSMutableArray*)uploadAttributes uploadUIImges:(NSMutableArray*)uploadUIImges imagesObjects:(NSDictionary*)imagesObjects imageDatasConfig:(NSDictionary*)imageDatasConfig;


#pragma mark - Images Names and Datas

+(void) loadImagesToJsonView: (JsonController*)jsonController objects:(NSDictionary*)objects;

+(void) getImagesDatasAndPaths: (JsonController*)jsonController datas:(NSMutableArray*)datasRepository thumbnailDatas:(NSMutableArray*)thumbnailDatas paths:(NSMutableArray*)pathsRepository thumbnailPaths:(NSMutableArray*)thumbnailPaths attributes:(NSArray*)attributes uiImages:(NSArray*)uiImages;

+(NSMutableDictionary*) getImagesPathsInController: (JsonController*)jsonController;
+(NSMutableDictionary*) getImagesPathsInController: (JsonController*)jsonController attributes:(NSArray*)attributes;
+(NSString*)getImagesHomeFolder: (NSString*)order department:(NSString*)department;

#pragma mark - Util Image Name Convenience
+(id) getImageNamePathWithOrder: (NSString*)order attribute:(id)attribute jsoncontroller:(JsonController*)jsoncontroller;

#pragma mark - Util Methods


+(NSString*) getCurrentApprovingLevel:(NSString*)orderType valueObjects:(NSDictionary*)valueObjects;
+(NSString*) getCurrentHasApprovedLevel:(NSString*)orderType valueObjects:(NSDictionary*)valueObjects;


+(BOOL) isLastAppLevel: (NSString*)orderType applevel:(NSString*)applevel;
+(NSString*) getLastAppLevel:(NSString*)order;
+(NSString*) getNextAppLevel:(NSString*)applevel;
+(NSString*) getPreviousAppLevel:(NSString*)applevel;
+(BOOL) isAllApplied: (NSString*)orderType valueObjects:(NSDictionary*)valueObjects;


#pragma mark - Util Methods

+(NSMutableDictionary*) getRenderModel: (NSString*)orderType;

+(NSMutableDictionary*) differObjects:(NSDictionary*)oldObjects objects:(NSDictionary*)objects;

@end
