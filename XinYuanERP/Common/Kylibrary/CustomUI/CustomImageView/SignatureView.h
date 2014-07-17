//
//  签名View
//


#import <UIKit/UIKit.h>

@class NetworkImageView;
@class NICSignatureView;
@class KYZoomView;
@interface SignatureView : UIView

@property(nonatomic,strong)NICSignatureView *draggedView;
@property(nonatomic,strong)NetworkImageView *signView;

@property(assign)BOOL viewIsIn;
@property(assign)BOOL firstIn;

@property(assign)CGRect genieRect;

@property(nonatomic,strong)KYZoomView* scrollView;

- (id)initWithFrame:(CGRect)frame withUrl:(NSString* )url parent:(UIView*)parentView;

-(void)initDrawViewWithParent:(UIView*)parentView;


@end
