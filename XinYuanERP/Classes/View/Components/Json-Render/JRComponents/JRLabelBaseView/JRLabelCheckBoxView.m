#import "JRLabelCheckBoxView.h"
#import "ClassesInterface.h"



@implementation JRLabelCheckBoxView

@synthesize checkBox;


#pragma mark - Override Methods

-(void) initializeComponents: (NSDictionary*)config
{
    [super initializeComponents: config];
    
    checkBox = [[JRCheckBox alloc] init];
    [self addSubview: checkBox];
    
    
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget: self action:@selector(didTapAction:)];
    [self addGestureRecognizer: tap];
}


-(id) getValue {
    return [checkBox getValue];
}

-(void) setValue: (id)value {
    [checkBox setValue: value];
}


#pragma mark - Private Methods
-(void) didTapAction: (UITapGestureRecognizer*)tap
{
    checkBox.checked = !checkBox.checked;
}


@end
