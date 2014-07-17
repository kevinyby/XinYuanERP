#import "JRLabelCommaTextView.h"
#import "JRComponents.h"

@implementation JRLabelCommaTextView

@synthesize textView;

-(void) initializeComponents: (NSDictionary*)config
{
    [super initializeComponents: config];
    
    textView = [[JRTextView alloc] init];
    [self addSubview: textView];
}

-(id) getValue {
    return textView.text;
}

-(void) setValue: (id)value {
    textView.text = value;
}


@end
