
#import "DOErrorView.h"
#import "CategoryAdditions.h"


static const CGFloat kVPadding1 = 30.0f;
static const CGFloat kVPadding2 = 20.0f;
static const CGFloat kHPadding  = 10.0f;
#define GRAY_COLOR				[UIColor grayColor]

@implementation DOErrorView


- (id)initWithTitle:(NSString*)title subtitle:(NSString*)subtitle image:(UIImage*)image {
    self = [self init];
    if (self) {
        self.title = title;
        self.subtitle = subtitle;
        self.image = image;
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _imageView = [[UIImageView alloc] init];
        _imageView.contentMode = UIViewContentModeCenter;
        [self addSubview:_imageView];
        
        _titleView = [[UILabel alloc] init];
        _titleView.backgroundColor = [UIColor clearColor];
        _titleView.textColor = [UIColor grayColor];
        _titleView.font = [UIFont systemFontOfSize:16];
        _titleView.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_titleView];
        
        _subtitleView = [[UILabel alloc] init];
        _subtitleView.backgroundColor = [UIColor clearColor];
        _subtitleView.textColor = [UIColor grayColor];
        _subtitleView.font = [UIFont systemFontOfSize:14];
        _subtitleView.textAlignment = NSTextAlignmentCenter;
        _subtitleView.numberOfLines = 0;
        [self addSubview:_subtitleView];
    }
    
    return self;
}

- (void)dealloc {
//    DO_RELEASE_SAFELY(_imageView);
//    DO_RELEASE_SAFELY(_titleView);
//    DO_RELEASE_SAFELY(_subtitleView);
//    
//    [super dealloc];
}




#pragma mark -
#pragma mark UIView

- (void)layoutSubviews {
    _subtitleView.size = [_subtitleView sizeThatFits:CGSizeMake(self.width - kHPadding*2, 0)];
    [_titleView sizeToFit];
    [_imageView sizeToFit];
    
    CGFloat maxHeight = _imageView.height + _titleView.height + _subtitleView.height
    + kVPadding1 + kVPadding2;
    BOOL canShowImage = _imageView.image && self.height > maxHeight;
    
    CGFloat totalHeight = 0.0f;
    
    if (canShowImage) {
        totalHeight += _imageView.height;
    }
    if (_titleView.text.length) {
        totalHeight += (totalHeight ? kVPadding1 : 0) + _titleView.height;
    }
    if (_subtitleView.text.length) {
        totalHeight += (totalHeight ? kVPadding2 : 0) + _subtitleView.height;
    }
    
    CGFloat top = floor(self.height/2 - totalHeight/2);
    
    if (canShowImage) {
        _imageView.origin = CGPointMake(floor(self.width/2 - _imageView.width/2), top);
        _imageView.hidden = NO;
        top += _imageView.height + kVPadding1;
        
    } else {
        _imageView.hidden = YES;
    }
    if (_titleView.text.length) {
        _titleView.origin = CGPointMake(floor(self.width/2 - _titleView.width/2), top);
        top += _titleView.height + kVPadding2;
    }
    if (_subtitleView.text.length) {
        _subtitleView.origin = CGPointMake(floor(self.width/2 - _subtitleView.width/2), top);
    }
}





#pragma mark -
#pragma mark Properties

- (NSString*)title {
    return _titleView.text;
}

- (void)setTitle:(NSString*)title {
    _titleView.text = title;
}

- (NSString*)subtitle {
    return _subtitleView.text;
}

- (void)setSubtitle:(NSString*)subtitle {
    _subtitleView.text = subtitle;
}

- (UIImage*)image {
    return _imageView.image;
}

- (void)setImage:(UIImage*)image {
    _imageView.image = image;
}


@end




