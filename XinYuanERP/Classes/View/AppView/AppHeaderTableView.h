#import "HeaderTableView.h"


//@protocol AppHeaderTableViewDelegate <HeaderTableViewDelegate>
//
//@optional
//
//@end



@interface AppHeaderTableView : HeaderTableView

@property (assign) float headerOriginY;
@property (assign) float headerOriginX;


@property (assign) float inset;
@property (assign) float headerHeight;


//@property (nonatomic, assign) id<AppHeaderTableViewDelegate> delegate;

-(void) reSetSubviewsConstraints ;

@end
