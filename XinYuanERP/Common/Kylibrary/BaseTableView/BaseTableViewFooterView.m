

#import "BaseTableViewFooterView.h"


#define RGB(__R,__G,__B)		[UIColor colorWithRed:((__R)/255.0f) green:((__G)/255.0f) blue:((__B)/255.0f) alpha:1.0]
#define FOOTER_TEXT_COLOR	 RGB(171,109,17)
#define WILL_LOAD_MORE_TIP @"下拉加载更多"
#define LOADING_MORE_TIP @"正在加载..."
#define NO_MORE_TIP @""
#define XYWH(__X,__Y,__W,__H) CGRectMake(__X, __Y, __W, __H)
#define FONT(_SIZE) [UIFont systemFontOfSize:_SIZE]


@implementation BaseTableViewFooterView

@synthesize tipLabel;
@synthesize activityIndicator;
@synthesize bfDelegate;


-(id)initWithFrame:(CGRect)frame{
    if (self=[super initWithFrame:frame]) {
        
        tipLabel = [[UILabel alloc] initWithFrame:XYWH(10, 15, 300, 20)];
        tipLabel.textAlignment = UITextAlignmentCenter;
        tipLabel.text = WILL_LOAD_MORE_TIP;
        tipLabel.font = FONT(14);
        tipLabel.textColor = FOOTER_TEXT_COLOR;
        tipLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:tipLabel];
        self.backgroundColor = [UIColor clearColor];
        
        //动画
        activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:
                             UIActivityIndicatorViewStyleGray];
        activityIndicator.frame = XYWH(280, 12, 30, 30);
        [activityIndicator startAnimating];
        activityIndicator.hidesWhenStopped = YES;
        activityIndicator.backgroundColor = [UIColor clearColor];
        [self addSubview:activityIndicator];
        
        
        UITapGestureRecognizer *aKeyword = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)];
        [aKeyword setNumberOfTouchesRequired:1];
        aKeyword.cancelsTouchesInView =NO;
        aKeyword.delegate=self;
        [self addGestureRecognizer:aKeyword];
        
    }
    
    return self;
}


-(void)dealloc{
//    DO_RELEASE_SAFELY(tipLabel);
//    DO_RELEASE_SAFELY(activityIndicator);
//    
//    [super dealloc];
}

-(void)start{
    tipLabel.text = LOADING_MORE_TIP;
    [activityIndicator startAnimating];
}

-(void)stop{
    tipLabel.text = WILL_LOAD_MORE_TIP;
    [activityIndicator stopAnimating];
}

-(void)stopNoMoreData{
    tipLabel.text = NO_MORE_TIP;
    [activityIndicator stopAnimating];
}

-(void)tapAction{
    if ([bfDelegate respondsToSelector:@selector(BaseTableViewFooterViewTapAction:)]) {
        [bfDelegate performSelector:@selector(BaseTableViewFooterViewTapAction:) withObject:self];
    }
}


@end




