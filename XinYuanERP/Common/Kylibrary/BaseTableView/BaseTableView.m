
#import "BaseTableView.h"
#import "CategoryAdditions.h"

#define H_FOOTER 50

@implementation BaseTableView

@synthesize hasHeaderView,hasFooterView;
@synthesize headerView,footerView;
@synthesize baseDelegate;
@synthesize datas;
@synthesize isLoading,isHeader,isMore,isRefresh;
@synthesize pageNum,totalPage,currentPage;
@synthesize loadingView,emptyView,errorView;



-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self resetData];
        hasFooterView = YES;
        hasHeaderView = YES;
        self.bounces = YES;
        
        BaseHeaderView *aHeaderView = [[BaseHeaderView alloc] initWithFrame:CGRectMake(0.0f, -self.height, self.width, self.height) isHeader:YES];
        aHeaderView.delegate = self;
        [self addSubview:aHeaderView];
        [aHeaderView refreshLastUpdatedDate];
        self.headerView =aHeaderView;
        
        
        BaseTableViewFooterView *aFooter = [[BaseTableViewFooterView alloc] initWithFrame:
                                            CGRectMake(0, 0, self.width, H_FOOTER)];
        aFooter.bfDelegate = self;
        self.tableFooterView = aFooter;
        self.footerView = aFooter;
        [self footerShowOrHide];
        
        
        
        //等待,为空,错误
        loadingView =  [[BaseLoadingView alloc] initWithFrame:self.bounds];
        //        [self addSubview:loadingView];
        errorView = [[DOErrorView alloc] initWithTitle:@"网络连接失败"  subtitle:@"" image:nil];
        errorView.frame = self.bounds;
        errorView.backgroundColor = [UIColor whiteColor];
        [self addSubview:errorView];
        [errorView setHidden:YES];
       
        
        
//        emptyView = [[BaseEmptyView alloc] initWithFrame:self.bounds];
//        [self addSubview:emptyView];
//        [emptyView setHidden:YES];
    }
    return self;
}


-(void)dealloc{
    
    headerView.delegate = nil;

    baseDelegate = nil;
    

}



-(void)footerShowOrHide{
    if (hasFooterView) {
        if (datas.count==0) {
            footerView.hidden = YES;
        }else{
            footerView.hidden = NO;
        }
    }else{
        self.tableFooterView=nil;
        footerView = nil;
    }
}


#pragma mark - ScrollViewDelegate

-(void)scrollViewDidScrollTOBaseTableViewAction{
    
    
    
    if(self.contentOffset.y<0){
        isHeader=YES;
        if (hasHeaderView) {
            [headerView egoRefreshScrollViewDidScroll:self];
        }
        
        return;
    }
    
    
    
    //底部触发加载
    else if (self.contentOffset.y>((self.contentSize.height - self.frame.size.height))
             && (self.contentSize.height - self.frame.size.height)>=0) {
        isHeader=NO;
        if (isMore) {
            
            if (footerView.hidden == NO){
                if (hasFooterView) {
                    
                    if (isLoading == NO) {
                        if ([baseDelegate respondsToSelector:@selector(baseTableViewFooterAction:)]) {
                            
                            isLoading = YES;
                            [footerView start];
                            self.tableFooterView = footerView;
                            [baseDelegate performSelector:@selector(baseTableViewFooterAction:) withObject:self];
                        }
                    
                    }
                }
                
            }
            else {
                return;
            }
        }
    }
}

-(void)scrollViewDidEndDraggingTOBaseTableViewAction{
    
    
    if(self.contentOffset.y<0){
        //刷新时候，隐藏footerView
        if (hasFooterView) {
            
            if (isMore) {
                [footerView stop];
            }else{
                [footerView stopNoMoreData];
                [self footerShowOrHide];
            }
        
        }
        isHeader=YES;
        if (hasHeaderView) {
            [headerView egoRefreshScrollViewDidEndDragging:self];
        }
    }
}




#pragma mark - action



-(void)mainReloadData{
    [self reloadData];
}

