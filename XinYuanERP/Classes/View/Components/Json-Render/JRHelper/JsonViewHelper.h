#import <Foundation/Foundation.h>
#import "JRViewProtocal.h"

@class JsonView;
@class JsonDivView;
@class TextFormatter;

@class JRLabelBaseView;
@class JRLocalizeLabel;


@interface JsonViewHelper : NSObject

+(void) refreshJsonViewLocalizeText: (id<JRTopViewProtocal>)jrViewProtocal;


+(void) setLocalizeText: (NSString*)model view:(id<JRViewProtocal>)jrview;


+(void) setViewSharedAttributes: (UIView*)component config: (NSDictionary*)dictionary;


+(void) autoLocateJRLabelBaseView: (JRLabelBaseView*)jrlableview frames:(NSArray*)frames;
+(void) autoLocateJRLocalizeLabel: (JRLocalizeLabel*)jrLocalizeLabel frames:(NSArray*)frames;

#pragma mark - Label Font
+(TextFormatter*) textFormatter;
+(void) setLabelFontAttribute: (UILabel*)label config:(NSDictionary*)dictionary;

#pragma mark - Font
+(UIFont*) getFontWithConfig:(NSDictionary*)dictionary;



+(JsonView*) getJsonViewBySubview: (UIView*)subView;

@end
