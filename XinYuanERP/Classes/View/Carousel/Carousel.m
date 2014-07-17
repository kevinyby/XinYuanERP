#import "Carousel.h"
#import <objc/message.h>
#import "AppInterface.h"


#import <Availability.h>
#if !__has_feature(objc_arc)
#error This class requires automatic reference counting
#endif


#define MIN_TOGGLE_DURATION 0.2f
#define MAX_TOGGLE_DURATION 0.4f
#define SCROLL_DURATION 0.4f
#define INSERT_DURATION 0.4f
#define DECELERATE_THRESHOLD 0.1f
#define SCROLL_SPEED_THRESHOLD 1.0f
#define SCROLL_DISTANCE_THRESHOLD 0.1f
#define DECELERATION_MULTIPLIER 10.0f


#define MAX_VISIBLE_ITEMS 30


@implementation NSObject (iCarousel)

- (NSUInteger)numberOfPlaceholdersInCarousel:(Carousel *)carousel { return 0; }
- (void)carouselWillBeginScrollingAnimation:(Carousel *)carousel {}
- (void)carouselDidEndScrollingAnimation:(Carousel *)carousel {}
- (void)carouselDidScroll:(Carousel *)carousel {}

- (void)carouselCurrentItemIndexDidChange:(Carousel *)carousel {}
- (void)carouselWillBeginDragging:(Carousel *)carousel {}
- (void)carouselDidEndDragging:(Carousel *)carousel willDecelerate:(BOOL)decelerate {}
- (void)carouselWillBeginDecelerating:(Carousel *)carousel {}
- (void)carouselDidEndDecelerating:(Carousel *)carousel {}

- (BOOL)carousel:(Carousel *)carousel shouldSelectItemAtIndex:(NSInteger)index { return YES; }
- (void)carousel:(Carousel *)carousel didSelectItemAtIndex:(NSInteger)index {}

- (CGFloat)carouselItemWidth:(Carousel *)carousel { return 0; }
- (CATransform3D)carousel:(Carousel *)carousel
   itemTransformForOffset:(CGFloat)offset
            baseTransform:(CATransform3D)transform { return transform; }
- (CGFloat)carousel:(Carousel *)carousel
     valueForOption:(iCarouselOption)option
        withDefault:(CGFloat)value { return value; }

@end


@interface Carousel ()

@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) NSMutableDictionary *itemViews;
@property (nonatomic, strong) NSMutableSet *itemViewPool;
@property (nonatomic, strong) NSMutableSet *placeholderViewPool;
@property (nonatomic, assign) NSInteger previousItemIndex;
@property (nonatomic, assign) NSInteger numberOfPlaceholdersToShow;
@property (nonatomic, assign) NSInteger numberOfVisibleItems;
@property (nonatomic, assign) CGFloat itemWidth;
@property (nonatomic, assign) CGFloat offsetMultiplier;
@property (nonatomic, assign) CGFloat startOffset;
@property (nonatomic, assign) CGFloat endOffset;
@property (nonatomic, assign) NSTimeInterval scrollDuration;
@property (nonatomic, assign, getter = isScrolling) BOOL scrolling;
@property (nonatomic, assign) NSTimeInterval startTime;
@property (nonatomic, assign) CGFloat startVelocity;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign, getter = isDecelerating) BOOL decelerating;
@property (nonatomic, assign) CGFloat previousTranslation;
@property (nonatomic, assign, getter = isWrapEnabled) BOOL wrapEnabled;
@property (nonatomic, assign, getter = isDragging) BOOL dragging;
@property (nonatomic, assign) BOOL didDrag;
@property (nonatomic, assign) NSTimeInterval toggleTime;

NSComparisonResult compareViewDepth(UIView *view1, UIView *view2, Carousel *self);

@end


@implementation Carousel

@synthesize contentView;
@synthesize itemViews;
@synthesize itemViewPool;
@synthesize placeholderViewPool;
@synthesize previousItemIndex;
@synthesize numberOfPlaceholdersToShow;
@synthesize numberOfVisibleItems;
@synthesize itemWidth;
@synthesize offsetMultiplier;
@synthesize startOffset;
@synthesize endOffset;
@synthesize scrollDuration;
@synthesize scrolling;
@synthesize startTime;
@synthesize startVelocity;
@synthesize timer;
@synthesize decelerating;
@synthesize previousTranslation;
@synthesize wrapEnabled;
@synthesize dragging;
@synthesize didDrag;
@synthesize toggleTime;


@synthesize decelerationRate;
@synthesize bounces;
@synthesize perspective;
@synthesize contentOffset;
@synthesize viewpointOffset;
@synthesize scrollSpeed;
@synthesize bounceDistance;
@synthesize stopAtItemBoundary;
@synthesize scrollToItemBoundary;
@synthesize centerItemWhenSelected;

@synthesize dataSource;
@synthesize delegate;
@synthesize type;
@synthesize vertical;
@synthesize toggle;
@synthesize numberOfItems;
@synthesize numberOfPlaceholders;
@synthesize scrollOffset;
@synthesize pagingEnabled;


#pragma mark -
#pragma mark Initialisation

- (void)setUp
{
    decelerationRate = 0.99f;     // when 1.0f , will nerver stop
    bounces = YES;
    offsetMultiplier = 1.0f;
//    perspective = -1.0f/500.0f;
    //modify by yby
    if (IS_IPHONE) {
        perspective = -3.0f/500.0f;
    }else{
        perspective = -1.0f/500.0f;
    }
    
    contentOffset = CGSizeZero;
    viewpointOffset = CGSizeZero;
    scrollSpeed = 1.0f;
    bounceDistance = 1.0f;
    stopAtItemBoundary = YES;
    scrollToItemBoundary = YES;
    centerItemWhenSelected = YES;
    
    contentView = [[UIView alloc] initWithFrame:self.bounds];
    
        
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(didPanContainer:)];
    panGesture.delegate = (id <UIGestureRecognizerDelegate>)self;
    [contentView addGestureRecognizer:panGesture];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapContainer:)];
    [contentView addGestureRecognizer:tapGesture];
    
    UISwipeGestureRecognizer *swipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(didSwipeContainer:)];    // Isaacs modified
    swipeGesture.direction = UISwipeGestureRecognizerDirectionLeft;
    [contentView addGestureRecognizer:swipeGesture];
    
    
    [self addSubview:contentView];
    
    if (dataSource) [self reloadData];
}


- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame]))
    {
        [self setUp];
    }
    return self;
}


- (void)dealloc
{   
    [self stopAnimation];
}

- (void)setDataSource:(id<iCarouselDataSource>)dataSourceValue
{
    if (dataSource != dataSourceValue)
    {
        dataSource = dataSourceValue;
        if (dataSource)
        {
            [self reloadData];
        }
    }
}

- (void)setDelegate:(id<iCarouselDelegate>)delegateValue
{
    if (delegate != delegateValue)
    {
        delegate = delegateValue;
        if (delegate && dataSource)
        {
            [self setNeedsLayout];
        }
    }
}

