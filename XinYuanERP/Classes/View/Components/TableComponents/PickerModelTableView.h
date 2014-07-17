#import <UIKit/UIKit.h>
#import "JRTitleHeaderTableView.h"


@interface PickerModelTableView : JRTitleHeaderTableView



-(id) initWithModel: (NSString*) model;
+(void) setEmployeesNumbersNames:(TableViewBase*)tableViewBase numbers:(NSMutableArray*)numbers;


#pragma mark - Class Pair Methods

+(PickerModelTableView*) getPickerModelView:(NSString*)model fields:(NSArray*)fields criterias:(NSDictionary*)criterias;


+(PickerModelTableView*) popupWithModel:(NSString*)model willDimissBlock:(void(^)(UIView* view))dimissBlock;
+(PickerModelTableView*) popupWithRequestModel:(NSString*)model fields:(NSArray*)fields willDimissBlock:(void(^)(UIView* view))dimissBlock;
+(void) dismiss;

@end
