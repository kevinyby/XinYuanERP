#import "RefreshTableView.h"
#import "RefreshBottomView.h"
#import "RefreshTopView.h"

#import "_View.h"
#import "_Helper.h"
#import "_Frame.h"


@interface RefreshTableView ()
{
    void(^_refreshTableViewDidTriggeredRefreshTop)(RefreshTableView* tableViewObj);
    void(^_refreshTableViewDidTriggeredRefreshBottom)(RefreshTableView* tableViewObj);
}

@end


@interface RefreshTableView() <TableViewBaseScrollProxy>

@property (assign) float kTOP_BOTTOM_REFRESH_OFFSET_Y;
@property (assign) float kTOP_BOTTOM_VIEW_SHOW_POSITION_Y;

@end

@implementation RefreshTableView
{
    CGFloat topViewY ;
    CGFloat bottomViewY ;
    
    NSArray* topBottomContraints;
}

@synthesize kTOP_BOTTOM_VIEW_SHOW_POSITION_Y;
@synthesize kTOP_BOTTOM_REFRESH_OFFSET_Y;


- (id)init
{
    self = [super init];
    if (self) {
        kTOP_BOTTOM_VIEW_SHOW_POSITION_Y = [FrameTranslater convertCanvasY: 25];
        kTOP_BOTTOM_REFRESH_OFFSET_Y = [FrameTranslater convertCanvasY: 50];
        
        self.tableView.scrollProxy = self;
        
        // top view
        _topView = [[RefreshTopView alloc] initWithText:Nil];
        _topView.arrowImage = [UIImage imageNamed:@"blackArrow"];
        [_topView setSize:(CGSize){[FrameTranslater convertCanvasWidth:210],[FrameTranslater convertCanvasHeight:25]}];
        [self insertSubview:_topView belowSubview: self.headerView];
        
        // bottom view
        _bottomView = [[RefreshBottomView alloc] initWithText:nil];
        [_bottomView setSize:(CGSize){[FrameTranslater convertCanvasWidth:30],[FrameTranslater convertCanvasHeight:30]}];
        [self addSubview: _bottomView];
        
        
        // important!!!   forbbin when scrolling call layoutSubviews method
        [_topView setTranslatesAutoresizingMaskIntoConstraints: NO];
        [_bottomView setTranslatesAutoresizingMaskIntoConstraints: NO];
    }
    return self;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    
    [self.topView setCenterX: self.frame.size.width/2];
    [self.bottomView setCenterX: self.frame.size.width/2];
    
    topViewY = self.tableView.frame.origin.y - [FrameTranslater convertCanvasY: 50];
    [self.topView setCenterY: topViewY];
    
    bottomViewY = self.frame.size.height * 0.9;
    [self.bottomView setCenterY: bottomViewY];
    
//    NSLog(@"---> %f, %f, %f", topViewY, bottomViewY, self.frame.origin.y);
}


#pragma mark - getter

-(void)setDisableTriggered:(BOOL)disableTriggered {
    if (disableTriggered) {
        self.tableView.scrollProxy = nil;
        self.topView.hidden = YES;
        self.bottomView.hidden = YES;
    } else {
        self.tableView.scrollProxy = self;
        self.topView.hidden = NO;
        self.topView.hidden = NO;
    }
    _disableTriggered = disableTriggered;
}


#pragma mark - TableViewBaseScrollProxy

- (void)tableViewBaseDidScroll:(TableViewBase *)tableViewObj 
{
    if (_disableTriggered) return;
    
    float contentoffsetY = tableViewObj.contentOffset.y;
    
    // drag down
    if (contentoffsetY < 0) {
        // normal or loading mode
        float y = topViewY - contentoffsetY;
        [self.topView setOriginY: y];

    
        if (self.topView.state == RefreshElementStateLoading) return;
        
        
        // pulling mode
        if (contentoffsetY < -kTOP_BOTTOM_REFRESH_OFFSET_Y) {
            if (self.topView.state != RefreshElementStatePulling) {
                self.topView.state = RefreshElementStatePulling;
            }
        } else {
            if (self.topView.state != RefreshElementStateNormal) {
                self.topView.state = RefreshElementStateNormal;
            }
        }
        
        
    // drag up
    } else if (contentoffsetY > 0) {
        
        if (self.bottomView.state == RefreshElementStateLoading) return;
        
        BOOL isContentSizeSmall = tableViewObj.contentSize.height < tableViewObj.bounds.size.height;
        if ((isContentSizeSmall && contentoffsetY > kTOP_BOTTOM_VIEW_SHOW_POSITION_Y)
            || (!isContentSizeSmall && contentoffsetY > kTOP_BOTTOM_VIEW_SHOW_POSITION_Y + fabs(tableViewObj.contentSize.height - tableViewObj.bounds.size.height))) {
            
            if (self.bottomView.state != RefreshElementStatePulling) self.bottomView.state = RefreshElementStatePulling;
        } else {
            if (self.bottomView.state != RefreshElementStateNormal) self.bottomView.state = RefreshElementStateNormal;
        }
    }
}

