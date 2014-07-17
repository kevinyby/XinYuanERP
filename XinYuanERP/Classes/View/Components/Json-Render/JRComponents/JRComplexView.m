#import "JRComplexView.h"
#import "AppInterface.h"

@implementation JRComplexView


id getJRComplexViewValue (id self, SEL _cmd)
{
    NSString* result = @"";
    BOOL isAllEmpty = YES;
    
    JRComplexView* complexView = self;
    NSArray* subViews = complexView.subviews;
    for (int i = 0; i < subViews.count; i++) {
        UIView* view = subViews[i];
        if ([view conformsToProtocol:@protocol(JRComponentProtocal)]) {
            id<JRComponentProtocal> jrView = (id<JRComponentProtocal>)view;
            id value = [jrView getValue];
            if (OBJECT_EMPYT(value)) {
                value = @"";
            } else {
                isAllEmpty = NO;
            }
            if (i == 0) {
                result = value;
            } else {
                result = [result stringByAppendingFormat:@"%@%@",DOT, value];
            }
        }
    }
    return isAllEmpty ? nil : result;
}


void setJRComplexViewValue (id self, SEL _cmd, id value)
{
    NSArray* elements = [value componentsSeparatedByString:DOT];
    JRComplexView* complexView = self;
    NSArray* subViews = complexView.subviews;
    for (int i = 0; i < subViews.count; i++) {
        UIView* view = subViews[i];
        if ([view conformsToProtocol:@protocol(JRComponentProtocal)]) {
            id<JRComponentProtocal> jrView = (id<JRComponentProtocal>)view;
            
            id obj = [elements safeObjectAtIndex: i];
            [jrView setValue: obj];
        }
    }
}

//+(void) registerInformationJsonDivViewEvent: (JsonDivView*)infoJsonDivView
//{
//    // urgency complex view
//    JRComplexView* urgencyComplexView = (JRComplexView*)[infoJsonDivView getView: @"TEST_COMPLEX_VIEW"];
//    Method originGetMethod = class_getInstanceMethod([urgencyComplexView class], @selector(getValue));
//    Method originSetMethod = class_getInstanceMethod([urgencyComplexView class], @selector(setValue:));
//
//    IMP originGetMethodIMP = method_getImplementation(originGetMethod);
//    IMP originSetMethodIMP = method_getImplementation(originSetMethod);
//
//    // replace
//    class_replaceMethod([urgencyComplexView class], @selector(getValue), (IMP)getJRComplexViewValue, method_getTypeEncoding(originGetMethod));
//    class_replaceMethod([urgencyComplexView class], @selector(setValue:), (IMP)setJRComplexViewValue, method_getTypeEncoding(originSetMethod));
//
//    Method newGetMethod = class_getInstanceMethod([urgencyComplexView class], @selector(getValue));
//    Method newSetMethod = class_getInstanceMethod([urgencyComplexView class], @selector(setValue:));
//
//    IMP newGetMethodIMP = method_getImplementation(newGetMethod);
//    IMP newSetMethodIMP = method_getImplementation(newSetMethod);
//
//    // replace back
//    class_replaceMethod([urgencyComplexView class], @selector(getValue), (IMP)originGetMethodIMP, method_getTypeEncoding(originGetMethod));
//    class_replaceMethod([urgencyComplexView class], @selector(setValue:), (IMP)originSetMethodIMP, method_getTypeEncoding(originSetMethod));
//}

#pragma mark - JRComponentProtocal Methods

-(id) getValue {
    id result = nil;
    if (self.getJRComplexViewValueBlock) result = self.getJRComplexViewValueBlock(self);
    return result;
}

-(void) setValue: (id)value {
    if (self.setJRComplexViewValueBlock) self.setJRComplexViewValueBlock(self, value);
}

-(void)subRender:(NSDictionary *)dictionary
{
    [super subRender: dictionary];
    
    if ([dictionary[k_JR_DISABLE_DEFAULTVALUES] boolValue]) return;
        
    // set the default , if u want to nil or other implementation, replace it
    self.getJRComplexViewValueBlock = ^id(JRComplexView* complexView) {
        return getJRComplexViewValue(complexView, nil);
    };
    self.setJRComplexViewValueBlock = ^void(JRComplexView* complexView, id value) {
        setJRComplexViewValue(complexView, nil, value);
    };
}


#pragma mark - Public Methods
-(UIView*) getView: (NSString*)key
{
    return [JsonViewIterateHelper getViewWithKeyPath: key on:self];
}

@end
