#import "JRRefreshTableView.h"

@interface JRLazyLoadingTable : JRRefreshTableView


@property (readonly, strong) NSMutableArray* loadImages;

@property (nonatomic, strong) NSMutableArray* loadImagePaths; // outside set

//
@property (assign) CGRect cellImageViewFrame;


#pragma mark - Public Methods
-(void) stopLazyLoading;

@end