-(void)finishLoadingDataAction:(NSArray*)aArray{

    isLoading = NO;
    if (hasFooterView){
        [footerView setHidden:NO];
    }else{
        self.tableFooterView=nil;
    }
    
    
    //********************************************
    [loadingView setHidden:YES];
    
    if (isRefresh == YES) {
        [datas removeAllObjects];
        isRefresh = NO;
    }
    
    NSMutableArray *aMutableArray = [[NSMutableArray alloc] init];
    
    //加入数据
    if (aArray) {
        for (int i=0; i<[aArray count]; i++) {
            [aMutableArray addObject:[aArray objectAtIndex:i]];
        }
    }
    self.datas=aMutableArray;
    
    //加入数据,并reload
    [self performSelectorOnMainThread:@selector(mainReloadData) withObject:nil waitUntilDone:NO];

    
    //********************************************
//    if ([datas count]==0) {
//        [emptyView setHidden:NO];
//        
//    }else{
//        [emptyView setHidden:YES];
//    }
    
    //关闭动画
    if (isHeader) {
        if (hasHeaderView) {
            [headerView egoRefreshScrollViewDataSourceDidFinishedLoading:self];
        }
    
    }
    else {
        if (hasFooterView) {
            [footerView stop];
            [self footerShowOrHide];
        }
    }
    
    //是否有footer
    //totalPage
    if (currentPage>=totalPage) {
        if (hasFooterView) {
            [footerView stopNoMoreData];
            [self footerShowOrHide];
            
            self.tableFooterView= nil;
        }
        
        isMore = NO;
    }else{
        
        if (hasFooterView) {
            [footerView stop];
            [self footerShowOrHide];
        }
        
        isMore = YES;
    }
    
    //是否隐藏footer
    if ([datas count]<pageNum
        || (([datas count]/pageNum)>=totalPage)) {
        if (hasFooterView) {
            [footerView stopNoMoreData];
            [self footerShowOrHide];
            
            self.tableFooterView= nil;
        }
        
        isMore = NO;
    }
    
    if (isMore) {
        currentPage++;
    }
}

-(void)resetData{
    
    isRefresh = YES;
    isLoading = NO;
    pageNum = 10;
    totalPage = 1;
    currentPage = 1;
    isMore = YES;
    if (datas == nil) {
        self.datas = [[NSMutableArray alloc] init] ;
    }
}





#pragma mark - EGORefreshTableHeaderDelegate Methods

- (void)egoRefreshTableHeaderDidTriggerRefresh:(BaseHeaderView*)view{
    
    //头部触发加载
    if (isHeader && !isLoading) {
        if ([baseDelegate respondsToSelector:@selector(baseTableViewHeaderAction:)]) {
            
//            [emptyView setHidden:YES];
            //判断是否显示loadingView
            if ([datas count]==0) {
                [loadingView setHidden:NO];
            }
            
            [self resetData];
            
            isLoading = YES;
            
            [baseDelegate performSelector:@selector(baseTableViewHeaderAction:) withObject:self];
        }
    }
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(BaseHeaderView*)view{
	return isLoading;
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(BaseHeaderView*)view{
	
	return [NSDate date];
}


-(void)BaseTableViewFooterViewTapAction:(BaseTableViewFooterView*)aBaseTableViewFooterView{
    isHeader=NO;
    if (isMore){
        if (hasFooterView) {
            if (isLoading == NO) {
                if ([baseDelegate respondsToSelector:@selector(baseTableViewFooterAction:)]) {
                    isLoading = YES;
                    
                    self.tableFooterView = footerView;
                    [footerView start];
                    [self footerShowOrHide];
                    [baseDelegate performSelector:@selector(baseTableViewFooterAction:) withObject:self];
                    
                }
            }
        }
        
    }

}


- (void)layoutSubviews {
    [super layoutSubviews];
    
    loadingView.frame = self.bounds;
//    emptyView.frame = self.bounds;
    errorView.frame = self.bounds;
    
}


@end
