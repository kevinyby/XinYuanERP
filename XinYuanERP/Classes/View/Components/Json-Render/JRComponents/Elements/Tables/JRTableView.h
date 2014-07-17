#import "TableViewBase.h"
#import "JRViewProtocal.h"

@interface JRTableView : TableViewBase <JRComponentProtocal>

@property (copy) id(^JRTableViewGetValue)(JRTableView* tableViewObj);
@property (copy) void(^JRTableViewSetValue)(JRTableView* tableViewObj, id value);

#pragma mark - Class Methods
+(void) setCellColorImages:(TableViewBase*)tableView config:(NSDictionary*)config;
+(void) setTableViewCellAttributes: (UITableViewCell*)cell config:(NSDictionary*)config;
+(void) setTableViewAttributes:(TableViewBase*)tableView config:(NSDictionary*)config;

@end