- (void)setType:(iCarouselType)typeValue
{
    if (type != typeValue)
    {
        type = typeValue;
        [self layOutItemViews];
    }
}

- (void)setVertical:(BOOL)verticalValue
{
    if (vertical != verticalValue)
    {
        vertical = verticalValue;
        [self layOutItemViews];
    }
}

- (void)setScrollOffset:(CGFloat)scrollOffsetValue
{
    if (scrollOffset != scrollOffsetValue)
    {
        scrolling = NO;
        startOffset = scrollOffsetValue;
        endOffset = scrollOffsetValue;
        scrollOffset = scrollOffsetValue;
        [self didScroll];
    }
}

- (void)setCurrentItemIndex:(NSInteger)currentItemIndex
{
    [self setScrollOffset:currentItemIndex];
}

- (void)setPerspective:(CGFloat)perspectiveValue
{
    if (perspective != perspectiveValue)
    {
        perspective = perspectiveValue;
        [self transformItemViews];
    }
}

- (void)setViewpointOffset:(CGSize)viewpointOffsetValue
{
    if (!CGSizeEqualToSize(viewpointOffset, viewpointOffsetValue))
    {
        viewpointOffset = viewpointOffsetValue;
        [self transformItemViews];
    }
}

- (void)setContentOffset:(CGSize)contentOffsetValue
{
    if (!CGSizeEqualToSize(contentOffset, contentOffsetValue))
    {
        contentOffset = contentOffsetValue;
        [self layOutItemViews];
    }
}

- (void)pushAnimationState:(BOOL)enabled
{
    [CATransaction begin];
    [CATransaction setDisableActions:!enabled];
}

- (void)popAnimationState
{
    [CATransaction commit];
}


#pragma mark -
#pragma mark View management

- (NSArray *)indexesForVisibleItems
{
    return [[itemViews allKeys] sortedArrayUsingSelector:@selector(compare:)];
}

- (NSArray *)visibleItemViews
{
    NSArray *indexes = [self indexesForVisibleItems];
    return [itemViews objectsForKeys:indexes notFoundMarker:[NSNull null]];
}

- (UIView *)itemViewAtIndex:(NSInteger)index
{
    return itemViews[@(index)];
}

- (UIView *)currentItemView
{
    return [self itemViewAtIndex:self.currentItemIndex];
}

- (NSInteger)indexOfItemView:(UIView *)view
{
    NSInteger index = [[itemViews allValues] indexOfObject:view];
    if (index != NSNotFound)
    {
        return [[itemViews allKeys][index] integerValue];
    }
    return NSNotFound;
}

- (NSInteger)indexOfItemViewOrSubview:(UIView *)view
{
    NSInteger index = [self indexOfItemView:view];
    if (index == NSNotFound && view != nil && view != contentView)
    {
        return [self indexOfItemViewOrSubview:view.superview];
    }
    return index;
}

- (void)setItemView:(UIView *)view forIndex:(NSInteger)index
{
    itemViews[@(index)] = view;
}

- (void)removeViewAtIndex:(NSInteger)index
{
    NSMutableDictionary *newItemViews = [NSMutableDictionary dictionaryWithCapacity:[itemViews count] - 1];
    for (NSNumber *number in [self indexesForVisibleItems])
    {
        NSInteger i = [number integerValue];
        if (i < index)
        {
            newItemViews[number] = itemViews[number];
        }
        else if (i > index)
        {
            newItemViews[@(i - 1)] = itemViews[number];
        }
    }
    self.itemViews = newItemViews;
}

- (void)insertView:(UIView *)view atIndex:(NSInteger)index
{
    NSMutableDictionary *newItemViews = [NSMutableDictionary dictionaryWithCapacity:[itemViews count] + 1];
    for (NSNumber *number in [self indexesForVisibleItems])
    {
        NSInteger i = [number integerValue];
        if (i < index)
        {
            newItemViews[number] = itemViews[number];
        }
        else
        {
            newItemViews[@(i + 1)] = itemViews[number];
        }
    }
    if (view)
    {
        [self setItemView:view forIndex:index];
    }
    self.itemViews = newItemViews;
}


#pragma mark -
#pragma mark View layout

- (CGFloat)alphaForItemWithOffset:(CGFloat)offset
{
    CGFloat fadeMin = -INFINITY;
    CGFloat fadeMax = INFINITY;
    CGFloat fadeRange = 1.0f;
    CGFloat fadeMinAlpha = 0.0f;
    switch (type)
    {
        case iCarouselTypeTimeMachine:
        {
            fadeMax = 0.0f;
            break;
        }
        case iCarouselTypeInvertedTimeMachine:
        {
            fadeMin = 0.0f;
            break;
        }
        default:
        {
            //do nothing
        }
    }
    fadeMin = [self valueForOption:iCarouselOptionFadeMin withDefault:fadeMin];
    fadeMax = [self valueForOption:iCarouselOptionFadeMax withDefault:fadeMax];
    fadeRange = [self valueForOption:iCarouselOptionFadeRange withDefault:fadeRange];
    fadeMinAlpha = [self valueForOption:iCarouselOptionFadeMinAlpha withDefault:fadeMinAlpha];
    
    CGFloat factor = 0.0f;
    if (offset > fadeMax)
    {
        factor = offset - fadeMax;
    }
    else if (offset < fadeMin)
    {
        factor = fadeMin - offset;
    }
    return 1.0f - fminf(factor, fadeRange) / fadeRange * (1.0f - fadeMinAlpha);
}

- (CGFloat)valueForOption:(iCarouselOption)option withDefault:(CGFloat)value
{    
    return [delegate carousel:self valueForOption:option withDefault:value];
}

