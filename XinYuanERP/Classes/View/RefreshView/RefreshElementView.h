#import <UIKit/UIKit.h>


typedef enum {
    RefreshElementStateNull,
    RefreshElementStateNormal,
    RefreshElementStatePulling,
    RefreshElementStateLoading,
} RefreshElementState;

// Base class for RefreshTopView , RefreshBottomView
@interface RefreshElementView : UIView

@property (strong) UILabel* label;
@property (strong) UIActivityIndicatorView* indicator;


@property (nonatomic, assign) RefreshElementState state;


- (id)initWithText:(NSString*)text;

@end
