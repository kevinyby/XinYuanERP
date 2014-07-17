#import <Foundation/Foundation.h>

@class JRButton;

@interface BrowseImageView : NSObject

+(void)browseImage:(UIImageView*)originImageView;

+(void)browseImage:(UIImageView *)originImageView adjustSize:(CGFloat)originX;

@end