- (CATransform3D)transformForItemView:(UIView *)view withOffset:(CGFloat)offset
{   
    //set up base transform
    CATransform3D transform = CATransform3DIdentity;
    transform.m34 = perspective;
    transform = CATransform3DTranslate(transform, -viewpointOffset.width, -viewpointOffset.height, 0.0f);

    //perform transform
    switch (type)
    {
        case iCarouselTypeCustom:
        {
            return [delegate carousel:self itemTransformForOffset:offset baseTransform:transform];
        }
        case iCarouselTypeLinear:
        {
            CGFloat spacing = [self valueForOption:iCarouselOptionSpacing withDefault:1.0f];
            if (vertical)
            {
                return CATransform3DTranslate(transform, 0.0f, offset * itemWidth * spacing, 0.0f);
            }
            else
            {
                return CATransform3DTranslate(transform, offset * itemWidth * spacing, 0.0f, 0.0f);
            }
        }
        case iCarouselTypeRotary:
        case iCarouselTypeInvertedRotary:
        {
            CGFloat count = [self circularCarouselItemCount];
            CGFloat spacing = [self valueForOption:iCarouselOptionSpacing withDefault:1.0f];
            CGFloat arc = [self valueForOption:iCarouselOptionArc withDefault:M_PI * 2.0f];
            CGFloat radius = [self valueForOption:iCarouselOptionRadius withDefault:fmaxf(itemWidth * spacing / 2.0f, itemWidth * spacing / 2.0f / tanf(arc/2.0f/count))];
//            CGFloat angle = [self valueForOption:iCarouselOptionAngle withDefault:offset / count * arc];
            
            //modify by yby
            CGFloat angle;
            if (IS_IPHONE) {
                
                if (count<=5) {
                    angle = [self valueForOption:iCarouselOptionAngle withDefault:offset / count * arc];
                }else{
                    angle = [self valueForOption:iCarouselOptionAngle withDefault:offset / count * arc/2];
                }
                
            }else{
                
                if (count<=5) {
                    angle = [self valueForOption:iCarouselOptionAngle withDefault:offset / count * arc];
                }else{
                    angle = [self valueForOption:iCarouselOptionAngle withDefault:offset / count * arc/1.8];
                }
                
            }
            
            
            if (type == iCarouselTypeInvertedRotary)
            {
                radius = -radius;
                angle = -angle;
            }
            
            if (vertical)
            {
                return CATransform3DTranslate(transform, 0.0f, radius * sin(angle), radius * cos(angle) - radius);
            }
            else
            {
                return CATransform3DTranslate(transform, radius * sin(angle), 0.0f, radius * cos(angle) - radius);
            }
        }
        case iCarouselTypeCylinder:
        case iCarouselTypeInvertedCylinder:
        {
            CGFloat count = [self circularCarouselItemCount];
            CGFloat spacing = [self valueForOption:iCarouselOptionSpacing withDefault:1.0f];
            CGFloat arc = [self valueForOption:iCarouselOptionArc withDefault:M_PI * 2.0f];
            CGFloat radius = [self valueForOption:iCarouselOptionRadius withDefault:fmaxf(0.01f, itemWidth * spacing / 2.0f / tanf(arc/2.0f/count))];
            CGFloat angle = [self valueForOption:iCarouselOptionAngle withDefault:offset / count * arc];
            
            if (type == iCarouselTypeInvertedCylinder)
            {
                radius = -radius;
                angle = -angle;
            }
            
            if (vertical)
            {
                transform = CATransform3DTranslate(transform, 0.0f, 0.0f, -radius);
                transform = CATransform3DRotate(transform, angle, -1.0f, 0.0f, 0.0f);
                return CATransform3DTranslate(transform, 0.0f, 0.0f, radius + 0.01f);
            }
            else
            {
                transform = CATransform3DTranslate(transform, 0.0f, 0.0f, -radius);
                transform = CATransform3DRotate(transform, angle, 0.0f, 1.0f, 0.0f);
                return CATransform3DTranslate(transform, 0.0f, 0.0f, radius + 0.01f);
            }
        }
        case iCarouselTypeWheel:
        case iCarouselTypeInvertedWheel:
        {
            CGFloat count = [self circularCarouselItemCount];
            CGFloat spacing = [self valueForOption:iCarouselOptionSpacing withDefault:1.0f];
            CGFloat arc = [self valueForOption:iCarouselOptionArc withDefault:M_PI * 2.0f];
            CGFloat radius = [self valueForOption:iCarouselOptionRadius withDefault:itemWidth * spacing * count / arc];
            CGFloat angle = [self valueForOption:iCarouselOptionAngle withDefault:arc / count];
            
            if (type == iCarouselTypeInvertedWheel)
            {
                radius = -radius;
                angle = -angle;
            }
            
            if (vertical)
            {
                transform = CATransform3DTranslate(transform, -radius, 0.0f, 0.0f);
                transform = CATransform3DRotate(transform, angle * offset, 0.0f, 0.0f, 1.0f);
                return CATransform3DTranslate(transform, radius, 0.0f, offset * 0.01f);
            }
            else
            {
                transform = CATransform3DTranslate(transform, 0.0f, radius, 0.0f);
                transform = CATransform3DRotate(transform, angle * offset, 0.0f, 0.0f, 1.0f);
                return CATransform3DTranslate(transform, 0.0f, -radius, offset * 0.01f);
            }
        }
        case iCarouselTypeCoverFlow:
        case iCarouselTypeCoverFlow2:
        {
            CGFloat tilt = [self valueForOption:iCarouselOptionTilt withDefault:0.9f];
            CGFloat spacing = [self valueForOption:iCarouselOptionSpacing withDefault:0.25f];
            CGFloat clampedOffset = fmaxf(-1.0f, fminf(1.0f, offset));
            
            if (type == iCarouselTypeCoverFlow2)
            {
                if (toggle >= 0.0f)
                {
                    if (offset <= -0.5f)
                    {
                        clampedOffset = -1.0f;
                    }
                    else if (offset <= 0.5f)
                    {
                        clampedOffset = -toggle;
                    }
                    else if (offset <= 1.5f)
                    {
                        clampedOffset = 1.0f - toggle;
                    }
                }
                else
                {
                    if (offset > 0.5f)
                    {
                        clampedOffset = 1.0f;
                    }
                    else if (offset > -0.5f)
                    {
                        clampedOffset = -toggle;
                    }
                    else if (offset > -1.5f)
                    {
                        clampedOffset = - 1.0f - toggle;
                    }
                }
            }
            
            CGFloat x = (clampedOffset * 0.5f * tilt + offset * spacing) * itemWidth;
            CGFloat z = fabsf(clampedOffset) * -itemWidth * 0.5f;
            
            if (vertical)
            {
                transform = CATransform3DTranslate(transform, 0.0f, x, z);
                return CATransform3DRotate(transform, -clampedOffset * M_PI_2 * tilt, -1.0f, 0.0f, 0.0f);
            }
            else
            {
                transform = CATransform3DTranslate(transform, x, 0.0f, z);
                return CATransform3DRotate(transform, -clampedOffset * M_PI_2 * tilt, 0.0f, 1.0f, 0.0f);
            }
        }
        case iCarouselTypeTimeMachine:
        case iCarouselTypeInvertedTimeMachine:
        {
            CGFloat tilt = [self valueForOption:iCarouselOptionTilt withDefault:0.3f];
            CGFloat spacing = [self valueForOption:iCarouselOptionSpacing withDefault:1.0f];
            
            if (type == iCarouselTypeInvertedTimeMachine)
            {
                tilt = -tilt;
                offset = -offset;
            }
            
            if (vertical)
            {
                return CATransform3DTranslate(transform, 0.0f, offset * itemWidth * tilt, offset * itemWidth * spacing);
            }
            else
            {
                return CATransform3DTranslate(transform, offset * itemWidth * tilt, 0.0f, offset * itemWidth * spacing);
            }
        }
        default:
        {
            //shouldn't ever happen
            return CATransform3DIdentity;
        }
    }
}

