#import "JRLabelCommaTextFieldButtonView.h"
#import "JRComponents.h"

@implementation JRLabelCommaTextFieldButtonView

@synthesize button;

-(void) initializeComponents: (NSDictionary*)config
{
    [super initializeComponents: config];
    
    button = [[JRButton alloc] init];
    [self addSubview: button];
    
    self.textField.enabled = NO;
}

@end
