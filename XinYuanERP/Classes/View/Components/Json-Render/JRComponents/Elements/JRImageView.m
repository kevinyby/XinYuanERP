
#import "JRImageView.h"
#import "JRComponents.h"
#import "ClassesInterface.h"


@implementation UIImage (NewGenerate)


const char* isNewGeneratedKey = "isNewGeneratedKey";

-(BOOL) isNewGenerated
{
    NSNumber* isNewNum = objc_getAssociatedObject(self, isNewGeneratedKey);
    return [isNewNum boolValue];
}

-(void) setIsNewGenerated: (BOOL) isNew
{
    NSNumber* isNewNum = [NSNumber numberWithBool: isNew];
    objc_setAssociatedObject(self, isNewGeneratedKey, isNewNum, OBJC_ASSOCIATION_RETAIN);
}

@end



@interface JRImageView ()
{
    UITapGestureRecognizer* tapGestureRecognizer;
    UITapGestureRecognizer* doubleTapGestureRecognizer;
}

@end

@implementation JRImageView
{
    NSString* _attribute ;
}

#pragma mark - JRComponentProtocal Methods
-(void) initializeComponents: (NSDictionary*)config
{
}

-(NSString*) attribute
{
    return _attribute;
}

-(void) setAttribute: (NSString*)attribute
{
    _attribute = attribute;
}

-(void) subRender: (NSDictionary*)dictionary
{
    // border radius
    if (dictionary[k_JR_CORNERRADIUS]) {
        self.layer.cornerRadius = [dictionary[k_JR_CORNERRADIUS] floatValue];
        self.clipsToBounds = YES;
    }
    
    
    if (dictionary[k_JR_ENABLE]) {
        self.userInteractionEnabled = [dictionary[k_JR_ENABLE] boolValue];
    }
    
    // image
    NSString* imageName = [dictionary objectForKey: k_JR_Image];
    UIImage* image = [UIImage imageNamed:imageName];
    self.image = image;
    if (image) [self setSize: [FrameTranslater convertCanvasSize: image.size]];
}

-(id) getValue {
    return self.image;
}

-(void) setValue: (id)value {
    self.image = value;
}



#pragma mark - 

-(void)setDidClickAction:(JRImageViewDidClickAction)didClickAction
{
    _didClickAction = didClickAction;
    
    if (didClickAction) {
        self.userInteractionEnabled = YES;
        if (!tapGestureRecognizer) {
            tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget: self action:@selector(tapAction:)];
        }
        [self addGestureRecognizer: tapGestureRecognizer];
    } else {
        self.userInteractionEnabled = NO;
        [self removeGestureRecognizer:tapGestureRecognizer];
    }
}


-(void) setDoubleClickAction:(JRImageViewDidClickAction)doubleClickAction
{
    _doubleClickAction = doubleClickAction;
    
    if (doubleClickAction) {
        self.userInteractionEnabled = YES;
        if (!doubleTapGestureRecognizer) {
            doubleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleClickAction:)];
            doubleTapGestureRecognizer.numberOfTapsRequired = 2 ;
        }
        [self addGestureRecognizer: doubleTapGestureRecognizer];
    } else {
        self.userInteractionEnabled = NO;
        [self removeGestureRecognizer: doubleTapGestureRecognizer];
    }
    
    
}

#pragma mark - Action

-(void) tapAction: (UITapGestureRecognizer *)tapGesture {
    if (self.didClickAction) {
        self.didClickAction(self);
    }
}

-(void) doubleTapAction: (UITapGestureRecognizer*)tapGesture
{
    if (self.doubleClickAction) {
        self.doubleClickAction(self);
    }
}

@end
