#import "ZoomScrollView.h"
#import "AppInterface.h"

@interface ZoomScrollView ()
{
    
    CGFloat currentScale;//当前倍率
    CGFloat minScale;//最小倍率
    
}
@end

@implementation ZoomScrollView
//@synthesize contentView;
@synthesize maxScale;
//@synthesize zoomdelegate=_zoomdelegate;


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        //最大放大倍数(默认值)
        maxScale=2.0;
        //设置最小倍率为1.0
        minScale=1.0;
        //设置当前的放大倍数
        currentScale=1.0;
        
        self.userInteractionEnabled=YES;
        self.maximumZoomScale=2.0;//最大倍率（默认倍率）
        self.minimumZoomScale=1.0;//最小倍率（默认倍率）
        self.decelerationRate=1.0;//减速倍率（默认倍率）
        self.delegate=self;
        self.autoresizingMask =UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleHeight;
        
        UIView* contentView = self.contentView;
//        contentView=[[UIView alloc] init];
        contentView.userInteractionEnabled=YES;
        contentView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleHeight;
        //图片默认作为2倍图处理
        contentView.frame=CGRectMake(0, 0, frame.size.width, frame.size.height);
        contentView.backgroundColor=[UIColor whiteColor];
//        [super addSubview:contentView];
        
        
        
        if (IS_IPHONE) {
            [self setContentSize:CGSizeMake(frame.size.width, frame.size.height)];
            
            //            self.userInteractionEnabled=YES;
            //双击手势
            //            UITapGestureRecognizer *doubelGesture=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleGesture:)];
            //            doubelGesture.numberOfTouchesRequired=2;
            //            [self addGestureRecognizer:doubelGesture];
            //            [doubelGesture release];
            
            [self setScrollEnabled:YES];
            
            
        }else{
            
            [self setContentSize:CGSizeMake(frame.size.width, frame.size.height)];
            [self setScrollEnabled:NO];
            
        }
        
    }
    return self;
}

#pragma mark -setter action
-(void)setMaxScale:(float)maxScaleValue
{
    maxScale=maxScaleValue;
    self.maximumZoomScale=maxScaleValue;
}


//-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
//{
//    return contentView;
//}

-(void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale
{
    currentScale=scale;
}
#pragma mark -DoubleGesture Action
-(void)doubleGesture:(UIGestureRecognizer *)sender
{
    
    //当前倍数等于最大放大倍数
    //双击默认为缩小到原图
    if (currentScale==maxScale) {
        currentScale=minScale;
        [self setZoomScale:currentScale animated:YES];
        return;
    }
    //当前等于最小放大倍数
    //双击默认为放大到最大倍数
    if (currentScale==minScale) {
        currentScale=maxScale;
        [self setZoomScale:currentScale animated:YES];
        return;
    }
    
    CGFloat aveScale =minScale+(maxScale-minScale)/2.0;//中间倍数
    
    //当前倍数大于平均倍数
    //双击默认为放大最大倍数
    if (currentScale>=aveScale) {
        currentScale=maxScale;
        [self setZoomScale:currentScale animated:YES];
        return;
    }
    
    //当前倍数小于平均倍数
    //双击默认为放大到最小倍数
    if (currentScale<aveScale) {
        currentScale=minScale;
        [self setZoomScale:currentScale animated:YES];
        return;
    }
}


@end
