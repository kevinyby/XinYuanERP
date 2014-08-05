#import "ContentFilterHelper.h"
#import "AppInterface.h"


// some pre define content filter
ContentFilterElementBlock nilContentFilter = ^id(id cellElement, NSMutableArray* cellRepository)
{
    return nil;
};

ContentFilterElementBlock numberNameContentFilter = ^id(id cellElement, NSMutableArray* cellRepository)
{
    NSString* employeename  = [DATA.usersNONames objectForKey: cellElement];
    if (cellElement) [cellRepository addObject: cellElement];
    if (employeename) [cellRepository addObject: employeename];
    return nil;
};

ContentFilterElementBlock dateContentFilter = ^id(id cellElement, NSMutableArray* cellRepository)
{
    NSDateFormatter* dateformat = [DateHelper getDefaultDateFormater];
    if ([dateformat dateFromString: cellElement]) {
        cellElement =  [DateHelper stringFromString: cellElement fromPattern:PATTERN_DATE_TIME toPattern:PATTERN_DATE];
    }
    return cellElement;
    
};

ContentFilterElementBlock localizeContentFilter = ^id(id cellElement, NSMutableArray* cellRepository)
{
    return LOCALIZE_KEY(cellElement);
};

ContentFilterElementBlock localizeUpperCaseContentFilter = ^id(id cellElement, NSMutableArray* cellRepository)
{
    return LOCALIZE_KEY([cellElement uppercaseString]);
};

ContentFilterElementBlock exchangeIndexesContentFilter = ^id(id cellElement, NSMutableArray* cellRepository)
{
    return nil;
};





@implementation ContentFilterHelper


NSDictionary* contentFiltersMap = nil;
+(void)initialize
{
    contentFiltersMap = @{
                          list_FILTER_NIL: nilContentFilter,
                          list_FILTER_NumberName: numberNameContentFilter,
                          list_FILTER_Date: dateContentFilter,
                          list_FILTER_Localize : localizeContentFilter,
                          list_FILTER_LocalizeUpperCase: localizeUpperCaseContentFilter
                          };
}


+(NSDictionary*) contentFiltersMap
{
    return contentFiltersMap;
}



@end
