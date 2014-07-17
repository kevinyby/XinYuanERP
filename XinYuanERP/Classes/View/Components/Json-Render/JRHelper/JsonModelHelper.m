#import "JsonModelHelper.h"
#import "JRComponents.h"
#import "DictionaryHelper.h"

@implementation JsonModelHelper


#pragma mark - Class Methods

+(void) iterateTopLevelJRComponentProtocalWithValue: (UIView*)contentView handler:(BOOL (^)(id<JRComponentProtocal> jrComponentProtocalView))handler
{
    [JsonViewIterateHelper iterateTopLevelJRComponentProtocal:contentView handler:^BOOL(id<JRComponentProtocal> jrComponentProtocalView) {
        if ([jrComponentProtocalView isKindOfClass:[JRImageView class]] ) {
            if (! [jrComponentProtocalView.attribute hasPrefix:JSON_IMG_PRE]) {
                return NO;
            }
        }
        return handler(jrComponentProtocalView);
    }];
}
+(void) iterateTopLevelJRComponentProtocalWithImageValue: (UIView*)contentView handler:(BOOL (^)(id<JRComponentProtocal> jrComponentProtocalView))handler
{
    [self iterateTopLevelJRComponentProtocalWithValue: contentView handler:^BOOL(id<JRComponentProtocal> jrComponentProtocalView) {
        if ([jrComponentProtocalView isKindOfClass:[JRImageView class]] && [jrComponentProtocalView.attribute hasPrefix:JSON_IMG_PRE]) {
            return handler(jrComponentProtocalView);
        }
        return NO;
    }];
}





#pragma mark -------


+(void) clearModel: (UIView*)contentView
{
    [self iterateTopLevelJRComponentProtocalWithValue: contentView handler:^BOOL(id<JRComponentProtocal> jrComponentProtocalView) {
        [jrComponentProtocalView setValue: nil];
        return NO;
    }];
}

+(void) clearModel: (UIView*)contentView keys:(NSArray*)keys
{
    if (! keys.count) return;
    [self iterateTopLevelJRComponentProtocalWithValue: contentView handler:^BOOL(id<JRComponentProtocal> jrProtocalView) {
        if ([keys containsObject:[jrProtocalView attribute]]) [jrProtocalView setValue: nil];
        return NO;
    }];
}
+(void) clearModel: (UIView*)contentView exceptkeys:(NSArray*)keys
{
    [self iterateTopLevelJRComponentProtocalWithValue: contentView handler:^BOOL(id<JRComponentProtocal> jrProtocalView) {
        if (! [keys containsObject:[jrProtocalView attribute]]) [jrProtocalView setValue: nil];
        return NO;
    }];
}


+(NSMutableDictionary*) getModel: (UIView*)contentView
{
    NSMutableDictionary* model = [NSMutableDictionary dictionary];
    [self iterateTopLevelJRComponentProtocalWithValue: contentView handler:^BOOL(id<JRComponentProtocal> jrComponentProtocalView) {
        id value = [jrComponentProtocalView getValue];
        NSString* key = jrComponentProtocalView.attribute;
        if (value && key) [model setObject: value forKey: key];
        return NO;
    }];
    return model;
}

+(NSMutableDictionary*) getImagesModels: (UIView*)contentView
{
    NSMutableDictionary* model = [NSMutableDictionary dictionary];
    [self iterateTopLevelJRComponentProtocalWithImageValue: contentView handler:^BOOL(id<JRComponentProtocal> jrComponentProtocalView) {
       
        id value = [jrComponentProtocalView getValue];
        NSString* key = jrComponentProtocalView.attribute;
        if (value && key) {
            [model setObject: value forKey: key];
        }
        
        return NO;
    }];
    return model;
}



+(void) setModel: (UIView*)contentView model:(NSDictionary*)model
{
    if (! model.count) return;
    [self iterateTopLevelJRComponentProtocalWithValue:contentView handler:^BOOL(id<JRComponentProtocal> jrComponentProtocalView) {
        
        NSString* attribute = jrComponentProtocalView.attribute;
        id value = [model objectForKey: attribute];
        
        if (value) {
            if (value == [NSNull null]) {
                value = nil;
            }
            [jrComponentProtocalView setValue: value];
        }
        
        return NO;
    }];
}


+(void) renderWithObjectsKeys: (NSDictionary*)objects jrTopView:(id<JRTopViewProtocal>)jrTopView
{
    for (NSString* key in objects) {
        id value = [objects objectForKey: key];
        id<JRComponentProtocal> jrComponentProtocalView = (id<JRComponentProtocal>)[jrTopView getView: key];
        
        if (value) {
            if (value == [NSNull null]) {
                value = nil;
            }
            [jrComponentProtocalView setValue: value];
        }
    }
}



@end
