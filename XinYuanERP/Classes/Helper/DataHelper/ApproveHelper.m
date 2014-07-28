#import "ApproveHelper.h"
#import "AppInterface.h"

@implementation ApproveHelper

#pragma mark - Checkout the pending approvals and badge icon number

+(void) refreshBadgeIconNumber: (NSString*)user
{
    if (! user) {
        return;
    }
    RequestJsonModel* requestModel = [RequestJsonModel getJsonModel];
    requestModel.path = PATH_LOGIC_READ(CATEGORIE_APPROVAL);
    [requestModel.fields addObject:@[@"pendingApprovalsCount"]];
    [requestModel.models addObjectsFromArray:@[@".Approvals"]];
    [requestModel addObject:@{PROPERTY_EMPLOYEENO: user}];
    [DATA.requester startPostRequest:requestModel completeHandler:^(HTTPRequester* requester, ResponseJsonModel *data, NSHTTPURLResponse *httpURLReqponse, NSError *error) {
        NSArray* results = [data.results firstObject];
        int approvalCount = [[results firstObject] intValue] ;
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:approvalCount];
        
    }];
}

+(int) getPendingOrdersCount: (NSString*)pendingApprovalStr
{
    int count = 0 ;
    if (OBJECT_EMPYT(pendingApprovalStr)) {
        return 0 ;
    }
    NSDictionary* pendingApprovals = [CollectionHelper convertJSONStringToJSONObject: pendingApprovalStr];
    NSDictionary* ordersApprovals = [DictionaryHelper convertToOneDimensionDictionary: pendingApprovals];
    for (NSString* key in ordersApprovals) {
        NSArray* orderNOs = [ordersApprovals objectForKey: key];
        count += orderNOs.count;
    }
    return count;
}

@end
