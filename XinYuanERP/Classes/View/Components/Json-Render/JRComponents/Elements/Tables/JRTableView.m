#import "JRTableView.h"
#import "JRComponents.h"
#import "AppInterface.h"

@implementation JRTableView
{
    NSString* _attribute ;
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
    [JRTableView setCellColorImages: self config:dictionary];
    [JRTableView setTableViewAttributes: self config:dictionary];
}

-(id) getValue {
    id result = nil;
    if (self.JRTableViewGetValue) {
        result = self.JRTableViewGetValue(self);
    }
    return result;
}

-(void) setValue: (id)value {
    if (self.JRTableViewSetValue) {
        self.JRTableViewSetValue(self, value);
    }
}




#pragma mark - Class Methods

+(void) setCellColorImages: (TableViewBase*)tableView config:(NSDictionary*)config
{
    tableView.tableViewBaseCellForIndexPathAction = ^UITableViewCell*(TableViewBase* tableViewObj, NSIndexPath* indexPath, UITableViewCell* oldCell){
        [JRTableView setTableViewCellAttributes: oldCell config:config];
        return oldCell;
    };
}

+(void) setTableViewCellAttributes: (UITableViewCell*)cell config:(NSDictionary*)config {
    
    // add image view
    if ([config objectForKey: k_JR_CELLBGN_Image]){
        
        UIImageView* bgImageView = (UIImageView*)[cell viewWithTag: 4043];
        if (! bgImageView) {
            UIImage* bgImage = [UIImage imageNamed:[config objectForKey: k_JR_CELLBGN_Image]];
            if (bgImage) {
                // hight light image
                UIImage* hightlightBGImage = [UIImage imageNamed:[config objectForKey: k_JR_CELLBGH_Image]];
                if (!hightlightBGImage) hightlightBGImage = [ImageHelper applyingAlphaToImage: bgImage alpha:0.5];
                
                // add image view
                bgImageView = [[UIImageView alloc] initWithImage:bgImage highlightedImage:hightlightBGImage];
                bgImageView.frame = CGRectMake(0, 0, bgImage.size.width, bgImage.size.height);
                bgImageView.tag = 4043;
                [cell addSubview: bgImageView];
                [cell sendSubviewToBack: bgImageView];
            }
        }
        
    }
    
    // border color , background color, radius
    id borderColorOBJ = [config objectForKey: k_JR_CELL_BORDER];
    if (borderColorOBJ) {
        [ColorHelper setBorder: cell color:borderColorOBJ];
    }
    
    id backgroundColorOBJ = [config objectForKey: k_JR_CELL_BGCOLOR];
    if (backgroundColorOBJ) {
        [ColorHelper setBackGround: cell color:backgroundColorOBJ];
    }
    
    id radiusOBJ = [config objectForKey: k_JR_CELL_RADIUS];
    if (radiusOBJ) {
        cell.layer.cornerRadius = [radiusOBJ floatValue];
        cell.layer.masksToBounds = YES;
    }
}

+(void) setTableViewAttributes:(TableViewBase*)tableView config:(NSDictionary*)config
{
    [JsonViewHelper setViewSharedAttributes: tableView config:config];

    if (config[k_JR_TBL_HIDESECTION]) tableView.hideSections = [config[k_JR_TBL_HIDESECTION] boolValue];
    if (config[k_JR_TBL_SECTIONHEIGHT]) {
        float convertHeight = [FrameTranslater convertCanvasHeight: [config[k_JR_TBL_SECTIONHEIGHT] floatValue]];
        tableView.tableViewBaseHeightForSectionAction = ^CGFloat(TableViewBase* tableViewObj,NSInteger section) {
            return convertHeight;
        };
    }
    if (config[k_JR_TBL_SHOWLINENOCONTENTS] && [config[k_JR_TBL_SHOWLINENOCONTENTS] boolValue]) tableView.tableFooterView = nil;
    if (config[k_JR_TBL_CELLHEIGHT]) {
        CGFloat canvasHeight = [config[k_JR_TBL_CELLHEIGHT] floatValue];
        CGFloat height = [FrameTranslater convertCanvasHeight: canvasHeight];
        tableView.tableViewBaseHeightForIndexPathAction = ^CGFloat(TableViewBase* tableViewObj, NSIndexPath* indexPath){
            return height;
        };
    }
}

@end