NSComparisonResult compareViewDepth(UIView *view1, UIView *view2, Carousel *self)
{
    //compare depths
    CATransform3D t1 = view1.superview.layer.transform;
    CATransform3D t2 = view2.superview.layer.transform;
    CGFloat z1 = t1.m13 + t1.m23 + t1.m33 + t1.m43;
    CGFloat z2 = t2.m13 + t2.m23 + t2.m33 + t2.m43;
    CGFloat difference = z1 - z2;
    
    //if depths are equal, compare distance from current view
    if (difference == 0.0f)
    {
        CATransform3D t3 = [self currentItemView].superview.layer.transform;
        if (self.vertical)
        {
            CGFloat y1 = t1.m12 + t1.m22 + t1.m32 + t1.m42;
            CGFloat y2 = t2.m12 + t2.m22 + t2.m32 + t2.m42;
            CGFloat y3 = t3.m12 + t3.m22 + t3.m32 + t3.m42;
            difference = fabsf(y2 - y3) - fabsf(y1 - y3);
        }
        else
        {
            CGFloat x1 = t1.m11 + t1.m21 + t1.m31 + t1.m41;
            CGFloat x2 = t2.m11 + t2.m21 + t2.m31 + t2.m41;
            CGFloat x3 = t3.m11 + t3.m21 + t3.m31 + t3.m41;
            difference = fabsf(x2 - x3) - fabsf(x1 - x3);
        }
    }
    return (difference < 0.0f)? NSOrderedAscending: NSOrderedDescending;
}

- (void)depthSortViews
{
    for (UIView *view in [[itemViews allValues] sortedArrayUsingFunction:(NSInteger (*)(id, id, void *))compareViewDepth context:(__bridge void *)self])
    {
        [contentView bringSubviewToFront:view.superview];
    }
}

- (CGFloat)offsetForItemAtIndex:(NSInteger)index
{
    //calculate relative position
    CGFloat offset = index - scrollOffset;
    if (wrapEnabled)
    {
        if (offset > numberOfItems/2)
        {
            offset -= numberOfItems;
        }
        else if (offset < -numberOfItems/2)
        {
            offset += numberOfItems;
        }
    }
    
    //handle special case for one item
    if (numberOfItems + numberOfPlaceholdersToShow == 1)
    {
        offset = 0.0f;
    }
    
    return offset;
}

- (UIView *)containView:(UIView *)view
{
    //set item width
    if (!itemWidth)
    {
        itemWidth = vertical? view.bounds.size.height: view.bounds.size.width;
    }
    
    //set container frame
    CGRect frame = view.bounds;
//    frame.size.width = vertical? frame.size.width: itemWidth;           // Isaacs modified
//    frame.size.height = vertical? itemWidth: frame.size.height;
    UIView *containerView = [[UIView alloc] initWithFrame:frame];
    view.userInteractionEnabled = NO;
    
    
    //set view frame
    frame = view.frame;
    frame.origin.x = (containerView.bounds.size.width - frame.size.width) / 2.0f;
    frame.origin.y = (containerView.bounds.size.height - frame.size.height) / 2.0f;
    view.frame = frame;
    [containerView addSubview:view];
    
    return containerView;
}

- (void)transformItemView:(UIView *)view atIndex:(NSInteger)index
{
    //calculate offset
    CGFloat offset = [self offsetForItemAtIndex:index];
    
    //center view
    view.superview.center = CGPointMake(self.bounds.size.width/2.0f + contentOffset.width,
                                        self.bounds.size.height/2.0f + contentOffset.height);
    
    //update alpha
    view.superview.alpha = [self alphaForItemWithOffset:offset];
    
    //special-case logic for iCarouselTypeCoverFlow2
    CGFloat clampedOffset = fmaxf(-1.0f, fminf(1.0f, offset));
    if (decelerating || (scrolling && !didDrag) || (scrollOffset - [self clampedOffset:scrollOffset]) != 0.0f)
    {
        if (offset > 0)
        {
            toggle = (offset <= 0.5f)? -clampedOffset: (1.0f - clampedOffset);
        }
        else
        {
            toggle = (offset > -0.5f)? -clampedOffset: (- 1.0f - clampedOffset);
        }
    }
    
    //calculate transform
    CATransform3D transform = [self transformForItemView:view withOffset:offset];
    
    //transform view
    view.superview.layer.transform = transform;
    
    //backface culling
    BOOL showBackfaces = view.layer.doubleSided;
    if (showBackfaces)
    {
        switch (type)
        {
            case iCarouselTypeInvertedCylinder:
            {
                showBackfaces = NO;
                break;
            }
            default:
            {
                showBackfaces = YES;
                break;
            }
        }
    }
    showBackfaces = !![self valueForOption:iCarouselOptionShowBackfaces withDefault:showBackfaces];
    
    //we can't just set the layer.doubleSided property because it doesn't block interaction
    //instead we'll calculate if the view is front-facing based on the transform
    view.superview.hidden = !(showBackfaces ?: (transform.m33 > 0.0f));
}

- (void)layoutSubviews
{
    contentView.frame = self.bounds;
    [self layOutItemViews];
}

- (void)transformItemViews
{
    for (NSNumber *number in itemViews)
    {
        NSInteger index = [number integerValue];
        UIView *view = itemViews[number];
        [self transformItemView:view atIndex:index];
//        view.userInteractionEnabled = (!centerItemWhenSelected || index == self.currentItemIndex);
        view.userInteractionEnabled = YES;              // Isaacs Modified
    }
}

- (void)updateItemWidth
{
    itemWidth = [delegate carouselItemWidth:self] ?: itemWidth;
    if (numberOfItems > 0)
    {
        if ([itemViews count] == 0)
        {
            [self loadViewAtIndex:0];
        }
    }
    else if (numberOfPlaceholders > 0)
    {
        if ([itemViews count] == 0)
        {
            [self loadViewAtIndex:-1];
        }
    }
}

- (void)updateNumberOfVisibleItems
{
    //get number of visible items
    switch (type)
    {
        case iCarouselTypeLinear:
        {
            //exact number required to fill screen
            CGFloat spacing = [self valueForOption:iCarouselOptionSpacing withDefault:1.0f];
            CGFloat width = vertical ? self.bounds.size.height: self.bounds.size.width;
            CGFloat itemWidthValue = itemWidth * spacing;
            numberOfVisibleItems = ceilf(width / itemWidthValue) + 2;
            break;
        }
        case iCarouselTypeCoverFlow:
        case iCarouselTypeCoverFlow2:
        {
            //exact number required to fill screen
            CGFloat spacing = [self valueForOption:iCarouselOptionSpacing withDefault:0.25f];
            CGFloat width = vertical ? self.bounds.size.height: self.bounds.size.width;
            CGFloat itemWidthValue = itemWidth * spacing;
            numberOfVisibleItems = ceilf(width / itemWidthValue) + 2;
            break;
        }
        case iCarouselTypeRotary:
        case iCarouselTypeCylinder:
        {
            //based on count value
            numberOfVisibleItems = [self circularCarouselItemCount];
            break;
        }
        case iCarouselTypeInvertedRotary:
        case iCarouselTypeInvertedCylinder:
        {
            //TODO: improve this
            numberOfVisibleItems = ceilf([self circularCarouselItemCount] / 2.0f);
            break;
        }
        case iCarouselTypeWheel:
        case iCarouselTypeInvertedWheel:
        {
            //TODO: improve this
            CGFloat count = [self circularCarouselItemCount];
            CGFloat spacing = [self valueForOption:iCarouselOptionSpacing withDefault:1.0f];
            CGFloat arc = [self valueForOption:iCarouselOptionArc withDefault:M_PI * 2.0f];
            CGFloat radius = [self valueForOption:iCarouselOptionRadius withDefault:itemWidth * spacing * count / arc];
            if (radius - itemWidth / 2.0f < MIN(self.bounds.size.width, self.bounds.size.height) / 2.0f)
            {
                numberOfVisibleItems = count;
            }
            else
            {
                numberOfVisibleItems = ceilf(count / 2.0f) + 1;
            }
            break;
        }
        case iCarouselTypeTimeMachine:
        case iCarouselTypeInvertedTimeMachine:
        case iCarouselTypeCustom:
        default:
        {
            //slightly arbitrary number, chosen for performance reasons
            numberOfVisibleItems = MAX_VISIBLE_ITEMS;
            break;
        }
    }
    numberOfVisibleItems = MIN(MAX_VISIBLE_ITEMS, numberOfVisibleItems);
    numberOfVisibleItems = [self valueForOption:iCarouselOptionVisibleItems withDefault:numberOfVisibleItems];
    numberOfVisibleItems = MAX(0, MIN(numberOfVisibleItems, numberOfItems + numberOfPlaceholdersToShow));

}

