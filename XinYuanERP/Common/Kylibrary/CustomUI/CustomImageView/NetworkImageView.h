//
//  异步下载图片(Post 请求)
//

#import <UIKit/UIKit.h>
#import "HTTPRequester.h"
#import "GestureImageView.h"


@interface NetworkImageView : GestureImageView<HTTPRequesterDelegate>

@property(nonatomic,strong)UIImage* dataImage;
@property(nonatomic,strong)UIImage* defaultImage;
@property(nonatomic,strong)UIActivityIndicatorView* activityView;

@property(nonatomic,strong)HTTPRequester* requester;

- (void)loadImageFromURL:(NSString*)url;

@end
