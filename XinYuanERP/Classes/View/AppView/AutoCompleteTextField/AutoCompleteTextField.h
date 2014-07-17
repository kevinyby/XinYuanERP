#import <UIKit/UIKit.h>
#import "TableViewBase.h"
#import "NormalTextField.h"

@class FilterTableView;
@class AutoCompleteTextField;


@protocol AutoCompleteTextFieldDelegate <UITextFieldDelegate>

@optional
-(void) autoCompleteTextField:(AutoCompleteTextField*)textField didSelectIndexPath:(NSIndexPath *)indexPath;

@end




@interface AutoCompleteTextField : NormalTextField <TableViewBaseTableProxy>

@property (strong) FilterTableView* tableView;

@property(nonatomic,assign) id<AutoCompleteTextFieldDelegate> delegate;


-(id) value;            // the selected real value
-(NSIndexPath*) index;  // the selected index path

@end
