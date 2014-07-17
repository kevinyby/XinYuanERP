#import "RefreshBottomView.h"


@implementation RefreshBottomView

-(void)setState:(RefreshElementState)state
{
    switch (state) {

        case RefreshElementStatePulling:
            [self.indicator startAnimating];
            break;
        default:
            break;
    }
    
    super.state = state;
}


@end
