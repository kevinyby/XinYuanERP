#import "JRImageLabelCommaTextView.h"
#import "ClassesInterface.h"

@implementation JRImageLabelCommaTextView

@synthesize imageView;

-(void)initializeComponents:(NSDictionary *)config
{
    [super initializeComponents: config];
    
    imageView = [[JRImageView alloc] init];
    self.backgroundColor = [UIColor clearColor];
    
    [self insertSubview: imageView atIndex:0 ];
}

@end
