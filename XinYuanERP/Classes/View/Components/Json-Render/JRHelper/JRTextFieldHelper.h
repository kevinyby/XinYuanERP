
#import "JRViewProtocal.h"
@interface JRTextFieldHelper : NSObject


+(BOOL) isKeyBoardShowing;

+(void) setTextFieldDelegateAdjustKeyboard: (id<JRTopViewProtocal>)jrTopViewProtocal;

+(void) adjustKeyBoardPositions: (UIView *)textFieldView;

@end
