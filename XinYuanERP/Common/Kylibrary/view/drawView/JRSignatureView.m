#import "JRSignatureView.h"
#import "AppInterface.h"

@implementation JRSignatureView

{
    NSString* _attribute ;
}

#pragma mark - JRComponentProtocal Methods
-(void) initializeComponents: (NSDictionary*)config
{
}

-(NSString*) attribute
{
    return _attribute;
}

-(void) setAttribute: (NSString*)attribute
{
    _attribute = attribute;
}

-(void) subRender: (NSDictionary*)dictionary
{
    if (dictionary[k_JR_GLCOLOR]) {
        NSArray* colors = dictionary[k_JR_GLCOLOR];
        float red = 0.0, green = 0.0, blue = 0.0 ,alpha = 1.0;
        [ColorHelper parseColor: colors red:&red green:&green blue:&blue alpha:&alpha];
        self.color = GLKVector4Make(red, green,  blue, alpha);
    }
}

-(id) getValue {
    return nil;
}

-(void) setValue: (id)value {
}


@end
