#import "ComponentHelper.h"
#import "AppInterface.h"

@implementation ComponentHelper

+(UIButton*) createButton: (int)tag title:(NSString*)title target:(id)target action:(SEL)action canvas:(CGRect)canvas
{
    UIButton* button = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? [UIButton buttonWithType: UIButtonTypeDetailDisclosure] : [[UIButton alloc] init];
    button.tag = tag;
    [button setTitle: title forState: UIControlStateNormal];
    [button setTitleColor: BLUE_COLOR forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize: [FrameTranslater convertFontSize: 20]];
    [button addTarget: target action: action forControlEvents: UIControlEventTouchUpInside];
    [FrameHelper setFrame: canvas view:button];
    return button;
}


@end
