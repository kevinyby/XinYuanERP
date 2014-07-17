#import <UIKit/UIKit.h>

@interface UIView (UIViewAdditions)


-(void)setBackgroundImage:(NSString*)aImageStr;

-(BOOL)removeSubview:(NSInteger)aTag;

-(void)removeAllSubviews;

@property(retain,nonatomic) NSValue* originFrame;
@property(retain,nonatomic) NSString* symbol;//标示



- (CGFloat)left;
- (void)setLeft:(CGFloat)x;

- (CGFloat)top;
- (void)setTop:(CGFloat)y;

- (CGFloat)right;
- (void)setRight:(CGFloat)right;

- (CGFloat)bottom;
- (void)setBottom:(CGFloat)bottom;

- (CGFloat)centerX;
- (void)setCenterX:(CGFloat)centerX;

- (CGFloat)centerY;
- (void)setCenterY:(CGFloat)centerY;

- (CGFloat)width;
- (void)setWidth:(CGFloat)width;

- (CGFloat)height;
- (void)setHeight:(CGFloat)height;

- (CGPoint)origin;
- (void)setOrigin:(CGPoint)origin;

- (CGSize)size;
- (void)setSize:(CGSize)size;


@end
