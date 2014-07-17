

#import <UIKit/UIKit.h>

@class DAPagesContainer;
@protocol DAPagesContainerDelegate <NSObject>

- (void)itemAtIndex:(NSUInteger)index didSelectInDAPagesContainer:(DAPagesContainer *)container;

@end

@interface DAPagesContainer : UIViewController

@property (strong, nonatomic) NSArray *viewControllers;
@property (assign, nonatomic) NSUInteger selectedIndex;

@property (strong, nonatomic) UIScrollView *scrollView;
@property (weak,   nonatomic) UIScrollView *observingScrollView;

@property (assign, nonatomic) NSUInteger topBarHeight;
@property (assign, nonatomic) CGSize pageIndicatorViewSize;
@property (strong, nonatomic) UIColor *topBarBackgroundColor;
@property (strong, nonatomic) UIFont *topBarItemLabelsFont;
@property (strong, nonatomic) UIColor *pageItemsTitleColor;
@property (strong, nonatomic) UIColor *selectedPageItemColor;

@property (assign, nonatomic) NSUInteger topBarItemGap;
@property (assign, nonatomic) NSUInteger topBarOriginX;

@property (weak, nonatomic) id<DAPagesContainerDelegate> delegate;

- (void)setSelectedIndex:(NSUInteger)selectedIndex animated:(BOOL)animated;
- (void)updateLayoutForNewOrientation:(UIInterfaceOrientation)orientation;


- (void)setViewControllers:(NSArray *)viewControllers withbuttonArray:(NSArray*)btns;

- (id)initWithBarHeight:(NSUInteger)topBarHeight;

@end