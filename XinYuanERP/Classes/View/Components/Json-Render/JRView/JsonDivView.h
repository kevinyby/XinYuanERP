#import "JRViewProtocal.h"

@interface JsonDivView : UIControl <JRTopViewProtocal>

#pragma mark - JRTopViewProtocal Methods

@property (strong) NSString* attribute;
@property (strong) NSDictionary* specifications;

@end
