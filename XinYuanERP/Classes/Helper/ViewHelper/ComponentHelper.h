#import <Foundation/Foundation.h>


@class TableViewBase;
@class HeaderTableView;
@class AutoCompleteTextField;

@interface ComponentHelper : NSObject

+(UIButton*) createButton: (int)tag title:(NSString*)title target:(id)target action:(SEL)action canvas:(CGRect)canvas;


+(AutoCompleteTextField*) createAutoCompleteTextField: (UIReturnKeyType)returnKeyType delegate:(id)delegate;


@end
