#import <UIKit/UIKit.h>
#import "NormalLabel.h"
#import "JRViewProtocal.h"

@interface JRLabel : NormalLabel <JRComponentProtocal>

@property (strong) NSString* cnSpace;
@property (strong) NSString* enSpace;

// ______________

@property (assign) BOOL isReserveCenter;       // when adjust to the text length,
                                            // the center will be changed.


@property (assign) BOOL disableChangeTextTransition;

@end
