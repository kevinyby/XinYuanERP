#import <UIKit/UIKit.h>
#import "JRViewProtocal.h"

@class JRImageView;
typedef void(^JRImageViewDidClickAction)(JRImageView* jrImageView);

@interface JRImageView : UIImageView <JRComponentProtocal>



@property (nonatomic, copy) JRImageViewDidClickAction didClickAction;

@property (nonatomic, copy) JRImageViewDidClickAction doubleClickAction;



@end