- (NSInteger)circularCarouselItemCount
{
    NSInteger count = 0;
    switch (type)
    {
        case iCarouselTypeRotary:
        case iCarouselTypeInvertedRotary:
        case iCarouselTypeCylinder:
        case iCarouselTypeInvertedCylinder:
        case iCarouselTypeWheel:
        case iCarouselTypeInvertedWheel:
        {
            //slightly arbitrary number, chosen for aesthetic reasons
            CGFloat spacing = [self valueForOption:iCarouselOptionSpacing withDefault:1.0f];
            CGFloat width = vertical ? self.bounds.size.height: self.bounds.size.width;
            count = MIN(MAX_VISIBLE_ITEMS, MAX(12, ceilf(width / (spacing * itemWidth)) * M_PI));
            count = MIN(numberOfItems + numberOfPlaceholdersToShow, count);
            break;
        }
        default:
        {
            //not used for non-circular carousels
            return numberOfItems + numberOfPlaceholdersToShow;
            break;
        }
    }
    return [self valueForOption:iCarouselOptionCount withDefault:count];
}

- (void)layOutItemViews
{
    //bail out if not set up yet
    if (!dataSource || !contentView)
    {
        return;
    }

    //update wrap
    switch (type)
    {
        case iCarouselTypeRotary:
        case iCarouselTypeInvertedRotary:
        case iCarouselTypeCylinder:
        case iCarouselTypeInvertedCylinder:
        case iCarouselTypeWheel:
        case iCarouselTypeInvertedWheel:
        {
            wrapEnabled = YES;
            break;
        }
        default:
        {
            wrapEnabled = NO;
            break;
        }
    }
    wrapEnabled = !![self valueForOption:iCarouselOptionWrap withDefault:wrapEnabled];
    
    //no placeholders on wrapped carousels
    numberOfPlaceholdersToShow = wrapEnabled? 0: numberOfPlaceholders;
    
    //set item width
    [self updateItemWidth];
    
    //update number of visible items
    [self updateNumberOfVisibleItems];
    
    //prevent false index changed event
    previousItemIndex = self.currentItemIndex;
    
    //update offset multiplier
    switch (type)
    {
        case iCarouselTypeCoverFlow:
        case iCarouselTypeCoverFlow2:
        {
            offsetMultiplier = 2.0f;
            break;
        }
        default:
        {
            offsetMultiplier = 1.0f;
            break;
        }
    }
    offsetMultiplier = [self valueForOption:iCarouselOptionOffsetMultiplier withDefault:offsetMultiplier];

    //align
    if (!scrolling && !decelerating)
    {
        if (scrollToItemBoundary)
        {
//            [self scrollToItemAtIndex:self.currentItemIndex animated:YES];
        }
        else
        {
            scrollOffset = [self clampedOffset:scrollOffset];
        }
    }
    
    //update views
    [self didScroll];
}


#pragma mark -
#pragma mark View queing

- (void)queueItemView:(UIView *)view
{
    if (view)
    {
        [itemViewPool addObject:view];
    }
}

- (void)queuePlaceholderView:(UIView *)view
{
    if (view)
    {
        [placeholderViewPool addObject:view];
    }
}

- (UIView *)dequeueItemView
{
    UIView *view = [itemViewPool anyObject];
    if (view)
    {
        [itemViewPool removeObject:view];
    }
    return view;
}

- (UIView *)dequeuePlaceholderView
{
    UIView *view = [placeholderViewPool anyObject];
    if (view)
    {
        [placeholderViewPool removeObject:view];
    }
    return view;
}


#pragma mark -
#pragma mark View loading

- (UIView *)loadViewAtIndex:(NSInteger)index withContainerView:(UIView *)containerView
{
    [self pushAnimationState:NO];
    
    UIView *view = nil;
    if (index < 0)
    {
        view = [dataSource carousel:self placeholderViewAtIndex:(int)ceilf((CGFloat)numberOfPlaceholdersToShow/2.0f) + index reusingView:[self dequeuePlaceholderView]];
    }
    else if (index >= numberOfItems)
    {
        view = [dataSource carousel:self placeholderViewAtIndex:numberOfPlaceholdersToShow/2.0f + index - numberOfItems reusingView:[self dequeuePlaceholderView]];
    }
    else
    {
        view = [dataSource carousel:self viewForItemAtIndex:index reusingView:[self dequeueItemView]];
    }
    
    if (view == nil)
    {
        view = [[UIView alloc] init];
    }
    [self setItemView:view forIndex:index];
    if (containerView)
    {
        //get old item view
        UIView *oldItemView = [containerView.subviews lastObject];
        if (index < 0 || index >= numberOfItems)
        {
            [self queuePlaceholderView:oldItemView];
        }
        else
        {
            [self queueItemView:oldItemView];
        }
        
        //set container frame
        CGRect frame = containerView.bounds;
        if(vertical) {
            frame.size.width = view.frame.size.width;
            frame.size.height = MIN(itemWidth, view.frame.size.height);
        } else {
            frame.size.width = MIN(itemWidth, view.frame.size.width);
            frame.size.height = view.frame.size.height;
        }
        containerView.bounds = frame;

        
        //set view frame
        frame = view.frame;
        frame.origin.x = (containerView.bounds.size.width - frame.size.width) / 2.0f;
        frame.origin.y = (containerView.bounds.size.height - frame.size.height) / 2.0f;
        view.frame = frame;
        
        //switch views
        [oldItemView removeFromSuperview];
        [containerView addSubview:view];
    }
    else
    {
        [contentView addSubview:[self containView:view]];
    }
    [self transformItemView:view atIndex:index];
    
    [self popAnimationState];
    
    return view;
}

- (UIView *)loadViewAtIndex:(NSInteger)index
{
    return [self loadViewAtIndex:index withContainerView:nil];
}

