#import "JRLabelTextFieldView.h"
#import "ClassesInterface.h"


@implementation JRLabelTextFieldView

@synthesize textField;


#pragma mark - Override Methods

-(void) initializeComponents: (NSDictionary*)config
{
    [super initializeComponents: config];
    
    textField = [[JRTextField alloc] init];
    [self addSubview: textField];
}

-(id) getValue {
    return [textField getValue];
}

-(void) setValue: (id)value {
    [textField setValue: value];
}


@end
