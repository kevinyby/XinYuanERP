#import "BaseController.h"
#import "Carousel.h"


@class AppWheelViewController;

typedef void(^WheelDidTapSwipLeftAtIndexBlockk)(AppWheelViewController* wheel, NSInteger index);
typedef void(^WheelDidSwipRightAtIndexBlockk)(AppWheelViewController* wheel, UISwipeGestureRecognizer* sender);



@interface AppWheelViewController : BaseController <iCarouselDataSource, iCarouselDelegate>

@property(strong, readonly) Carousel *carousel;
@property(nonatomic,strong) NSArray* wheels;
@property(strong) NSDictionary* config;


@property(copy) WheelDidTapSwipLeftAtIndexBlockk wheelDidTapSwipLeftBlock;
@property(copy) WheelDidSwipRightAtIndexBlockk wheelDidSwipRightBlock;


@end
