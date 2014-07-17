#import "JRTitleHeaderTableView.h"
#import "AppInterface.h"

@interface JRTitleHeaderTableView () <TableViewBaseTableProxy>

@end

@implementation JRTitleHeaderTableView
{
    NSString* _attribute ;
}

#pragma mark - JRComponentProtocal Methods
-(void) initializeComponents: (NSDictionary*)config
{
    [super initializeComponents:config];
}

-(NSString*) attribute
{
    return _attribute;
}

-(void) setAttribute: (NSString*)attribute
{
    _attribute = attribute;
}

-(void) subRender: (NSDictionary*)dictionary
{
    [super subRender: dictionary];
}

-(id) getValue {
    return nil;
}

-(void) setValue: (id)value {
}






@synthesize headerView;
@synthesize titleLabel;
@synthesize tableView;
@synthesize footerView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initializeSubViews];
        
        [tableView setTranslatesAutoresizingMaskIntoConstraints: NO];
        [headerView setTranslatesAutoresizingMaskIntoConstraints: NO];
        [footerView setTranslatesAutoresizingMaskIntoConstraints: NO];
        
        [self refreshSubviewsConstraints];
    }
    return self;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    [titleLabel setCenterX: [titleLabel.superview sizeWidth] / 2];
    [titleLabel setCenterY: [titleLabel.superview sizeHeight] / 2];
}


-(void) initializeSubViews
{
    // headerView
    headerView = [[UIView alloc] init];
    headerView.backgroundColor = [UIColor flatBlueColor];
    [headerView setSizeHeight: [FrameTranslater convertCanvasHeight: 60]];  // default
    [self addSubview: headerView];
    
    // titleLabel
    titleLabel = [[JRLocalizeLabel alloc] init];
    [FrameHelper setFrame: CGRectMake(0, 0, 200, 50) view:titleLabel];  // default
    titleLabel.font = [UIFont systemFontOfSize:[FrameTranslater convertFontSize: 18]];
    titleLabel.labelDidSetTextBlock = ^(NormalLabel* label, NSString* newText, NSString* oldText){
        [label adjustWidthToFontText];
    };
    [headerView addSubview: titleLabel];
    
    
    // tableView
    tableView = [[JRRefreshTableView alloc] init];
    tableView.headerView.backgroundColor = [ColorHelper parseColor:@[@(220),@(220),@(220),@(1)]];
    tableView.tableView.proxy = self;
    [tableView.searchBar setHiddenCancelButton: YES];
//    [tableView setHideSearchBar: YES];
    [self addSubview: tableView];
    
    tableView.disableTriggered = YES;
    tableView.tableView.tableViewBaseHeightForIndexPathAction = ^CGFloat(TableViewBase* tableViewObj, NSIndexPath* indexPath) {
        return [FrameTranslater convertCanvasHeight: UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? 80 : 50];
    };
    tableView.tableView.tableViewBaseWillShowCellAction = ^void(TableViewBase* tableViewObj,UITableViewCell* cell, NSIndexPath* indexPath){
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
    };
    
    
    // footerView
    footerView = [[UIView alloc] init];
    [self addSubview: footerView];
    
}


-(void) refreshSubviewsConstraints
{
    [self removeConstraints: self.constraints];
    
    [self setupHorizontalContrainst];
    [self setupVerticalContraints];
}

-(void) setupHorizontalContrainst
{
    [self addConstraints: [NSLayoutConstraint
                           constraintsWithVisualFormat:@"|-0-[tableView]-0-|"
                           options:NSLayoutFormatDirectionLeadingToTrailing
                           metrics:nil
                           views:NSDictionaryOfVariableBindings(tableView)]];
    [self addConstraints: [NSLayoutConstraint
                           constraintsWithVisualFormat:@"|-0-[headerView]-0-|"
                           options:NSLayoutFormatDirectionLeadingToTrailing
                           metrics:nil
                           views:NSDictionaryOfVariableBindings(headerView)]];
    [self addConstraints: [NSLayoutConstraint
                           constraintsWithVisualFormat:@"|-0-[footerView]-0-|"
                           options:NSLayoutFormatDirectionLeadingToTrailing
                           metrics:nil
                           views:NSDictionaryOfVariableBindings(footerView)]];
}


-(void) setupVerticalContraints
{
    CGFloat footerHeight = [footerView sizeHeight];
    CGFloat headerHeight = [headerView sizeHeight];
    [self addConstraints: [NSLayoutConstraint
                           constraintsWithVisualFormat:@"V:|-0-[headerView(headerHeight)][tableView][footerView(footerHeight)]-0-|"
                           options:NSLayoutFormatDirectionLeadingToTrailing
                           metrics:@{@"footerHeight":@(footerHeight), @"headerHeight":@(headerHeight)}
                           views:NSDictionaryOfVariableBindings(tableView, headerView, footerView)]];
}


#pragma mark - TableViewBaseTableProxy Methods
- (void)tableViewBase:(TableViewBase *)tableViewObj didSelectIndexPath:(NSIndexPath*)indexPath
{
    if (self.titleHeaderViewDidSelectAction) self.titleHeaderViewDidSelectAction(self, indexPath, tableViewObj);
}


@end
