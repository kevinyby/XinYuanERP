#import <Foundation/Foundation.h>


@class TableViewBase;
@class HeaderTableView;

@interface ComponentHelper : NSObject

+(UIButton*) createButton: (int)tag title:(NSString*)title target:(id)target action:(SEL)action canvas:(CGRect)canvas;



@end