- (void)tableViewBaseDidEndDecelerating:(TableViewBase *)tableViewObj
{
    if (self.bottomView.state == RefreshElementStateNormal) {
        self.bottomView.state = RefreshElementStateNull;
    }
    if (self.topView.state == RefreshElementStateNormal) {
        self.topView.state = RefreshElementStateNull;
    }
}

- (void)tableViewBase:(TableViewBase *)tableViewObj didEndDragging:(BOOL)willDecelerate
{
    if (_disableTriggered) return;
    
    float contentoffsetY = tableViewObj.contentOffset.y;
#pragma mark - Trigger Top Refresh

    if (contentoffsetY < 0 && contentoffsetY < -kTOP_BOTTOM_REFRESH_OFFSET_Y) {
        NSLog(@"--------didEndDragging Top Refresh");
        if (self.topView.state == RefreshElementStateLoading) return;
        
        self.topView.state = RefreshElementStateLoading;
        
        [self setScrollViewContentInsetForLoading];
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(didTriggeredTopRefresh:)]) {
            [self.delegate didTriggeredTopRefresh: self];
        } else {
            [self doneDownloading: YES];
        }
    
       
#pragma mark - Trigger Bottom Refresh
        
     } else if (contentoffsetY > 0 && contentoffsetY > kTOP_BOTTOM_REFRESH_OFFSET_Y ) {
         if (self.bottomView.state == RefreshElementStateLoading) return;
         
         BOOL isContentSizeSmall = tableViewObj.contentSize.height < tableViewObj.bounds.size.height;
         
         if ((isContentSizeSmall && contentoffsetY > kTOP_BOTTOM_REFRESH_OFFSET_Y)
             || (!isContentSizeSmall && contentoffsetY > kTOP_BOTTOM_REFRESH_OFFSET_Y + fabs(tableViewObj.contentSize.height - tableViewObj.bounds.size.height))) {
             
             NSLog(@"--------didEndDragging Bottom Refresh");
             self.bottomView.state = RefreshElementStateLoading;
             
             [self setScrollViewContentInsetForLoading];
             
             if (self.delegate && [self.delegate respondsToSelector:@selector(didTriggeredBottomRefresh:)]) {
                 [self.delegate didTriggeredBottomRefresh: self];
             } else {
                 [self doneDownloading: NO];
             }
         }
         

     }
}



#pragma mark - Private Methods

- (void)setScrollViewContentInsetForLoading {
    UITableViewCell* cell = [self.tableView.visibleCells lastObject];
    CGFloat cellHeight = cell.frame.size.height;
    
    UIEdgeInsets currentTableViewInsets = self.tableView.contentInset;
    if (self.tableView.contentOffset.y < 0){
        currentTableViewInsets.top = cellHeight;
    } else {
        currentTableViewInsets.bottom = cellHeight;
    }

    [UIView animateWithDuration:0.1
                          delay:0
                        options:UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         self.tableView.contentInset = currentTableViewInsets;
                     }
                     completion:NULL];
}

#pragma mark - Public Methods

-(void) doneDownloading: (BOOL)isTop {
    [NSObject cancelPreviousPerformRequestsWithTarget: self];
    [self performSelector: @selector(resumeViewsDoneLoading:) withObject:[NSNumber numberWithBool: isTop] afterDelay:1.0];
    
//    int64_t delayInSeconds = 1.0;
//    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
//    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
//        [self resumeViewsDoneLoading: [NSNumber numberWithBool: isTop]];
//    });
}

#pragma mark - Private Methods

-(void) resumeViewsDoneLoading: (NSNumber*)isTopNum
{
    BOOL isTop = [isTopNum boolValue];
    UIEdgeInsets contentInset = self.tableView.contentInset;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.1];
    [self.tableView setContentInset:(UIEdgeInsets){isTop ? 0.0f:contentInset.top, contentInset.left, isTop ? contentInset.bottom:0.0f, contentInset.right}];
    [UIView commitAnimations];
    
//    if (!isTop) {
//        CGPoint bottomOffset = CGPointMake(0, fmaxf(0,self.tableView.contentSize.height - self.tableView.bounds.size.height));
//        [self.tableView setContentOffset:bottomOffset animated:YES];
//    }
    
    RefreshElementView* elementView = isTop ? self.topView : self.bottomView;
    elementView.state = RefreshElementStateNull;
}


@end


















// ----------------------- Delegate Block

@implementation RefreshTableView(DelegateBlock)

-(void (^)(RefreshTableView *))refreshTableViewDidTriggeredRefreshTop
{
    return _refreshTableViewDidTriggeredRefreshTop;
}

-(void)setRefreshTableViewDidTriggeredRefreshTop:(void (^)(RefreshTableView *))refreshTableViewDidTriggeredRefreshTop
{
    _refreshTableViewDidTriggeredRefreshTop = refreshTableViewDidTriggeredRefreshTop;
}

-(void (^)(RefreshTableView *))refreshTableViewDidTriggeredRefreshBottom
{
    return _refreshTableViewDidTriggeredRefreshBottom;
}

-(void)setRefreshTableViewDidTriggeredRefreshBottom:(void (^)(RefreshTableView *))refreshTableViewDidTriggeredRefreshBottom
{
    _refreshTableViewDidTriggeredRefreshBottom = refreshTableViewDidTriggeredRefreshBottom;
}

@end







