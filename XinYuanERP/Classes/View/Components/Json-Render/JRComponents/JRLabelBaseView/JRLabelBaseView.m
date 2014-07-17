#import "JRLabelBaseView.h"
#import "JRComponents.h"

@implementation JRLabelBaseView

@synthesize label;

#pragma mark - Override Methods
-(void) initializeComponents: (NSDictionary*)config
{
    [super initializeComponents: config];
    
    label = [[JRLocalizeLabel alloc] init];
    [self addSubview: label];
}

-(void) subRender: (NSDictionary*)dictionary {
    [super subRender: dictionary];
    
    label.attribute = self.attribute;       // for localize
}

-(id) getValue {
    return label.text;
}

-(void) setValue: (id)value {
    label.text = value;
}

@end
