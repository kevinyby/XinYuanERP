#import <Foundation/Foundation.h>



@class OrderSearchListViewController;



@interface OrderSearchListViewHelper : NSObject


#pragma mark -

+(NSString*) getImageFolderName:(OrderSearchListViewController*)listController indexPath:(NSIndexPath*)realIndexPath;

+(NSString*) getDeleteImageFolderProperty: (NSString*)department order:(NSString*)order;

+(void) deleteWithCheckPermission:(NSString*)orderType deparment:(NSString*)department identification:(id)identification tips:(NSString*)tips handler:(void(^)(bool isSuccess))handler;


@end
