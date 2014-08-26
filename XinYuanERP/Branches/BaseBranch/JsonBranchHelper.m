#import "JsonBranchHelper.h"
#import "AppInterface.h"

@implementation JsonBranchHelper


+(void) iterateHeaderJRLabel: (BaseOrderListController*)listController handler:(BOOL(^)(JRLocalizeLabel* label, int index, NSString* attribute))handler
{
    NSArray* headers = listController.headers;
    UIView* headerView = listController.headerTableView.headerView;
    for (int i = 0; i < headers.count; i++) {
        NSString* attribute = headers[i];
        JRLocalizeLabel* jrLabel = (JRLocalizeLabel*)[headerView viewWithTag:ALIGNTABLE_HEADER_LABEL_TAG(i)];
        if (handler) {
            if (handler(jrLabel, i, attribute)) {
                return;
            }
        }
    }
}

+(JRLocalizeLabel*) getHeaderJRLabelByAttribute: (BaseOrderListController*)listController attribute:(NSString*)attribute
{
    NSArray* headers = listController.headers;
    UIView* headerView = listController.headerTableView.headerView;
    for (int i = 0; i < headers.count; i++) {
        JRLocalizeLabel* jrLabel = (JRLocalizeLabel*)[headerView viewWithTag:ALIGNTABLE_HEADER_LABEL_TAG(i)];
        if ([jrLabel.attribute isEqualToString: attribute]) {
            return jrLabel;
        }
    }
    return nil;
}


+(void) navigateToOrderController: (NSString*)department order:(NSString*)order identifier:(id)identifier
{
    JsonController* jsonController = [JsonBranchHelper getNewJsonControllerInstance: department order:order];
    jsonController.controlMode = JsonControllerModeRead;
    jsonController.identification = identifier;
    
    [VIEW.navigator pushViewController: jsonController animated:YES];
}





+(JsonController*) getNewJsonControllerInstance:(NSString*)department order:(NSString*)order
{
    // controller
    NSString* controllerCalzzstring = [NSString stringWithFormat: @"%@%@", order, @"Controller"];
    Class controllerCalzz = NSClassFromString(controllerCalzzstring);
    if (controllerCalzz == Nil) controllerCalzz = [JsonController class];
    JsonController* jsonController = [[controllerCalzz alloc] init];
    jsonController.order = order;
    jsonController.department = department;
    jsonController.controlMode = JsonControllerModeNull;
    return jsonController;
}


+(NSDictionary*) getModelsListSpecification: (NSString*)department
{
    NSString* departmentListFileName = [department stringByAppendingString: @"List.json"];
    NSDictionary* result = [JsonFileManager getJsonFromFile: departmentListFileName];
    return result;
}

+(NSDictionary*) getModelsListSpecification: (NSString*)department order:(NSString*)order
{
    NSDictionary* result = [self getModelsListSpecification: department];
    if (order) {
        result = result[order];
    }
    return result;
}







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
