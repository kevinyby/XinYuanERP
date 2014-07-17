#import "JsonViewRenderHelper.h"

#import "JRComponents.h"
#import "ClassesInterface.h"    


@implementation JsonViewRenderHelper

+(UIView*) renderFile:(NSString*)fileName specificationsKey:(NSString*)specificationsKey
{
    NSDictionary* allSpecificationInFile = [JsonFileManager getJsonFromFile: fileName];
    return [JsonViewRenderHelper render: specificationsKey specifications: allSpecificationInFile[specificationsKey]];
}

+(UIView*) render: (NSString*)attribute specifications:(NSDictionary*)specifications
{
    // A . One Way
    UIView* view = [self renderOneComponent:specifications attribute:attribute];
    UIView* contentView = view;
    
    // if conform JRTopViewProtocal
    if ([view conformsToProtocol:@protocol(JRTopViewProtocal)]) {
        id<JRTopViewProtocal> jrViewProtocal = (id<JRTopViewProtocal>)view;
        jrViewProtocal.specifications = specifications;
        contentView = jrViewProtocal.contentView;
        if (contentView != view) {
            contentView.frame = view.bounds;
        }
    }
    
    [self renderComponentsWithSortedKeys:specifications parentView:contentView];
    
    // B . If conform JRTopViewProtocal
    if ([view conformsToProtocol:@protocol(JRTopViewProtocal)]) {
        id<JRTopViewProtocal> jrViewProtocal = (id<JRTopViewProtocal>)view;
        [JsonViewHelper refreshJsonViewLocalizeText: jrViewProtocal];
        [JRTextFieldHelper setTextFieldDelegateAdjustKeyboard: jrViewProtocal];
    }
    
    // The Other Way : Top view is JsonView
    //    JsonView* jsonview = (JsonView*)[self renderConponentsInBreadth: specifications key:model];
    
    return view;
}



#pragma mark -
// {     "SORTEDKEYS":["BG_book"],  "COMPONENTS": {"BG_book":{...} }     }
+(void) renderComponentsWithSortedKeys: (NSDictionary*)specification parentView:(UIView*)parentView
{
    NSDictionary* componentsSpecification = [specification objectForKey: JSON_COMPONENTS];
    if (! [componentsSpecification isKindOfClass:[NSDictionary class]]) return;
    NSArray* rangedKeys = [ArrayHelper reRangeContents: [componentsSpecification allKeys] frontContents:specification[JSON_SORTEDKEYS]];
    NSArray* components = [self doRendersRecursive: componentsSpecification keys: rangedKeys];
    
    for (int i = 0; i < components.count; i++) {
        [parentView addSubview: components[i]];
    }
}

+(NSArray*) doRendersRecursive: (NSDictionary*)dictionary keys:(NSArray*)keys
{
    int count = keys.count;
    NSMutableArray* views = [NSMutableArray arrayWithCapacity:count];
    for (int i = 0; i < count; i++) {
        NSString* key = [keys objectAtIndex: i];
        NSDictionary* specification = dictionary[key];
        
        if(! [self isConformToSpecification: specification key:key]) continue;
        UIView* component = [self renderOneComponent:specification attribute:key];
        
        // recursive do the render again
        [self renderComponentsWithSortedKeys:specification parentView:component];
        
        [views addObject: component];
    }
    return views;
}

// {"JCom":"JRLabel", ...}
+(UIView*) renderOneComponent: (NSDictionary*)specification attribute:(NSString*)attribute
{
    if (!specification) return nil;
    UIView* component = nil;
    
    // alloc component
    NSString* classString = [specification objectForKey: JSON_JCOM];
    if (!classString) classString = JSON_DIVVIEW;
    classString = [classString stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];
    component = [[NSClassFromString(classString) alloc] init];
    
    
    if (!component) {
        [ACTION alertWarning: [NSString stringWithFormat:@"%@ %@ %@", classString, @" Component Class Not Found For Key ", attribute ]];
        return nil;
    }
    
    // if conform JRViewProtocal
    if ([component conformsToProtocol:@protocol(JRViewProtocal)]) {
        id<JRViewProtocal> jrViewProtocal = (id<JRViewProtocal>)component;
        jrViewProtocal.attribute = attribute;
    }
    // if conform JRComponentProtocal
    if ([component conformsToProtocol:@protocol(JRComponentProtocal)]){
        id<JRComponentProtocal> jrProtocal = (id<JRComponentProtocal>)component;
        [jrProtocal initializeComponents: nil];                                         // TO BE EXTENDED
        [jrProtocal subRender: [specification objectForKey: JSON_SubRender]];
    }
    
    // set frame
    NSArray* frame = [specification objectForKey: JSON_FRAME];
    [FrameHelper setComponentFrame: frame component:component];
    
    
    // set border/radius/background
    [JsonViewHelper setViewSharedAttributes: component config:specification];
    
    return component;
}

+(BOOL) isConformToSpecification: (NSDictionary*)specification key:(NSString*)key
{
    if ([key hasSuffix:@"_" ] || [key hasPrefix: @"_"]) return NO ;          // for writer's convenient
    
    if (! [specification isKindOfClass: [NSDictionary class]]) return NO;    // for combination convenient: in share.json you have "Footer":{}, you want to delete "Footer" , just "Footer":""
    
    return YES;
}









#pragma mark -  /////////////////////////////// Tail Recursion //////////////////////

+(UIView*) renderConponentsInBreadth: (NSDictionary*)specification key:(NSString*)key
{
    NSMutableArray* repositories = [NSMutableArray array];
    UIView* component = [JsonViewRenderHelper renderOneComponent: specification attribute:key];
    [self fillRepositories: repositories component:component specification:specification];
    [self renderInBreadthRecursive: repositories];
    return component;
}
+(void) renderInBreadthRecursive: (NSMutableArray*)repositories
{
    NSArray* copies = [NSArray arrayWithArray: repositories];
    [repositories removeAllObjects];
    
    for (NSArray* array in copies) {
        UIView* parentView = [array firstObject];
        NSArray* keys = [array safeObjectAtIndex: 1];
        NSDictionary* dictionary = [array lastObject];
        
        for (int i = 0; i < keys.count; i++) {
            NSString* key = [keys objectAtIndex: i];
            NSDictionary* specification = dictionary[key];
            
            if(! [self isConformToSpecification: specification key:key]) continue;
            UIView* component = [self renderOneComponent: specification attribute:key];
            
            [self fillRepositories: repositories component:component specification:specification];
            
            // cause jsonview is zoomablescrollview
            if ([parentView isKindOfClass: [JsonView class]]) {
                [((JsonView*)parentView) addSubviewToContentView: component];
            } else {
                [parentView addSubview: component];
            }
        }
    }
    
    if (repositories.count) [self renderInBreadthRecursive: repositories];
}
+(void) fillRepositories: (NSMutableArray*)repositories component:(UIView*)component specification:(NSDictionary*)specification
{
    NSDictionary* jsonComponents = specification[JSON_COMPONENTS];
    NSArray* keys = [ArrayHelper reRangeContents: [jsonComponents allKeys] frontContents:specification[JSON_SORTEDKEYS]];
    if (component && jsonComponents) [repositories addObject: @[component, keys, jsonComponents]];
}


@end
