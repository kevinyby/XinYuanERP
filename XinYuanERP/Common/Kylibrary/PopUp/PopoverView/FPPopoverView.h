

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

typedef enum {
    FPPopoverArrowDirectionUp = 1UL << 0,
    FPPopoverArrowDirectionDown = 1UL << 1,
    FPPopoverArrowDirectionLeft = 1UL << 2,
    FPPopoverArrowDirectionRight = 1UL << 3,

    FPPopoverArrowDirectionVertical = FPPopoverArrowDirectionUp | FPPopoverArrowDirectionDown,
    FPPopoverArrowDirectionHorizontal = FPPopoverArrowDirectionLeft | FPPopoverArrowDirectionRight,
    
    FPPopoverArrowDirectionAny = FPPopoverArrowDirectionUp | FPPopoverArrowDirectionDown | 
    FPPopoverArrowDirectionLeft | FPPopoverArrowDirectionRight
    
} FPPopoverArrowDirection;


#define FPPopoverArrowDirectionIsVertical(direction)    ((direction) == FPPopoverArrowDirectionVertical || (direction) == FPPopoverArrowDirectionUp || (direction) == FPPopoverArrowDirectionDown)

#define FPPopoverArrowDirectionIsHorizontal(direction)    ((direction) == FPPopoverArrowDirectionHorizontal || (direction) == FPPopoverArrowDirectionLeft || (direction) == FPPopoverArrowDirectionRight)


typedef enum {
    FPPopoverBlackTint = 1UL << 0, // default
    FPPopoverLightGrayTint = 1UL << 1,
    FPPopoverGreenTint = 1UL << 2,
    FPPopoverRedTint = 1UL << 3,
    FPPopoverDefaultTint = FPPopoverBlackTint
} FPPopoverTint;

@interface FPPopoverView : UIView
{
    //default FPPopoverArrowDirectionUp
    FPPopoverArrowDirection _arrowDirection;
//    UIView *_contentView;
//    UILabel *_titleLabel;
}
@property(nonatomic,strong) NSString *title;
@property(nonatomic,assign) CGPoint relativeOrigin;
@property(nonatomic,assign) FPPopoverTint tint;

@property(nonatomic,strong)UIView *contentView;
@property(nonatomic,strong)UILabel *titleLabel;


-(void)setArrowDirection:(FPPopoverArrowDirection)arrowDirection;
-(FPPopoverArrowDirection)arrowDirection;

-(void)addContentView:(UIView*)contentView;

@end
