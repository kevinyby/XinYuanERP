
#import "DAPagesContainerTopBar.h"
#import "Utility.h"


@interface DAPagesContainerTopBar ()

@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) NSArray *itemViews;

- (void)layoutItemViews;

@end


@implementation DAPagesContainerTopBar

CGFloat const DAPagesContainerTopBarItemViewWidth = 10.;
CGFloat const DAPagesContainerTopBarItemsOffset = 30.;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.scrollView.showsHorizontalScrollIndicator = NO;
        [self addSubview:self.scrollView];
        self.font = [UIFont systemFontOfSize:14];
    }
    return self;
}

#pragma mark - Public

- (CGPoint)centerForSelectedItemAtIndex:(NSUInteger)index
{
    CGPoint center = ((UIView *)self.itemViews[index]).center;
    CGPoint offset = [self contentOffsetForSelectedItemAtIndex:index];
    center.x -= offset.x - (CGRectGetMinX(self.scrollView.frame));
    return center;
}

- (CGPoint)contentOffsetForSelectedItemAtIndex:(NSUInteger)index
{
    if (self.itemViews.count < index || self.itemViews.count == 1) {
        return CGPointZero;
    } else {
        CGFloat totalOffset = self.scrollView.contentSize.width - CGRectGetWidth(self.scrollView.frame);
        return CGPointMake(index * totalOffset / (self.itemViews.count - 1), 0.);
    }
}

#pragma mark * Overwritten setters

- (void)setItemTitles:(NSArray *)itemTitles withImageArray:(NSArray*)itemImage
{
    if (_itemTitles != itemTitles) {
        _itemTitles = itemTitles;
        NSMutableArray *mutableItemViews = [NSMutableArray arrayWithCapacity:itemTitles.count];
        for (NSUInteger i = 0; i < itemTitles.count; i++) {
            UIButton *itemView = [self addItemViewWithDic:[itemImage objectAtIndex:i]];
            [itemView setTitle:itemTitles[i] forState:UIControlStateNormal];
            [mutableItemViews addObject:itemView];
        }
        self.itemViews = [NSArray arrayWithArray:mutableItemViews];
        [self layoutItemViews];
    }
}

- (void)setFont:(UIFont *)font
{
    if (![_font isEqual:font]) {
        _font = font;
        for (UIButton *itemView in self.itemViews) {
            [itemView.titleLabel setFont:font];
        }
    }
}

#pragma mark - Private
- (UIButton *)addItemViewWithDic:(NSDictionary*)dic
{
    UIImage* normalImg = [dic objectForKey: @"buttonNormalImage"];
//    UIImage* onImage = [dic objectForKey: @"buttonSelectedImage"];
  
//    CGRect frame = CGRectMake(0., 0., DAPagesContainerTopBarItemViewWidth, CGRectGetHeight(self.frame));
    CGRect frame = CGRectMake(0., 0., normalImg.size.width, normalImg.size.height);
    UIButton *itemView = [[UIButton alloc] init];
    [itemView setBackgroundImage:normalImg forState:UIControlStateNormal];
    [itemView setBackgroundImage:normalImg forState:UIControlStateSelected];
    [itemView setBackgroundImage:normalImg forState:UIControlStateHighlighted];
    [itemView addTarget:self action:@selector(itemViewTapped:) forControlEvents:UIControlEventTouchUpInside];
    itemView.titleLabel.font = self.font;
    [itemView setTitleColor:[UIColor colorWithWhite:0.6 alpha:1.] forState:UIControlStateNormal];
    
    [Utility parent:self.scrollView add:itemView rect:frame];
    
//    [self.scrollView addSubview:itemView];
    return itemView;
}


- (void)itemViewTapped:(UIButton *)sender
{

    [self.delegate itemAtIndex:[self.itemViews indexOfObject:sender] didSelectInPagesContainerTopBar:self];
}

- (void)layoutItemViews
{
//    CGFloat x = DAPagesContainerTopBarItemsOffset;
    CGFloat x = 50;
    for (NSUInteger i = 0; i < self.itemViews.count; i++) {
        UIView *itemView = self.itemViews[i];
        itemView.frame = CGRectMake(x, 0., itemView.frame.size.width, itemView.frame.size.height);
        x += itemView.frame.size.width + self.tabItemGap;
    }
    self.scrollView.contentSize = CGSizeMake(x, CGRectGetHeight(self.scrollView.frame));
    CGRect frame = self.scrollView.frame;
    if (CGRectGetWidth(self.frame) > x) {
//        frame.origin.x = (CGRectGetWidth(self.frame) - x) / 2.;
        frame.origin.x = 0;
        frame.size.width = x;
    } else {
        frame.origin.x = 0.;
        frame.size.width = CGRectGetWidth(self.frame);
    }
    self.scrollView.frame = frame;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self layoutItemViews];
}

@end