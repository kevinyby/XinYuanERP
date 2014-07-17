#import "JRLocalizeLabel.h"
#import "AppInterface.h"

@interface JRLocalizeLabel()

@property (strong) CMPopTipView* popTipView;
@property (strong) NSString* descriptioinKey;
@end

@implementation JRLocalizeLabel
{
    UITapGestureRecognizer* tapGestureRecognizer;
    
}

#pragma mark - Override Methods

-(id) getValue {
    return nil;
}

-(void) setValue: (id)value {
}


-(void)subRender:(NSDictionary *)dictionary
{
    [super subRender:dictionary];
    
    
    if (dictionary[JSON_DESCRIPTION_KEY]) {
        self.descriptioinKey = dictionary[JSON_DESCRIPTION_KEY];
        
        self.jrLocalizeLabelDidClickAction = ^void(JRLocalizeLabel* label) {
            CMPopTipView* popTipView = label.popTipView;
            if (!popTipView) {
                popTipView = [[CMPopTipView alloc] initWithMessage: LOCALIZE_DESCRIPTION(label.descriptioinKey)];
                popTipView.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.3];
            }
            popTipView.animation = arc4random() % 2;
            [popTipView presentPointingAtView:label inView:[ViewHelper getTopView] animated:YES];
        };
    }
}

-(void)setJrLocalizeLabelDidClickAction:(void (^)(JRLocalizeLabel *))jrLocalizeLabelDidClickAction
{
    _jrLocalizeLabelDidClickAction = jrLocalizeLabelDidClickAction;
    if (jrLocalizeLabelDidClickAction) {
        self.userInteractionEnabled = YES;
        if (!tapGestureRecognizer) {
            tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget: self action:@selector(tapLabelAction:)];
        }
        [self addGestureRecognizer: tapGestureRecognizer];
    }
}


#pragma mark - Show Descriptions
-(void) tapLabelAction: (UITapGestureRecognizer *)tapGesture {
    if (self.jrLocalizeLabelDidClickAction) {
        self.jrLocalizeLabelDidClickAction(self);
    }
}


@end
