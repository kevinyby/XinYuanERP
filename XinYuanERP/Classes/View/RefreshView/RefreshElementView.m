#import "RefreshElementView.h"

#import "_View.h"
#import "FrameTranslater.h"

#import "UILabel+AdjustWidth.h"

@implementation RefreshElementView

@synthesize label;
@synthesize indicator;


- (id)initWithText:(NSString*)text
{
    self = [super init];
    if (self) {
        label = [[UILabel alloc] initWithText:text];
        indicator = [[UIActivityIndicatorView alloc]  init];
        indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
        [self addSubview: label];
        [self addSubview: indicator];
        
        [label setTranslatesAutoresizingMaskIntoConstraints:NO];
        [indicator setTranslatesAutoresizingMaskIntoConstraints:NO];
        
        [self addConstraints:[NSLayoutConstraint
                              constraintsWithVisualFormat:@"|-0-[indicator][label]-0-|"
                              options:NSLayoutFormatDirectionLeadingToTrailing
                              metrics:nil
                              views:NSDictionaryOfVariableBindings(indicator,label)]];
        
        [self addConstraints:[NSLayoutConstraint
                              constraintsWithVisualFormat:@"V:|-0-[indicator]-0-|"
                              options:NSLayoutFormatDirectionLeadingToTrailing
                              metrics:nil
                              views:NSDictionaryOfVariableBindings(indicator)]];
        [self addConstraints:[NSLayoutConstraint
                              constraintsWithVisualFormat:@"V:|-0-[label]-0-|"
                              options:NSLayoutFormatDirectionLeadingToTrailing
                              metrics:nil
                              views:NSDictionaryOfVariableBindings(label)]];
        
        label.font = [UIFont systemFontOfSize: [FrameTranslater convertFontSize: 20]];
        
        self.state = RefreshElementStateNull;
    }
    return self;
}

-(void)setState:(RefreshElementState)state
{
    self.hidden = NO;
    switch (state) {
        case RefreshElementStateNull:
            self.hidden = YES;
            break;
        
        case RefreshElementStateNormal:
			[self.indicator stopAnimating];
            break;
            
        case RefreshElementStatePulling:
            break;
            
        case RefreshElementStateLoading:
			[self.indicator startAnimating];
            break;
            
        default:
            break;
    }
    _state = state;
}


@end
