#import "BaseController.h"

#import "TableViewBase.h"
#import "JRRefreshTableView.h"
#import "ContentFilterHelper.h"

@class RequestJsonModel;
@class ResponseJsonModel;
@class AppSearchTableViewController;


typedef void(^AppTableControllerDidSelectRowBlock) (AppSearchTableViewController* controller ,NSIndexPath* realIndexPath);
typedef void(^WillShowCellBlock) (AppSearchTableViewController* controller ,NSIndexPath* indexPath, UITableViewCell* cell);

@interface AppSearchTableViewController : BaseController <TableViewBaseTableProxy>

@property (strong) JRRefreshTableView *headerTableView;

@property (assign) BOOL isPopNeedRefreshRequest;            // a queue will be better ...
@property (strong) RequestJsonModel* requestModel;

@property (strong, nonatomic) NSArray* headers ;                // array of string
@property (strong, nonatomic) NSArray* headersXcoordinates;     // array of number
@property (strong, nonatomic) NSArray* valuesXcoordinates;      // array of number

@property (copy) ContentFilterBlock contentsFilter;
@property (copy) AppTableControllerDidSelectRowBlock appTableDidSelectRowBlock;
@property (copy) WillShowCellBlock willShowCellBlock;


#pragma mark - Subclass Optional Override Methods
-(void) requestForDataFromServer ;
-(void) didReceiveDataFromServer: (ResponseJsonModel*)data error:(NSError*)error;

#pragma mark - Public Methods
-(void) reloadTableData ;
-(NSArray*) sections ;

-(NSMutableDictionary*) realContentsDictionary;
-(void) setRealContentsDictionary:(NSMutableDictionary *)realContentsDictionary;

-(NSMutableDictionary*) contentsDictionary;
-(void) setContentsDictionary:(NSMutableDictionary *)contentsDictionary;


-(id) valueForIndexPath: (NSIndexPath*)indexPath;
-(id) getIdentification: (NSIndexPath*)indexPath;


#pragma mark - For Subclass Override Methods

-(void) appSearchTableViewController: (AppSearchTableViewController*)controller didSelectIndexPath:(NSIndexPath*)indexPath;

@end