- (void)loadUnloadViews
{
    //set item width
    [self updateItemWidth];
    
    //update number of visible items
    [self updateNumberOfVisibleItems];
    
    //calculate visible view indices
    NSMutableSet *visibleIndices = [NSMutableSet setWithCapacity:numberOfVisibleItems];
    NSInteger min = -(int)ceilf((CGFloat)numberOfPlaceholdersToShow/2.0f);
    NSInteger max = numberOfItems - 1 + numberOfPlaceholdersToShow/2;
    NSInteger offset = self.currentItemIndex - numberOfVisibleItems/2;
    if (!wrapEnabled)
    {
        offset = MAX(min, MIN(max - numberOfVisibleItems + 1, offset));
    }
    for (NSInteger i = 0; i < numberOfVisibleItems; i++)
    {
        NSInteger index = i + offset;
        if (wrapEnabled)
        {
            index = [self clampedIndex:index];
        }
        CGFloat alpha = [self alphaForItemWithOffset:[self offsetForItemAtIndex:index]];
        if (alpha)
        {
            //only add views with alpha > 0
            [visibleIndices addObject:@(index)];
        }
    }
    
    //remove offscreen views
    for (NSNumber *number in [itemViews allKeys])
    {
        if (![visibleIndices containsObject:number])
        {
            UIView *view = itemViews[number];
            if ([number integerValue] < 0 || [number integerValue] >= numberOfItems)
            {
                [self queuePlaceholderView:view];
            }
            else
            {
                [self queueItemView:view];
            }
            [view.superview removeFromSuperview];
            [(NSMutableDictionary *)itemViews removeObjectForKey:number];
        }
    }
    
    //add onscreen views
    for (NSNumber *number in visibleIndices)
    {
        UIView *view = itemViews[number];
        if (view == nil)
        {
            [self loadViewAtIndex:[number integerValue]];
        }
    }
}

- (void)reloadData
{    
    //remove old views
    for (UIView *view in [itemViews allValues])
    {
        [view.superview removeFromSuperview];
    }
    
    //bail out if not set up yet
    if (!dataSource || !contentView)
    {
        return;
    }
    
    //get number of items and placeholders
    numberOfVisibleItems = 0;
    numberOfItems = [dataSource numberOfItemsInCarousel:self];
    numberOfPlaceholders = [dataSource numberOfPlaceholdersInCarousel:self];

    //reset view pools
    self.itemViews = [NSMutableDictionary dictionary];
    self.itemViewPool = [NSMutableSet set];
    self.placeholderViewPool = [NSMutableSet setWithCapacity:numberOfPlaceholders];
    
    //layout views
    [self setNeedsLayout];
}


#pragma mark -
#pragma mark Scrolling

- (NSInteger)clampedIndex:(NSInteger)index
{
    if (wrapEnabled)
    {
        return numberOfItems? (index - floorf((CGFloat)index / (CGFloat)numberOfItems) * numberOfItems): 0;
    }
    else
    {
        return MIN(MAX(0, index), MAX(0, numberOfItems - 1));
    }
}

- (CGFloat)clampedOffset:(CGFloat)offset
{
    if (wrapEnabled)
    {
        return numberOfItems? (offset - floorf(offset / (CGFloat)numberOfItems) * numberOfItems): 0.0f;
    }
    else
    {
        return fminf(fmaxf(0.0f, offset), fmaxf(0.0f, (CGFloat)numberOfItems - 1.0f));
    }
}

- (NSInteger)currentItemIndex
{   
    return [self clampedIndex:roundf(scrollOffset)];
}

- (NSInteger)minScrollDistanceFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex
{
    NSInteger directDistance = toIndex - fromIndex;
    if (wrapEnabled)
    {
        NSInteger wrappedDistance = MIN(toIndex, fromIndex) + numberOfItems - MAX(toIndex, fromIndex);
        if (fromIndex < toIndex)
        {
            wrappedDistance = -wrappedDistance;
        }
        return (ABS(directDistance) <= ABS(wrappedDistance))? directDistance: wrappedDistance;
    }
    return directDistance;
}

- (CGFloat)minScrollDistanceFromOffset:(CGFloat)fromOffset toOffset:(CGFloat)toOffset
{
    CGFloat directDistance = toOffset - fromOffset;
    if (wrapEnabled)
    {
        CGFloat wrappedDistance = fminf(toOffset, fromOffset) + numberOfItems - fmaxf(toOffset, fromOffset);
        if (fromOffset < toOffset)
        {
            wrappedDistance = -wrappedDistance;
        }
        return (fabsf(directDistance) <= fabsf(wrappedDistance))? directDistance: wrappedDistance;
    }
    return directDistance;
}

- (void)scrollByOffset:(CGFloat)offset duration:(NSTimeInterval)duration
{
    if (duration > 0.0)
    {
        decelerating = NO;
        scrolling = YES;
        startTime = CACurrentMediaTime();
        startOffset = scrollOffset;
        scrollDuration = duration;
        previousItemIndex = roundf(scrollOffset);
        endOffset = startOffset + offset;
        if (!wrapEnabled)
        {
            endOffset = [self clampedOffset:endOffset];
        }
        [delegate carouselWillBeginScrollingAnimation:self];
        [self startAnimation];
    }
    else
    {
        self.scrollOffset += offset;
    }
}

- (void)scrollToOffset:(CGFloat)offset duration:(NSTimeInterval)duration
{
    [self scrollByOffset:[self minScrollDistanceFromOffset:scrollOffset toOffset:offset] duration:duration];
}

- (void)scrollByNumberOfItems:(NSInteger)itemCount duration:(NSTimeInterval)duration
{
    if (duration > 0.0)
    {
        CGFloat offset = 0.0f;
        if (itemCount > 0)
        {
            offset = (floorf(scrollOffset) + itemCount) - scrollOffset;
        }
        else if (itemCount < 0)
        {
            offset = (ceilf(scrollOffset) + itemCount) - scrollOffset;
        }
        else
        {
            offset = roundf(scrollOffset) - scrollOffset;
        }
        [self scrollByOffset:offset duration:duration];
    }
    else
    {
        self.scrollOffset = [self clampedIndex:previousItemIndex + itemCount];
    }
}

- (void)scrollToItemAtIndex:(NSInteger)index duration:(NSTimeInterval)duration
{
    [self scrollToOffset:index duration:duration];
}

- (void)scrollToItemAtIndex:(NSInteger)index animated:(BOOL)animated
{
    [self scrollToItemAtIndex:index duration:animated? SCROLL_DURATION: 0];
}

