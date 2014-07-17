#import "JRBaseView.h"

@class JRComplexView;
typedef id(^JRComplexViewGetValueBlock)(JRComplexView* complexView);
typedef void(^JRComplexViewSetValueBlock)(JRComplexView* complexView, id value);

@interface JRComplexView : JRBaseView

@property (copy) JRComplexViewGetValueBlock getJRComplexViewValueBlock;
@property (copy) JRComplexViewSetValueBlock setJRComplexViewValueBlock;

id getJRComplexViewValue (id self, SEL _cmd);
void setJRComplexViewValue (id self, SEL _cmd, id value);


-(UIView*) getView: (NSString*)key;

@end
