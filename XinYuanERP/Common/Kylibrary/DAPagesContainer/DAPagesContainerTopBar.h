
#import <UIKit/UIKit.h>


@class DAPagesContainerTopBar;

@protocol DAPagesContainerTopBarDelegate <NSObject>

- (void)itemAtIndex:(NSUInteger)index didSelectInPagesContainerTopBar:(DAPagesContainerTopBar *)bar;

@end


@interface DAPagesContainerTopBar : UIView

@property (strong, nonatomic) NSArray *itemTitles;
@property (strong, nonatomic) UIFont *font;
@property (readonly, strong, nonatomic) NSArray *itemViews;
@property (readonly, strong, nonatomic) UIScrollView *scrollView;
@property (weak, nonatomic) id<DAPagesContainerTopBarDelegate> delegate;

@property (assign, nonatomic) NSUInteger tabItemGap;

@property (assign, nonatomic) NSUInteger tabItemOriginX;


- (CGPoint)centerForSelectedItemAtIndex:(NSUInteger)index;
- (CGPoint)contentOffsetForSelectedItemAtIndex:(NSUInteger)index;

- (void)setItemTitles:(NSArray *)itemTitles withImageArray:(NSArray*)itemImage;

@end