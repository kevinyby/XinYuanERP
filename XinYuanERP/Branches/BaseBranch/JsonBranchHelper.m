#import "JsonBranchHelper.h"
#import "AppInterface.h"

@implementation JsonBranchHelper



+(void) clickHeaderLabelSortRequestAction: (JRLocalizeLabel*)label listController:(BaseOrderListController*)listController
{
    RequestJsonModel* requestModel = listController.requestModel;
    NSString* attribute = label.attribute;
    
    // just first objects default
    NSString* sortString = [[requestModel.sorts firstObject] firstObject];
    NSString* newSortString = sortString;
    if ([sortString rangeOfString: attribute].location == NSNotFound) {
        
        // if is create Date
        if ([sortString rangeOfString: PROPERTY_IDENTIFIER].location != NSNotFound && [attribute isEqualToString: PROPERTY_CREATEDATE]) {
            newSortString = [sortString stringByReplacingOccurrencesOfString: PROPERTY_IDENTIFIER withString:PROPERTY_CREATEDATE];
        } else {
            newSortString = [attribute stringByAppendingFormat:@".%@", SORT_ASC];
        }
        
    }
    
    // revert
    newSortString = [self reverseSortString: newSortString];
    [[requestModel.sorts firstObject] replaceObjectAtIndex: 0 withObject: newSortString];
    [listController requestForDataFromServer];
}

+(NSString*) reverseSortString: (NSString*)sortString
{
    NSString* newSortString = sortString;
    if ([sortString rangeOfString:SORT_ASC].location != NSNotFound) {
        newSortString = [sortString stringByReplacingOccurrencesOfString: SORT_ASC withString:SORT_DESC];
    } else if([sortString rangeOfString:SORT_DESC].location != NSNotFound) {
        newSortString = [sortString stringByReplacingOccurrencesOfString: SORT_DESC withString:SORT_ASC];
    }
    return newSortString;
}





@end
