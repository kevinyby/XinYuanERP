#import "JRButtonBaseView.h"

#import "JRComponents.h"

@implementation JRButtonBaseView

@synthesize button;

-(void) initializeComponents: (NSDictionary*)config
{
    [super initializeComponents: config];
    
    button = [[JRButton alloc] init];
    [self addSubview: button];
}

-(void) subRender: (NSDictionary*)dictionary {
    [super subRender: dictionary];
    
    button.attribute = self.attribute;
}

@end
