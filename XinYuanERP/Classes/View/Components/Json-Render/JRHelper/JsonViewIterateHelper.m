#import "JsonViewIterateHelper.h"
#import "JRComponents.h"

@implementation JsonViewIterateHelper

// Just The Get Top Level View Value
// Just iterate the jsonview top level and nested top level, not iterate jcomplexview/jrview's subviews
+(void) iterateTopLevelJRComponentProtocal: (UIView*)superView handler:(BOOL (^)(id<JRComponentProtocal> jrProtocalView))handler
{
    for (UIView* subView in [superView subviews]) {
        if ([subView conformsToProtocol:@protocol(JRComponentProtocal)]){
            if (handler((id<JRComponentProtocal>)subView)) return;
        }
        
        else
            
        if ([subView conformsToProtocol:@protocol(JRTopViewProtocal)]) {
            [self iterateTopLevelJRComponentProtocal: [(id<JRTopViewProtocal>)subView contentView] handler:handler];
        }
    }
}

+(void) iterateJRViewProtocalDeepRecursive: (UIView*)superView handler:(BOOL (^)(id<JRViewProtocal> jrProtocalView))handler
{
    
    for (UIView* subView in [superView subviews]) {
        
        if ([subView conformsToProtocol:@protocol(JRViewProtocal)]){
            if (handler((id<JRViewProtocal>)subView)) return;
        }
        [self iterateJRViewProtocalDeepRecursive: subView handler:handler];
    }
}


#pragma mark - 

+(UIView*) getViewWithKeyPath: (NSString*)keyPath on:(UIView*)view
{
    NSArray* array = [keyPath componentsSeparatedByString:@"."];
    UIView* resultView = view;
    for (int i = 0; i < array.count; i++) {
        NSString* key = array[i];
        resultView = [JsonViewIterateHelper getJRView: resultView attribute:key];
    }
    return resultView == view ? nil : resultView;
}

+(UIView*) getJRView:(UIView*)superview attribute:(NSString*)attribute
{
    __block UIView* resultView = nil;
    [JsonViewIterateHelper iterateJRViewProtocalDeepRecursive: superview handler:^BOOL(id<JRViewProtocal> jrProtocalView) {
        if ([jrProtocalView.attribute isEqualToString: attribute]) {
            resultView = (UIView*)jrProtocalView;
            return YES;
        } else {
            return NO;
        }
    }];
    return resultView;
}

@end
