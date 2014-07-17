#import "JRBaseView.h"
#import "ClassesInterface.h"


@implementation JRBaseView
{
    NSString* _attribute ;
}

-(NSString*) attribute
{
    return _attribute;
}

-(void) setAttribute: (NSString*)attribute
{
    _attribute = attribute;
}

#pragma mark - JRComponentProtocal Methods
-(void) initializeComponents: (NSDictionary*)config
{
}

-(void) subRender: (NSDictionary*)dictionary {
    NSArray* subRenders = [dictionary objectForKey: k_SubRenders];
    NSArray* frames = [dictionary objectForKey: k_Frames];
    
    int count = [[self subviews] count];
    for (int i = 0; i < count; i++) {
        UIView* component = [[self subviews] objectAtIndex: i];
        
        if ([component conformsToProtocol:@protocol(JRComponentProtocal)]) {
            id<JRComponentProtocal> jrView = (id<JRComponentProtocal>) component;
            NSDictionary* subRenderJson = [subRenders safeObjectAtIndex: i];
            [JsonViewHelper setViewSharedAttributes: component config:subRenderJson];
            [jrView subRender: subRenderJson];
        }
        
        NSArray* frame = [frames safeObjectAtIndex: i];
        [FrameHelper setComponentFrame: frame component:component];
    }
}

-(id) getValue {
    return nil;
}

-(void) setValue: (id)value {
}


@end
