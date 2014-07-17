#import <Foundation/Foundation.h>


@class JsonView;
@class JRButton;
@class JRTextField;
@class JsonController;
@class JRImageView;

@interface JRComponentHelper : NSObject


+(JRButton*) getJRButton:(UIView*)buttonView;
+(JRTextField*) getJRTextField: (UIView*)view;

#pragma mark -Toogle Buttons
+(void) setupToggleButtons: (JsonView*)jsonView components:(NSArray*)components;

#pragma mark -QR Code
+(void) setupQRCodeComponents: (JsonView*)jsonView components:(NSArray*)components;

#pragma mark - Photo
+(void) setupPhotoPickerComponents: (JsonView*)jsonview config:(NSDictionary*)config;

+(void) setupPhotoPickerWithInteractivView:(JRButton*)button completeHandler:(void(^)(UIImagePickerController* controller, UIImage* image))completeHandler;

+(void) setupPreviewImageComponents: (JsonController*)jsoncontroller config:(NSDictionary*)config;

+ (void) previewImagesWithBrowseImageView: (JRImageView*)jrimageView config:(NSDictionary*)config;

#pragma mark - Signature
+(void) setupSignaturePicker: (JsonView*)jsonView config:(NSDictionary*)config;
    



#pragma mark - Date

+(void) setupDatePickerComponents: (JsonView*)jsonview pickers:(NSArray*)pickers patterns:(NSDictionary*)patterns;

+(void) showDatePicker: (UIView*)obj;

+(void) tranlateDateComponentToSend: (JsonView*)jsonview patterns:(NSDictionary*)patterns objects:(NSMutableDictionary*)objects;

+(void) translateNumberToName:(NSMutableDictionary*)objects attributes:(NSArray*)attributes;
+(void) tranlateDateComponentToVisual:(NSMutableDictionary*)objects patterns:(NSDictionary*)patterns;




#pragma mark - Pop Signature View
+(void) popSignatureView: (UIImageView*)containerImageView;




#pragma mark - About Name Number Class Mthods
+(NSString*) getNameByNumber: (NSString*)type number:(NSString*)number;
+(NSString*) getConnectedNameNumber: (NSString*)type number:(NSString*)number;
+(NSString*) getNumberInConnectNameNumber: (NSString*)connectNameNumber;

#pragma mark -
+(NSString*) getJRAttributePathLastKey:(NSString*) attribute;
+(BOOL) isJRAttributesTheSame: (NSString*)attribute with:(NSString*)contrastAttribute;

@end
