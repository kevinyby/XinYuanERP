
#import <UIKit/UIKit.h>

@interface UIApplication (WindowOverlay)

@property (nonatomic, readonly) UIView *baseWindowView;

-(void)addWindowOverlay:(UIView *)view;

@end