- (void)removeItemAtIndex:(NSInteger)index animated:(BOOL)animated
{
    index = [self clampedIndex:index];
    UIView *itemView = [self itemViewAtIndex:index];
    
    if (animated)
    {
        
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.1];
        [UIView setAnimationDelegate:itemView.superview];
        [UIView setAnimationDidStopSelector:@selector(removeFromSuperview)];
        [self performSelector:@selector(queueItemView:) withObject:itemView afterDelay:0.1];
        itemView.superview.layer.opacity = 0.0f;
        [UIView commitAnimations];
        
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDelay:0.1];
        [UIView setAnimationDuration:INSERT_DURATION];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(depthSortViews)];
        [self removeViewAtIndex:index];
        numberOfItems --;
        wrapEnabled = !![self valueForOption:iCarouselOptionWrap withDefault:wrapEnabled];
        [self updateNumberOfVisibleItems];
        scrollOffset = self.currentItemIndex;
        [self didScroll];
        [UIView commitAnimations];
        
    }
    else
    {
        [self pushAnimationState:NO];
        [self queueItemView:itemView];
        [itemView.superview removeFromSuperview];
        [self removeViewAtIndex:index];
        numberOfItems --;
        wrapEnabled = !![self valueForOption:iCarouselOptionWrap withDefault:wrapEnabled];
        scrollOffset = self.currentItemIndex;
        [self didScroll];
        [self depthSortViews];
        [self popAnimationState];
    }
}

- (void)fadeInItemView:(UIView *)itemView
{
    NSInteger index = [self indexOfItemView:itemView];
    CGFloat offset = [self offsetForItemAtIndex:index];
    CGFloat alpha = [self alphaForItemWithOffset:offset];
    
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.1f];
    itemView.superview.layer.opacity = alpha;
    [UIView commitAnimations];
    
}

- (void)insertItemAtIndex:(NSInteger)index animated:(BOOL)animated
{
    numberOfItems ++;
    wrapEnabled = !![self valueForOption:iCarouselOptionWrap withDefault:wrapEnabled];
    [self updateNumberOfVisibleItems];
    
    index = [self clampedIndex:index];
    [self insertView:nil atIndex:index];
    UIView *itemView = [self loadViewAtIndex:index];
    itemView.superview.layer.opacity = 0.0f;
    
    if (itemWidth == 0)
    {
        [self updateItemWidth];
    }
    
    if (animated)
    {
        
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:INSERT_DURATION];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(loadUnloadViews)];
        [self transformItemViews];
        [UIView commitAnimations];
        
        [self performSelector:@selector(fadeInItemView:) withObject:itemView afterDelay:INSERT_DURATION - 0.1f];
    }
    else
    {
        [self pushAnimationState:NO];
        [self transformItemViews]; 
        [self popAnimationState];
        itemView.superview.layer.opacity = 1.0f; 
    }
}

- (void)reloadItemAtIndex:(NSInteger)index animated:(BOOL)animated
{
    //get container view
    UIView *containerView = [[self itemViewAtIndex:index] superview];
    if (containerView)
    {
        if (animated)
        {
            //fade transition
            CATransition *transition = [CATransition animation];
            transition.duration = INSERT_DURATION;
            transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            transition.type = kCATransitionFade;
            [containerView.layer addAnimation:transition forKey:nil];
        }
        
        //reload view
        [self loadViewAtIndex:index withContainerView:containerView];
    }
}

#pragma mark -
#pragma mark Animation

- (void)startAnimation
{
    if (!timer)
    {
        self.timer = [NSTimer timerWithTimeInterval:1.0/60.0
                                             target:self
                                           selector:@selector(step)
                                           userInfo:nil
                                            repeats:YES];
        
        [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];

#ifdef ICAROUSEL_IOS
        
        [[NSRunLoop mainRunLoop] addTimer:timer forMode:UITrackingRunLoopMode];

#endif
        
    }
}

- (void)stopAnimation
{
    [timer invalidate];
    timer = nil;
}

- (CGFloat)decelerationDistance
{
    CGFloat acceleration = -startVelocity * DECELERATION_MULTIPLIER * (1.0f - decelerationRate);
//    NSLog(@"acceleration : %f", acceleration) ;         // Isaac modified
    return -powf(startVelocity, 2.0f) / (2.0f * acceleration);
}

- (BOOL)shouldDecelerate
{
    return (fabsf(startVelocity) > SCROLL_SPEED_THRESHOLD) &&
    (fabsf([self decelerationDistance]) > DECELERATE_THRESHOLD);
}

- (BOOL)shouldScroll
{
    return (fabsf(startVelocity) > SCROLL_SPEED_THRESHOLD) &&
    (fabsf(scrollOffset - self.currentItemIndex) > SCROLL_DISTANCE_THRESHOLD);
}

- (void)startDecelerating: (CGFloat)distance
{
//    distance = 10.5 ;                        // Isaacs modified
    startOffset = scrollOffset;
    endOffset = startOffset + distance;
    if (pagingEnabled)
    {
        if (distance > 0.0f)
        {
            endOffset = ceilf(startOffset);
        }
        else
        {
            endOffset = floorf(startOffset);
        }
    }
    else if (stopAtItemBoundary)
    {
        if (distance > 0.0f)    // Isaacs modified , go in here
        {
            endOffset = ceilf(endOffset);
        }
        else
        {
            endOffset = floorf(endOffset);
        }
    }
    if (!wrapEnabled)
    {
        if (bounces)
        {
            endOffset = fmaxf(-bounceDistance, fminf(numberOfItems - 1.0f + bounceDistance, endOffset));
        }
        else
        {
            endOffset = [self clampedOffset:endOffset];
        }
    }
    distance = endOffset - startOffset;
    
    startTime = CACurrentMediaTime();
    scrollDuration = fabsf(distance) / fabsf(0.5f * startVelocity);
//    NSLog(@"%f  =  %f - %f .      scrollDuration: %f", distance, endOffset, startOffset, scrollDuration);
    
    if (distance != 0.0f)
    {
        decelerating = YES;
        [self startAnimation];
    }
}

- (CGFloat)easeInOut:(CGFloat)time
{
    return (time < 0.5f)? 0.5f * powf(time * 2.0f, 3.0f): 0.5f * powf(time * 2.0f - 2.0f, 3.0f) + 1.0f;
//    return 0.7f;
}

