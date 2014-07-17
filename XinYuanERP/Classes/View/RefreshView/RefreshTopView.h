#import <UIKit/UIKit.h>
#import "RefreshElementView.h"

@interface RefreshTopView : RefreshElementView

@property (nonatomic, strong) UIImage* arrowImage;

@property (copy) NSString* (^refreshTopViewLabelTextForStateAction)(RefreshElementState state);

@end
