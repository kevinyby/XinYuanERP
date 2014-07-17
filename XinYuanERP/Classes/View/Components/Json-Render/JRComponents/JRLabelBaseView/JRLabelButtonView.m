#import "JRLabelButtonView.h"
#import "JRComponents.h"

#import "_View.h"

@implementation JRLabelButtonView

@synthesize button;

-(void) initializeComponents: (NSDictionary*)config
{
    [super initializeComponents: config];
    
    button = [[JRButton alloc] init];
    [button setTitle:@" " forState:UIControlStateNormal];
    [self addSubview: button];
    
}


@end
