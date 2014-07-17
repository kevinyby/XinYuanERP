#import "JRLabelTextAutoView.h"
#import "ClassesInterface.h"

@implementation JRLabelTextAutoView

@synthesize textField;


#pragma mark - Override Methods

-(void) initializeComponents: (NSDictionary*)config
{
    [super initializeComponents: config];
    
    textField = [[AutoCompleteTextField alloc] init];
    [self addSubview: textField];
}


-(id) getValue {
    return textField.text;
}

-(void) setValue: (id)value {
    textField.text = value;
} 

@end
