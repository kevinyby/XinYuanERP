#import "ZoomableScrollView.h"
#import "JRViewProtocal.h"

@interface JsonView : ZoomableScrollView <JRTopViewProtocal>

#pragma mark - JRTopViewProtocal Methods

@property (strong) NSString* attribute;
@property (strong) NSDictionary* specifications;

@end
