#import "AutoCompleteTextField.h"
#import "FilterTableView.h"
#import "ClassesInterface.h"

@interface AutoCompleteTextField()

// shadow
@property (assign) CGColorRef originalShadowColor;
@property (assign) CGSize originalShadowOffset;
@property (assign) CGFloat originalShadowOpacity;

//default is 0.15, if you fetch from a web service you may want this higher to prevent multiple calls happening very quickly.
@property (assign) NSTimeInterval autoCompleteFetchRequestDelay;


@end

@implementation AutoCompleteTextField
{
    NSIndexPath* _index;
}

@synthesize tableView;

- (id)init
{
    self = [super init];
    if (self) {
        [self beginNotifications];
        
        //    self.clearsOnBeginEditing = YES;
        
        self.autoCompleteFetchRequestDelay = 0.15;
        tableView = [[FilterTableView alloc] init];
        tableView.proxy = self;
        tableView.filterMode = FilterModeBeginWith;
        [ColorHelper setBorder: tableView color:[UIColor flatBlackColor]];

    }
    return self;
}

-(void)setFrame:(CGRect)frame
{
    [super setFrame: frame];
    
    [tableView setSizeWidth: 2 * frame.size.width];
    int mul = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 8 : 11;
    [tableView setSizeHeight: mul * frame.size.height];
    
}

#pragma mark - Notifications and KVO

-(void) beginNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldTextDidChangeNotification:) name:UITextFieldTextDidChangeNotification object:self];
}

-(void) textFieldTextDidChangeNotification: (NSNotification*)notification
{
    if (notification.object == self) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(loadAutoCompletes) object:nil];
        [self performSelector:@selector(loadAutoCompletes) withObject:nil afterDelay:self.autoCompleteFetchRequestDelay];
    }
}

#pragma mark - Events

-(BOOL)becomeFirstResponder
{
    [self restoreShadow];
    [self saveShadow];
    [self setShadow];
    
    UIView* topView = [[[UIApplication sharedApplication].keyWindow subviews] firstObject];
    [tableView setOrigin: [self convertPoint: (CGPoint){0, self.frame.size.height} toView:topView]];
    [topView addSubview: tableView];
    
    [self loadAutoCompletes];
    
    return [super becomeFirstResponder];
}

-(BOOL)resignFirstResponder
{
    [self restoreShadow];
    [tableView removeFromSuperview];
    
    if (tableView.seletedVisibleIndexPath) {
        self.text = [tableView contentForIndexPath: tableView.seletedVisibleIndexPath];
    } else {
        self.text = nil;
    }
    
    return [super resignFirstResponder];
}

-(NSIndexPath *)index
{
    return _index;
}

-(id)value
{
    return _index == nil ? nil : [self.tableView realContentForIndexPath: _index];
}

#pragma mark - Shadow

- (void)saveShadow
{
    [self setOriginalShadowColor:self.layer.shadowColor];
    [self setOriginalShadowOffset:self.layer.shadowOffset];
    [self setOriginalShadowOpacity:self.layer.shadowOpacity];
}

-(void) setShadow
{
    [self.layer setShadowColor: [[UIColor blackColor] CGColor]];
    [self.layer setShadowOffset: CGSizeMake(0, 1)];
    [self.layer setShadowOpacity: 0.35];
}

-(void) restoreShadow
{
    [self.layer setShadowColor:self.originalShadowColor];
    [self.layer setShadowOffset:self.originalShadowOffset];
    [self.layer setShadowOpacity:self.originalShadowOpacity];
}

// after renew autoCompleteTableView's contentdictionary , call it
- (void)loadAutoCompletes
{
    [self.tableView setFilterText: self.text];
}


#pragma mark - TableViewBaseTableProxy 
- (void)tableViewBase:(TableViewBase *)tableViewObj didSelectIndexPath:(NSIndexPath*)indexPath
{
    _index = indexPath;     // against to realcontentdictionary
    NSString* cellText = [tableView contentForIndexPath: tableView.seletedVisibleIndexPath];
    self.text = cellText;

    [tableView removeFromSuperview];
    
    if (self.delegate && [self.delegate respondsToSelector: @selector(autoCompleteTextField:didSelectIndexPath:)]) {
        [self.delegate autoCompleteTextField:self didSelectIndexPath:indexPath];
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver: self];
}

@end
