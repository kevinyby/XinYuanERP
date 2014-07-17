#import "AppModelListController.h"
#import "AppInterface.h"

#define HeaderHeight 50

@implementation AppModelListController

- (instancetype)init
{
    self = [super init];
    if (self) {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            self.headerTableView.searchBarHeight = [FrameTranslater convertCanvasHeight: 70];
            self.headerTableView.headerTableViewHeaderHeightAction = ^CGFloat(HeaderTableView* tableView){
                return [FrameTranslater convertCanvasHeight: HeaderHeight];
            };
        }
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        NSArray* headers = self.headers;
        UIView* headerView = self.headerTableView.headerView;
        for (int i = 0; i < headers.count; i++) {
            JRLocalizeLabel* label = (JRLocalizeLabel*)[headerView viewWithTag:ALIGNTABLE_HEADER_LABEL_TAG(i)];
            
            label.font = [UIFont systemFontOfSize: [FrameTranslater convertFontSize: 25]];
            [label adjustWidthToFontText];
            [label setSizeHeight: [FrameTranslater convertCanvasHeight: HeaderHeight]];
            [label setCenterY: [FrameTranslater convertCanvasHeight: HeaderHeight]/2];
            
            // for easy to click
            if (label.sizeWidth <= 38) {
                label.sizeWidth = label.sizeWidth * 3/2;
            }
        }
    }
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    // ... in filter mode selected error occured
    if (!self.headerTableView.tableView.isInFilteringMode && self.currentRow) {
        NSIndexPath* currentIndexPath = [NSIndexPath indexPathForRow:self.currentRow inSection: 0];
        [self.headerTableView.tableView selectRowAtIndexPath:currentIndexPath animated:YES scrollPosition:UITableViewScrollPositionMiddle];
    }
    
}

#pragma mark - Public Mthods

-(void) getPreviousRow: (int)idIndex handler:(void(^)(id identification))handler
{
    int temp = self.currentRow - 1;
    id identifier = nil;
    if (temp >= 0) {
        self.currentRow = temp;
        identifier = [self getCurrentIdentification: idIndex];
    }
    handler(identifier);
}

-(void) getNextRow: (int)idIndex handler:(void(^)(id identification))handler
{
    int temp = self.currentRow + 1;
    if (temp < self.amounts) {
        self.currentRow = temp;
        id identifier = [self getCurrentIdentification: idIndex];
        handler(identifier);
    } else {
        [AppRefreshTableViewController compareToSendModelRefreshRequest:self.headerTableView filter:self.contentsFilter requestModel:self.requestModel isTop:NO completion:^(BOOL isNoNewData) {
            if (isNoNewData) {
                handler(nil);
            } else {
                self.currentRow = temp;
                id identifier = [self getCurrentIdentification: idIndex];
                handler(identifier);
            }
            
            // update amounts
            self.amounts = [[self.headerTableView.tableView realContentsForSection: 0] count];
        }];
    }
}

#pragma mark - Private Methods

-(id) getCurrentIdentification: (int)idIndex
{
    NSIndexPath* currentIndexPath = [NSIndexPath indexPathForRow:self.currentRow inSection: 0];
    NSArray* values = [self valueForIndexPath: currentIndexPath];
    id identifier = [values objectAtIndex:idIndex];
    return identifier;
}


#pragma mark - Override Super Class Methods

-(void)tableViewBase:(TableViewBase *)tableViewObj didSelectIndexPath:(NSIndexPath*)indexPath{
    self.selectedIndexPath = indexPath;
    self.currentRow = indexPath.row;
    // update amounts
    self.amounts = [[self.headerTableView.tableView realContentsForSection: 0] count];
    
    // call super
    [super tableViewBase: tableViewObj didSelectIndexPath:indexPath];
}

- (void)tableViewBase:(TableViewBase *)tableViewObj willShowCell:(UITableViewCell*)cell indexPath:(NSIndexPath*)indexPath
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        for (UILabel* label in cell.contentView.subviews) {
            if([label isKindOfClass: [UILabel class]] && !label.hidden) {
                label.font = [UIFont systemFontOfSize: [FrameTranslater convertFontSize: 30]];
                [label adjustWidthToFontText];
                [label setSizeHeight: [FrameTranslater convertCanvasHeight:70]];
                [label setCenterY: [cell sizeHeight]/2];
            }
        }
    }
    [super tableViewBase:tableViewObj willShowCell:cell indexPath:indexPath];
}

- (CGFloat)tableViewBase:(TableViewBase *)tableViewObj heightForIndexPath:(NSIndexPath*)indexPath
{
    return [FrameTranslater convertCanvasHeight:UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? 80 : 50];
}


@end
