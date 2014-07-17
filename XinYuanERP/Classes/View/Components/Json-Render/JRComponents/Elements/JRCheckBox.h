#import <Foundation/Foundation.h>
#import "JRViewProtocal.h"
#import "JRButton.h"

@interface JRCheckBox: JRButton

@property (nonatomic, assign, setter = setChecked:) BOOL checked;

@property (nonatomic, copy) void (^stateChangedBlock)(JRCheckBox *checkBox);

@end
