#import "JRLabel.h"

@interface JRLocalizeLabel : JRLabel

@property (copy, nonatomic) void(^jrLocalizeLabelDidClickAction)(JRLocalizeLabel* label);

@end
