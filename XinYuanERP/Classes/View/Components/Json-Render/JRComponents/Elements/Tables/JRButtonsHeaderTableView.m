#import "JRButtonsHeaderTableView.h"
#import "AppInterface.h"

@implementation JRButtonsHeaderTableView

@synthesize leftButton;
@synthesize rightButton;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        UIView* headerView = self.headerView;
        
        leftButton = [[JRButton alloc] init];
        rightButton = [[JRButton alloc] init];
        
        
        [headerView addSubview: leftButton];
        [headerView addSubview: rightButton];
    }
    return self;
}



@end
