#import "JRLabel.h"
#import "ClassesInterface.h"

@implementation JRLabel
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


-(void) subRender: (NSDictionary*)dictionary {
    [JsonViewHelper setLabelFontAttribute: self config:dictionary];
    
    // for text alignment
    self.cnSpace = [dictionary objectForKey: JSON_CHWORD_SPACE];
    self.enSpace = [dictionary objectForKey: JSON_ENWORD_SPACE] ;
    self.isReserveCenter = [[dictionary objectForKey: JSON_RESERVECENTER] boolValue];
    
    if (dictionary[JSON_HIDDEN]) self.hidden = [dictionary[JSON_HIDDEN] boolValue];
}


-(id) getValue {
    return self.text;
}

-(void) setValue: (id)value {
    NSString* text = value;
    if ([value isKindOfClass:[NSNumber class]] ) {
        text = [value stringValue];
    }
    self.text = text;
}


#pragma mark - Override Methods
// Add animation when set text
-(void)setText:(NSString *)text
{
    // Add transition (must be called after myLabel has been displayed)
    // http://stackoverflow.com/a/6267259/1749293
    CATransition *animation = [CATransition animation];
    animation.duration = 0.5;
    animation.type = kCATransitionFromTop;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [self.layer addAnimation:animation forKey:@"changeTextTransition"];
    
    [super setText: text];
}

@end
