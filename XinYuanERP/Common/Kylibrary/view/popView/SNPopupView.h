

#import <UIKit/UIKit.h>


//#define _CONFIRM_REGION

#define SHADOW_OFFSET					CGSizeMake(10, 10)
#define CONTENT_OFFSET					CGSizeMake(10, 10)
#define POPUP_ROOT_SIZE					CGSizeMake(20, 10)

#define HORIZONTAL_SAFE_MARGIN			30

#define POPUP_ANIMATION_DURATION		0.3
#define DISMISS_ANIMATION_DURATION		0.2

#define DEFAULT_TITLE_SIZE				20

#define ALPHA							0.6

#define BAR_BUTTON_ITEM_UPPER_MARGIN	10
#define BAR_BUTTON_ITEM_BOTTOM_MARGIN	5

@class TouchPeekView;

typedef enum {
	SNPopupViewUp		= 1,
	SNPopupViewDown		= 2,
	SNPopupViewRight	= 1 << 8,
	SNPopupViewLeft		= 2 << 8,
}SNPopupViewDirection;

@class SNPopupView;

@protocol SNPopupViewModalDelegate <NSObject>

- (void)didDismissModal:(SNPopupView*)popupview;

@end

@interface SNPopupView : UIView {
	CGGradientRef gradient;
	CGGradientRef gradient2;
	
	CGRect		contentRect;
	CGRect		contentBounds;
	
	CGRect		popupRect;
	CGRect		popupBounds;
	
	CGRect		viewRect;
	CGRect		viewBounds;
	
	CGPoint		pointToBeShown;
	
	NSString	*title;
	float		fontSize;
	
	float		horizontalOffset;
	id			target;
	SEL			action;
	TouchPeekView	*peekView;
	
	BOOL		animatedWhenAppering;
}
@property (nonatomic, readonly) NSString *title;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, assign) id <SNPopupViewModalDelegate> delegate;
@property (nonatomic, assign) SNPopupViewDirection	direction;

- (id)initWithString:(NSString*)newValue withFontOfSize:(float)newFontSize;
- (id)initWithString:(NSString*)newValue;
- (id)initWithImage:(UIImage*)newImage;
- (id)initWithContentView:(UIView*)newContentView contentSize:(CGSize)contentSize;

- (void)showAtPoint:(CGPoint)p inView:(UIView*)inView;
- (void)showAtPoint:(CGPoint)p inView:(UIView*)inView animated:(BOOL)animated;

- (void)presentModalAtPoint:(CGPoint)p inView:(UIView*)inView;
- (void)presentModalAtPoint:(CGPoint)p inView:(UIView*)inView animated:(BOOL)animated;

- (BOOL)shouldBeDismissedFor:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)dismiss;
- (void)dismiss:(BOOL)animtaed;
- (void)dismissModal;

- (void)addTarget:(id)target action:(SEL)action;
@end
