#import <UIKit/UIKit.h>
#import "NormalButton.h"
#import "JRViewProtocal.h"

typedef id(^JRButtonGetValueBlock)(id button);
typedef void(^JRButtonSetValueBlock)(id button, id value);

@interface JRButton : NormalButton <JRComponentProtocal>

@property (strong) NSString* cnSpace;
@property (strong) NSString* enSpace;

@property (copy) JRButtonGetValueBlock getJRButtonValueBlock;
@property (copy) JRButtonSetValueBlock setJRButtonValueBlock;


@end
