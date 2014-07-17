

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface DOErrorView : UIView {
    UIImageView*  _imageView;
    UILabel*      _titleView;
    UILabel*      _subtitleView;
}

@property (nonatomic, strong) UIImage*  image;
@property (nonatomic, copy)   NSString* title;
@property (nonatomic, copy)   NSString* subtitle;

- (id)initWithTitle:(NSString*)title subtitle:(NSString*)subtitle image:(UIImage*)image;

@end

