#import "JsonOrderCreateHelper.h"
#import "AppInterface.h"

@implementation JsonOrderCreateHelper



///////_____________________________________________ Pop Cannot Create Alert Cause Other Order Approval ____________________________
+(void) cannotCreateAlert: (NSString*)order causeOrder:(NSString*)orderType department:(NSString*)department identifier:(id)identifier employeeNO:(NSString*)employeeNO objects:(NSDictionary*)objects
{
    NSString* currentApprovingLevel = [JsonControllerHelper getCurrentApprovingLevel: orderType valueObjects:objects];
    
    NSString* message = LOCALIZE_MESSAGE_FORMAT(@"HaveAnOrderApproving", employeeNO, LOCALIZE_KEY(orderType), LOCALIZE_KEY(currentApprovingLevel));
    message = [message stringByAppendingFormat:@", %@", APPLOCALIZE_KEYS(@"cannot", @"create", order)];
    
    [PopupViewHelper popAlert: nil message:message style:0 actionBlock:^(UIView *popView, NSInteger index) {
        if (index == 1) {
            [OrderListControllerHelper navigateToOrderController: department order:orderType identifier:identifier];
        }
    } dismissBlock:nil buttons:LOCALIZE_KEY(KEY_CANCEL), LOCALIZE_KEY(@"read"), nil];
}


@end
