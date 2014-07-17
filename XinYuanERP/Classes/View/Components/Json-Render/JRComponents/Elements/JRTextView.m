#import "JRTextView.h"
#import "AppInterface.h"

@implementation JRTextView {
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


-(void) subRender: (NSDictionary*)dictionary {
    
    self.textColor = [ColorHelper parseColor: dictionary[JSON_FONT_N_COLOR]];
    
    self.font = [JsonViewHelper getFontWithConfig: dictionary];
    
    
}


-(id) getValue {
    return self.text;
}

-(void) setValue: (id)value {
    self.text = value;
}

#pragma mark -

- (id)init
{
    self = [super init];
    if (self) {
        self.font = [UIFont fontWithName:@"Arial" size:[FrameTranslater convertFontSize: 20]];
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}


@end
