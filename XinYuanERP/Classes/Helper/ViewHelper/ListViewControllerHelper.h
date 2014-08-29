#import "AppSearchTableViewController.h"

@class ResponseJsonModel;
@class OrderListControllerHelper;
@class AppSearchTableViewController;
@class BaseOrderListController;

@interface ListViewControllerHelper : NSObject

#pragma mark - Temp
// array with dic
+(NSMutableArray*) assemble:(NSArray*)array keys:(NSArray*)keys;
+(NSMutableArray*) assembleDictionary:(NSDictionary*)contents keys:(NSArray*)keys;



+(void) assembleTableContents: (TableViewBase*)controller objects:(NSArray*)objects keys:(NSArray*)keys filter:(ContentFilterBlock)filter;

#pragma mark - Handler Real Content Dictionary & Content Dictionary
+(NSMutableDictionary*) convertRealToVisualContents: (NSDictionary*)realContentsDictionary filter:(ContentFilterBlock)filter;









#pragma mark - Exception Icon

+(void) setupExceptionAttributes: (BaseOrderListController*)listController order:(NSString*)order;

+(NSUInteger) modifyRequestFields: (RequestJsonModel*)requestModel order:(NSString*)order;

+(ContentFilterBlock) getExceptionContentFilter: (ContentFilterBlock)previousFilter order:(NSString*)order exceptionIndex:(NSUInteger)exceptionIndex;

+(WillShowCellBlock) getExceptionWillShowCellBlock: (WillShowCellBlock)previousWillShow exceptionIndex:(NSUInteger)exceptionIndex;


+(UIImageView*) getImageViewInCellTail: (NSString*)imageName cell:(UITableViewCell*)cell;

+(UIImageView*) getImageViewInCell: (UITableViewCell*)cell imageName:(NSString*)imageName centerX:(CGFloat)centerX tag:(NSInteger)tag;


@end
