#import "UIView+UIViewAdditions.h"
#import "UIView+Frame.h"
#import <objc/runtime.h>

static const char* originFrameKey="originFrameKey";
static const char* symbolKey = "symbolKey";

@implementation UIView (UIViewAdditions)


-(void)setBackgroundImage:(NSString*)aImageStr{
	NSString* path=[[NSBundle mainBundle] pathForResource:aImageStr ofType:nil];
	UIImage *smallImage = [[UIImage alloc] initWithContentsOfFile:path];
	self.backgroundColor = [UIColor colorWithPatternImage:smallImage];
}

-(BOOL)removeSubview:(NSInteger)aTag{
	if (nil!=[self viewWithTag:aTag]
		&& [[self viewWithTag:aTag] isKindOfClass:[UIView class]]) {
		[[self viewWithTag:aTag] removeFromSuperview];
		return YES;
	}
	return NO;
}

-(void)removeAllSubviews
{
    int subviewCount=[[self subviews]count];
    for (int i=0; i<subviewCount; i++) {
        if ([[[self subviews]objectAtIndex:i] isKindOfClass:[UIView class]]){
            [[[self subviews]objectAtIndex:i] removeFromSuperview];
        }
    }
}

-(NSValue*)originFrame{
    return  objc_getAssociatedObject(self, originFrameKey);
    
}
-(void)setOriginFrame:(NSValue *)originFrame
{
    objc_setAssociatedObject(self, originFrameKey, originFrame, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


-(NSString*)symbol{
    return  objc_getAssociatedObject(self, symbolKey);
}

-(void)setSymbol:(NSString *)symbol{
    objc_setAssociatedObject(self, symbolKey, symbol, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}



- (CGFloat)left {
	return self.frame.origin.x;
}
- (void)setLeft:(CGFloat)x {
	CGRect frame = self.frame;
	frame.origin.x = x;
	self.frame = frame;
}
- (CGFloat)top {
	return self.frame.origin.y;
}
- (void)setTop:(CGFloat)y {
	CGRect frame = self.frame;
	frame.origin.y = y;
	self.frame = frame;
}
- (CGFloat)right {
	return self.frame.origin.x + self.frame.size.width;
}
- (void)setRight:(CGFloat)right {
	CGRect frame = self.frame;
	frame.origin.x = right - frame.size.width;
	self.frame = frame;
}
- (CGFloat)bottom {
	return self.frame.origin.y + self.frame.size.height;
}
- (void)setBottom:(CGFloat)bottom {
	CGRect frame = self.frame;
	frame.origin.y = bottom - frame.size.height;
	self.frame = frame;
}
- (CGFloat)centerX {
	return self.center.x;
}
- (void)setCenterX:(CGFloat)centerX {
	self.center = CGPointMake(centerX, self.center.y);
}
- (CGFloat)centerY {
	return self.center.y;
}
- (void)setCenterY:(CGFloat)centerY {
	self.center = CGPointMake(self.center.x, centerY);
}
- (CGFloat)width {
	return self.frame.size.width;
}
- (void)setWidth:(CGFloat)width {
	CGRect frame = self.frame;
	frame.size.width = width;
	self.frame = frame;
}
- (CGFloat)height {
	return self.frame.size.height;
}
- (void)setHeight:(CGFloat)height {
	CGRect frame = self.frame;
	frame.size.height = height;
	self.frame = frame;
}
- (CGPoint)origin {
	return self.frame.origin;
}
- (void)setOrigin:(CGPoint)origin {
	CGRect frame = self.frame;
	frame.origin = origin;
	self.frame = frame;
}
- (CGSize)size {
	return self.frame.size;
}
- (void)setSize:(CGSize)size {
	CGRect frame = self.frame;
	frame.size = size;
	self.frame = frame;
}


@end
