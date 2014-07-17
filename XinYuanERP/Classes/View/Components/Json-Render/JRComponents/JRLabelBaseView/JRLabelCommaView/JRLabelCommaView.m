#import "JRLabelCommaView.h"
#import "ClassesInterface.h"

@implementation JRLabelCommaView

@synthesize commaLabel;

-(void) initializeComponents: (NSDictionary*)config
{
    [super initializeComponents: config];
    
    commaLabel = [[JRLabel alloc] init];
    commaLabel.textAlignment = NSTextAlignmentLeft;
    commaLabel.text = @":";
    
    [commaLabel setSizeHeight: [FrameTranslater convertCanvasHeight: 40]];      // default
    [commaLabel setSizeWidth: [FrameTranslater convertCanvasWidth: 12]];        // default
    commaLabel.font = [UIFont fontWithName:@"Arial" size:[FrameTranslater convertFontSize: 17]];        // default
    
    [self addSubview: commaLabel];
    
}




@end