- (void)step
{
    [self pushAnimationState:NO];
    NSTimeInterval currentTime = CACurrentMediaTime();
    
    if (toggle != 0.0f)
    {
        NSTimeInterval toggleDuration = startVelocity? fminf(1.0, fmaxf(0.0, 1.0 / fabsf(startVelocity))): 1.0;
        toggleDuration = MIN_TOGGLE_DURATION + (MAX_TOGGLE_DURATION - MIN_TOGGLE_DURATION) * toggleDuration;
        NSTimeInterval time = fminf(1.0f, (currentTime - toggleTime) / toggleDuration);
        CGFloat delta = [self easeInOut:time];
//        NSLog(@"delta : %f", time);                    // Isaacs modified
        toggle = (toggle < 0.0f)? (delta - 1.0f): (1.0f - delta);
        [self didScroll];
    }
    
    if (scrolling)
    {
        NSTimeInterval time = fminf(1.0f, (currentTime - startTime) / scrollDuration);
        CGFloat delta = [self easeInOut:time];
//        NSLog(@"delta : %f", time);                    // Isaacs modified
        scrollOffset = startOffset + (endOffset - startOffset) * delta;
//        [self didScroll];
        if (time == 1.0f)
        {
            scrolling = NO;
            [self depthSortViews];
            [self pushAnimationState:YES];
            [delegate carouselDidEndScrollingAnimation:self];
            [self popAnimationState];
        }
    }
    else if (decelerating)
    {
        CGFloat time = fminf(scrollDuration, currentTime - startTime);
        CGFloat acceleration = -startVelocity / scrollDuration;
        
        CGFloat rate = powf(time  , 2.0f);
        CGFloat distance = startVelocity * time + 0.5f * acceleration * rate;
//        NSLog(@"time %f,distance %f,reate: %f,leftTime:%f", time, distance, rate,scrollDuration-time);       // Isaacs modified
        scrollOffset = startOffset + distance;
        
        [self didScroll];
        if (time == (CGFloat)scrollDuration)
        {
            decelerating = NO;
            [self pushAnimationState:YES];
            [delegate carouselDidEndDecelerating:self];
            [self popAnimationState];
            if (scrollToItemBoundary || (scrollOffset - [self clampedOffset:scrollOffset]) != 0.0f)
            {
                //
            }
            else
            {
                CGFloat difference = (CGFloat)self.currentItemIndex - scrollOffset;
                if (difference > 0.5)
                {
                    difference = difference - 1.0f;
                }
                else if (difference < -0.5)
                {
                    difference = 1.0 + difference;
                }
                toggleTime = currentTime - MAX_TOGGLE_DURATION * fabsf(difference);
                toggle = fmaxf(-1.0f, fminf(1.0f, -difference));
            }
        }
    }
    else if (toggle == 0.0f)
    {
        [self stopAnimation];
    }
    
    [self popAnimationState];
}

//for iOS
- (void)didMoveToSuperview
{
    if (self.superview)
    {
        [self startAnimation];
    }
    else
    {
        [self stopAnimation];
    }
}

- (void)didScroll
{
    if (wrapEnabled || !bounces)
    {
        scrollOffset = [self clampedOffset:scrollOffset];
    }
    else
    {
        CGFloat min = -bounceDistance;
        CGFloat max = fmaxf(numberOfItems - 1, 0.0f) + bounceDistance;
        if (scrollOffset < min)
        {
            scrollOffset = min;
            startVelocity = 0.0f;
        }
        else if (scrollOffset > max)
        {
            scrollOffset = max;
            startVelocity = 0.0f;
        }
    }
    
    //check if index has changed
    NSInteger currentIndex = roundf(scrollOffset);
    NSInteger difference = [self minScrollDistanceFromIndex:previousItemIndex toIndex:currentIndex];
    if (difference)
    {
        toggleTime = CACurrentMediaTime();
        toggle = fmaxf(-1.0f, fminf(1.0f, -(CGFloat)difference));
        
        [self startAnimation];
    }
    
    [self loadUnloadViews];    
    [self transformItemViews];

    //update previous index
    previousItemIndex = currentIndex;
}


#pragma mark -
#pragma mark Gestures and taps

- (BOOL)viewOrSuperview:(UIView *)view implementsSelector:(SEL)selector
{
    //thanks to @mattjgalloway and @shaps for idea
    //https://gist.github.com/mattjgalloway/6279363
    //https://gist.github.com/shaps80/6279008
    
    Class class = [view class];
	while (class && class != [UIView class])
    {
		int unsigned numberOfMethods;
		Method *methods = class_copyMethodList(class, &numberOfMethods);
		for (int i = 0; i < numberOfMethods; i++)
        {
			if (method_getName(methods[i]) == selector)
            {
				return YES;
			}
		}
		class = [class superclass];
	}
    
    if (view.superview && view.superview != self.contentView)
    {
        return [self viewOrSuperview:view.superview implementsSelector:selector];
    }
    
	return NO;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gesture
{
    if ([gesture isKindOfClass:[UIPanGestureRecognizer class]]) {
        //ignore vertical swipes
        UIPanGestureRecognizer *panGesture = (UIPanGestureRecognizer *)gesture;
        CGPoint translation = [panGesture translationInView:self];
        BOOL value = vertical ? fabsf(translation.x) <= fabsf(translation.y) : fabsf(translation.x) >= fabsf(translation.y);
        return value;
    }
    return YES;
}

- (void) didTapContainer: (UITapGestureRecognizer *)tapGesture{     //Isaacs modified
    [self depthSortViews];
    CGPoint location = [tapGesture locationInView: tapGesture.view];
    UIView* superView = [tapGesture.view hitTest: location withEvent:nil];
    
    if (superView != tapGesture.view) {
        NSInteger index = [self indexOfItemView: superView];
        if (index >= numberOfItems) {
            index = [self indexOfItemView: [superView.subviews lastObject]];
        }
        
        [delegate carousel:self didTapItemAtIndex:index];
    }
}

- (void)didSwipeContainer:(UISwipeGestureRecognizer *)swipeGesture {         //Isaacs modified
    [self depthSortViews];
    CGPoint location = [swipeGesture locationInView: swipeGesture.view];
    UIView* superView = [swipeGesture.view hitTest: location withEvent:nil];
    
    if (superView != swipeGesture.view) {
        NSInteger index = [self indexOfItemView: superView];
        if (index >= numberOfItems) {
            index = [self indexOfItemView: [superView.subviews lastObject]];
        }
        
        [delegate carousel:self didSwipeItemAtIndex:index];
    }
}

- (void)didPanContainer:(UIPanGestureRecognizer *)panGesture
{
    switch (panGesture.state)
    {
        case UIGestureRecognizerStateBegan:
        {
            dragging = YES;
            scrolling = NO;
            decelerating = NO;
            previousTranslation = vertical? [panGesture translationInView:self].y: [panGesture translationInView:self].x;
            [delegate carouselWillBeginDragging:self];
            break;
        }
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        {
            dragging = NO;
            didDrag = YES;
            if ([self shouldDecelerate]) {
                didDrag = NO;
                [self startDecelerating: [self decelerationDistance]];
            }
            
            [self pushAnimationState:YES];
            [delegate carouselDidEndDragging:self willDecelerate:decelerating];
            [self popAnimationState];
            
            if (!decelerating && (scrollToItemBoundary || (scrollOffset - [self clampedOffset:scrollOffset]) != 0.0f)) {
                
            } else {
                [self pushAnimationState:YES];
                [delegate carouselWillBeginDecelerating:self];
                [self popAnimationState];
            }
            break;
        }
        default:
        {
            CGFloat translation = (vertical? [panGesture translationInView:self].y: [panGesture translationInView:self].x) - previousTranslation;
            CGFloat factor = 1.0f;
            if (!wrapEnabled && bounces)
            {
                factor = 1.0f - fminf(fabsf(scrollOffset - [self clampedOffset:scrollOffset]), bounceDistance) / bounceDistance;
            }
            
            previousTranslation = vertical? [panGesture translationInView:self].y: [panGesture translationInView:self].x;
            startVelocity = -(vertical? [panGesture velocityInView:self].y: [panGesture velocityInView:self].x) * factor * scrollSpeed / itemWidth;
            scrollOffset -= translation * factor * offsetMultiplier / itemWidth;
            [self didScroll];
        }
    }

}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self stopAnimation];
}

@end