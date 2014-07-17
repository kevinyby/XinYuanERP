
#import <UIKit/UIKit.h>

@interface UIImage (UIImageAdditions)

+ (UIImage *)imageNamed: (NSString *)imageStr size: (CGSize) size;
+ (UIImage *)scaleImage:(UIImage *)image maxWidth:(float)maxWidth maxHeight:(float)maxHeight;
+ (UIImage *)fixOrientation:(UIImage *)aImage;


- (UIImage *)imageRotatedByRadians:(CGFloat)radians;
- (UIImage *)imageRotatedByDegrees:(CGFloat)degrees;

@end
