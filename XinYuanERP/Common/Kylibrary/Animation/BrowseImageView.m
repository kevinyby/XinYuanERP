#import "BrowseImageView.h"
#import "UIApplication+WindowOverlay.h"
#import "FrameTranslater.h"
#import "AppInterface.h"

#define BASEWITH  1024

static CGRect oldframe;
@implementation BrowseImageView


+(void)browseImage:(UIImageView *)originImageView
{
    [self browseImage:originImageView adjustSize:0];
}

+(void)browseImage:(UIImageView *)originImageView adjustSize:(CGFloat)originX
{
    
    UIImage *image = originImageView.image;
    UIView* window = [UIApplication sharedApplication].baseWindowView;
    
    CGRect newRect = [UIScreen mainScreen].bounds;
    newRect.size.width = [UIScreen mainScreen].bounds.size.height;
    newRect.size.height = [UIScreen mainScreen].bounds.size.width;
    
    
    UIView *backgroundView=[[UIView alloc]initWithFrame:newRect];
    
    oldframe=[originImageView convertRect:originImageView.bounds toView:window];
    
    backgroundView.backgroundColor = [UIColor blackColor];
    backgroundView.alpha=0;
    UIImageView *imageView=[[UIImageView alloc]initWithFrame:oldframe];
    imageView.image=image;
    imageView.tag=1;
    
    [backgroundView addSubview:imageView];
    [window addSubview:backgroundView];
    
    
    UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideImage:)];
    [backgroundView addGestureRecognizer: tap];
    
    
    [UIView animateWithDuration:0.3 animations:^{
        
        CGRect iphoneNewRect = newRect;
        iphoneNewRect.origin.x = originX;
        iphoneNewRect.size.width = newRect.size.width - originX*2;
        imageView.frame = iphoneNewRect;
        
        backgroundView.alpha=1;
        
    } completion:^(BOOL finished) {
        
    }];
}


+(void)hideImage:(UITapGestureRecognizer*)tap{
    UIView *backgroundView=tap.view;
    
    UIImageView *imageView=(UIImageView*)[tap.view viewWithTag:1];
    
    [UIView animateWithDuration:0.3 animations:^{
        
        imageView.frame=oldframe;
        backgroundView.alpha=0;
        
    } completion:^(BOOL finished) {
        
        [backgroundView removeFromSuperview];
        
    }];
}





@end
