#import "JRRefreshTableView.h"
#import "AppInterface.h"

@implementation JRRefreshTableView
{
    NSString* _attribute ;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.topView.refreshTopViewLabelTextForStateAction = ^NSString*(RefreshElementState state){
            if (state == RefreshElementStateNormal) {
                return LOCALIZE_MESSAGE(@"RefreshWithPullDown");
            } else if (state == RefreshElementStatePulling) {
                return LOCALIZE_MESSAGE(@"RefreshWithRelease");
            } else if (state == RefreshElementStateLoading) {
                return LOCALIZE_MESSAGE(@"RefreshWithLoading");
            }
            return nil;
        };
        self.searchBar.textField.placeholder = LOCALIZE_KEY(@"SEARCH");
    }
    return self;
}



#pragma mark - JRComponentProtocal Methods
-(void) initializeComponents: (NSDictionary*)config
{
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
    [JRTableView setCellColorImages: self.tableView config:dictionary];
    [JRTableView setTableViewAttributes: self.tableView config:dictionary];

    [JRRefreshTableView setRefreshTableViewAttributs: self config:dictionary];
}

-(id) getValue {
    id result = nil;
    if (self.JRRefreshTableViewGetValue) {
        result = self.JRRefreshTableViewGetValue(self);
    }
    return result;
}

-(void) setValue: (id)value {
    if (self.JRRefreshTableViewSetValue) {
        self.JRRefreshTableViewSetValue(self, value);
    }
}
















#pragma mark - Class Methods
+(void) setRefreshTableViewAttributs: (JRRefreshTableView*)refreshTableView config:(NSDictionary*)config
{
    if (config[k_JR_TBL_HIDESEARCH]) {
        refreshTableView.hideSearchBar = [config[k_JR_TBL_HIDESEARCH] boolValue];
    }
    if (config[k_JR_TBL_HIDEREFRESH]) {
        refreshTableView.disableTriggered = [config[k_JR_TBL_HIDEREFRESH] boolValue];
    }
    
    // header color
    if (config[k_JR_TBL_headerColor]) refreshTableView.headerView.backgroundColor = [ColorHelper parseColor: config[k_JR_TBL_headerColor]];;
        
    // header properties
    if (config[k_JR_TBL_headerGap]) {
        float gap = [config[k_JR_TBL_headerGap] floatValue];
        float convertGap = [FrameTranslater convertCanvasHeight: gap];
        refreshTableView.headerTableViewGapAction = ^CGFloat(HeaderTableView* view) {
            return convertGap;
        };
    }
    if (config[k_JR_TBL_headerHeight]) {
        float convertHeight = [FrameTranslater convertCanvasHeight: [config[k_JR_TBL_headerHeight] floatValue]];
        refreshTableView.headerTableViewHeaderHeightAction = ^CGFloat(HeaderTableView* view) {
            return convertHeight;
        };
    }
    
    // headers , headers and values coordinates
    if (config[k_JR_TBL_headers]) refreshTableView.headers = [LocalizeHelper localize: config[k_JR_TBL_headers]];
    if (config[k_JR_TBL_headersX]) refreshTableView.headersXcoordinates = config[k_JR_TBL_headersX];
    if (config[k_JR_TBL_valuesX]) refreshTableView.valuesXcoordinates = config[k_JR_TBL_valuesX];
    if (config[k_JR_TBL_headersY]) refreshTableView.headersYcoordinates = config[k_JR_TBL_headersY];
    if (config[k_JR_TBL_valuesY]) refreshTableView.valuesYcoordinates = config[k_JR_TBL_valuesY];
    
    
}

@end
