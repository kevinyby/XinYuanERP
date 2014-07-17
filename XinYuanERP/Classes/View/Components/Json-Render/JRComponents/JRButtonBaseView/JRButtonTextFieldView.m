#import "JRButtonTextFieldView.h"
#import "JRComponents.h"

@implementation JRButtonTextFieldView

@synthesize textField;

-(void) initializeComponents: (NSDictionary*)config
{
    [super initializeComponents: config];
    
    textField = [[JRTextField alloc] init];
    [self addSubview: textField];
    
    textField.enabled = NO;
}

-(id) getValue {
    return [textField getValue];
}

-(void) setValue: (id)value {
    [textField setValue: value];
}

@end
