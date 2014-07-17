#import "JRLazyLoadingTable.h"
#import "AppInterface.h"

@interface JRLazyLoadingTable ()

@property (strong) NSMutableArray* currentLoadingUrlPaths;     // a flag
@property (strong) NSMutableArray* currentLoadingRequesters;    // requesters

@end

@implementation JRLazyLoadingTable


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _loadImages = [NSMutableArray array];
        
        self.currentLoadingUrlPaths = [NSMutableArray array];
        self.currentLoadingRequesters = [NSMutableArray array];
    }
    return self;
}

-(void)setLoadImagePaths:(NSMutableArray *)loadUrlPaths
{
    _loadImagePaths = loadUrlPaths == nil ? nil : [ArrayHelper deepCopy: loadUrlPaths];
    
    [_loadImages removeAllObjects];
    for (int i = 0; i < _loadImagePaths.count; i++) {
        [_loadImages addObject:[NSNull null]];
    }
    
    [self.currentLoadingUrlPaths removeAllObjects];
}


#pragma mark - Override Super Class Methods
-(void) subRender: (NSDictionary*)dictionary
{
    [super subRender: dictionary];
    
    __weak JRLazyLoadingTable* weakSelf = self;
    
    
    self.tableView.tableViewBaseCanEditIndexPathAction = ^BOOL(TableViewBase* tableViewObj, NSIndexPath* indexPath) {
        return YES;
    };
    self.tableView.tableViewBaseDidDeleteContentsAction = ^void(TableViewBase* tableViewObj, NSIndexPath* indexPath) {
        [weakSelf.loadImages removeObjectAtIndex: indexPath.row];
    };
    self.tableView.tableViewBaseCellForIndexPathAction = ^UITableViewCell*(TableViewBase* tableViewObj, NSIndexPath* indexPath,UITableViewCell* oldCell){
        JRImageView* jrimageView = (JRImageView*)[oldCell.contentView viewWithTag: 3002];
        if (! jrimageView) {
            jrimageView = [[JRImageView alloc] init];
            jrimageView.tag = 3002;
            jrimageView.userInteractionEnabled = YES;
            [oldCell.contentView addSubview: jrimageView];
            [FrameHelper setFrame: weakSelf.cellImageViewFrame view:jrimageView];
            oldCell.backgroundColor = [UIColor clearColor];
        }
        int row = indexPath.row;
        UIImage* image = [weakSelf.loadImages safeObjectAtIndex: row];
        if (! [image isKindOfClass:[UIImage class]]) image = nil;
        jrimageView.image = image;
        
        NSString* imagePath = [weakSelf.loadImagePaths safeObjectAtIndex: row];
        if (imagePath) {
            UIActivityIndicatorView* indicator = (UIActivityIndicatorView*)[oldCell.contentView viewWithTag: 4003];
            if (! indicator) {
                indicator = [[UIActivityIndicatorView alloc] init];
                indicator.tag = 4003;
                indicator.color = [UIColor blackColor];
                [FrameHelper setFrame: CGRectMake(0, 0, 50, 50) view:indicator];
                [oldCell.contentView addSubview: indicator];
            }
            [indicator stopAnimating];
            
            if (! image) {
                    [indicator startAnimating];
                    // if not loading
                    if (! [weakSelf.currentLoadingUrlPaths containsObject:imagePath]) {
                        HTTPRequester* requester = (HTTPRequester*)[weakSelf.currentLoadingRequesters safeObjectAtIndex: row];
                        // if no request to enough use
                        if (! requester) {
                            requester = [[HTTPRequester alloc] init];
                            [weakSelf.currentLoadingRequesters addObject: requester];
                        }
                        
                        [weakSelf.currentLoadingUrlPaths addObject: imagePath];
                        [requester startDownloadRequest: IMAGE_URL(DOWNLOAD) parameters:@{@"PATH":imagePath} completeHandler:^(HTTPRequester *requester, ResponseJsonModel *model, NSHTTPURLResponse *httpURLReqponse, NSError *error) {
                            UIImage* image = [UIImage imageWithData: model.binaryData];
                            NSLog(@"-- %@   loaded!!", imagePath);
                            if (! image) return ;
                            [indicator stopAnimating];
                            [weakSelf.loadImages replaceObjectAtIndex: row withObject:image];       //  loadImages need a occupied position
                            
                            [weakSelf.tableView beginUpdates];
                            [weakSelf.tableView reloadRowsAtIndexPaths: @[indexPath] withRowAnimation:YES];
                            [weakSelf.tableView endUpdates];
                            
                        }];
                }
            }
            
            
        }
        
        return oldCell;
    };
}


#pragma mark - Public Methods

-(void) stopLazyLoading
{
    [self.currentLoadingRequesters makeObjectsPerformSelector:@selector(cancelRequester)];
}



@end
