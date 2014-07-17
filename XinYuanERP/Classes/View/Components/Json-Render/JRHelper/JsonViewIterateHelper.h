#import <Foundation/Foundation.h>

@protocol JRComponentProtocal;
@protocol JRViewProtocal;


@interface JsonViewIterateHelper : NSObject

+(void) iterateTopLevelJRComponentProtocal: (UIView*)superView handler:(BOOL (^)(id<JRComponentProtocal> jrProtocalView))handler;

+(void) iterateJRViewProtocalDeepRecursive: (UIView*)superView handler:(BOOL (^)(id<JRViewProtocal> jrProtocalView))handler;


+(UIView*) getViewWithKeyPath: (NSString*)keyPath on:(UIView*)view;

@end
