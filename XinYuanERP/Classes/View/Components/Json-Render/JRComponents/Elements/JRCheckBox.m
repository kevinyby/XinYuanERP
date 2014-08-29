#import "JRCheckBox.h"
#import "JRComponents.h"

@implementation JRCheckBox
{
    NSString* _attribute ;
    
    
    // ----
    UIImage* checkImage;
    UIImage* uncheckImage;
}


#pragma mark - JRComponentProtocal Methods

-(void) subRender: (NSDictionary*)dictionary {
    [super subRender: dictionary];
    
    if(dictionary[k_JR_Check_IMG])checkImage = [UIImage imageNamed:dictionary[k_JR_Check_IMG]];
    if(dictionary[k_JR_UNCheck_IMG])uncheckImage = [UIImage imageNamed: dictionary[k_JR_UNCheck_IMG]];
    [self updateImage];
}

-(id) getValue {
    return [NSNumber numberWithBool: self.checked];
}

-(void) setValue: (id)value {
    self.checked = [value boolValue];
}


#pragma mark -

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initializeProperties];
    }
    return self;
}

-(void) initializeProperties {
    // default images
    NSString* checkImageStr = @"cb_mono_on";
    NSString* uncheckImageStr = @"cb_mono_off";
    checkImage = [UIImage imageNamed:checkImageStr];
    uncheckImage = [UIImage imageNamed: uncheckImageStr];
    
    self.checked = NO;
    self.stateChangedBlock = nil;
    self.userInteractionEnabled = YES;
    self.backgroundColor = [UIColor clearColor];
    
    __weak JRCheckBox* weakSelf = self;
    self.didClikcButtonAction = ^void(id sender){
        weakSelf.checked = !weakSelf.checked;
        if (weakSelf.stateChangedBlock) weakSelf.stateChangedBlock(weakSelf);
    };
}

- (void) setChecked:(BOOL)isChecked
{
    _checked = isChecked;
    [self updateImage];
}

-(void) updateImage
{
    UIImage* image = _checked ? checkImage : uncheckImage;
    [self setImage:image forState:UIControlStateNormal];
}


@end
