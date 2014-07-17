#import "RefreshTopView.h"
#import <QuartzCore/QuartzCore.h>
#import "_View.h"


#define FLIP_ANIMATION_DURATION 0.18f


@interface RefreshTopView()

@property (strong) CALayer* arrowLayer;

@end


@implementation RefreshTopView

-(void)setFrame:(CGRect)frame
{
    [super setFrame: frame];
    
    float w = [FrameTranslater convertCanvasHeight: _arrowImage.size.width];
    _arrowLayer.frame = CGRectMake(0, 0, w, frame.size.height);
}

-(void)setArrowImage:(UIImage *)arrowImage
{
    _arrowImage = arrowImage;
    _arrowLayer = [CALayer layer];
    _arrowLayer.contentsGravity = kCAGravityResizeAspect;
    _arrowLayer.contents = (id)arrowImage.CGImage;
    [[self layer] addSublayer:_arrowLayer];
}


-(void)setState:(RefreshElementState)state
{
    NSString* labelText = self.refreshTopViewLabelTextForStateAction ? self.refreshTopViewLabelTextForStateAction(state) : nil;
    switch (state) {
        
        case RefreshElementStateNormal:
        
            if (super.state == RefreshElementStatePulling) {
                [CATransaction begin];
                [CATransaction setAnimationDuration:FLIP_ANIMATION_DURATION];
                _arrowLayer.transform = CATransform3DIdentity;
                [CATransaction commit];
            }
            
            self.label.text = labelText ? labelText : NSLocalizedString(@"Pull down to refresh...", @"Pulling Down status");
            
            [CATransaction begin];
            [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
            _arrowLayer.hidden = NO;
            _arrowLayer.transform = CATransform3DIdentity;
            [CATransaction commit];
        
        break;
        
        
        case RefreshElementStatePulling:
        
            self.label.text = labelText ? labelText : NSLocalizedString(@"Release to refresh...", @"Wating Release status");
            
            [CATransaction begin];
            [CATransaction setAnimationDuration:FLIP_ANIMATION_DURATION];
            _arrowLayer.transform = CATransform3DMakeRotation((M_PI / 180.0) * 180.0f, 0.0f, 0.0f, 1.0f);
            [CATransaction commit];
        
        break;
        
        
        case RefreshElementStateLoading:
        
            self.label.text = labelText ? labelText : NSLocalizedString(@"Loading...", @"Loading Status");
            
            [CATransaction begin];
            [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
            _arrowLayer.hidden = YES;
            [CATransaction commit];
        
        break;
        
        
        default:
        
        break;
    }
    
    super.state = state;
}

@end
