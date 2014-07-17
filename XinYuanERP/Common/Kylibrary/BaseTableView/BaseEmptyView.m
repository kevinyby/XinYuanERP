

#import "BaseEmptyView.h"

@implementation BaseEmptyView

@synthesize textLabel;

-(void)initView{
    textLabel = [[UILabel alloc] init];
    textLabel.text = @"数据为空";
    textLabel.backgroundColor = [UIColor clearColor];
    textLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    textLabel.textAlignment = UITextAlignmentCenter;
    textLabel.font = [UIFont systemFontOfSize:14];
    textLabel.textColor = [UIColor grayColor];
    [self addSubview:textLabel];
}

-(id)initWithCoder:(NSCoder *)aDecoder{
    if (self=[super initWithCoder:aDecoder]) {
        
        [self initView];
    }
    return self;
}


-(id)initWithFrame:(CGRect)frame{
    if (self=[super initWithFrame:frame]) {
        [self initView];
        
    }
    
    return self;
}


-(void)dealloc{
//    DO_RELEASE_SAFELY(textLabel);
//    [super dealloc];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    textLabel.frame = CGRectMake(0, self.frame.size.height/2-10, 320, 20);
    
}



@end
