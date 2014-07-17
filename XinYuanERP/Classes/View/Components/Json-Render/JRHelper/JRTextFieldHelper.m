#import "JRTextFieldHelper.h"
#import "AppInterface.h"

@implementation JRTextFieldHelper

+(void) setTextFieldDelegateAdjustKeyboard: (id<JRTopViewProtocal>)jrTopViewProtocal
{
    [self setTextFieldAdjustKeyboardDelegate: jrTopViewProtocal.contentView];
}

+(void) setTextFieldAdjustKeyboardDelegate: (UIView*)superview
{
    // set text for label by key/attribute
    [ViewHelper iterateSubView: superview class:[UITextField class] handler:^BOOL(id subView) {
        UITextField* textField = (UITextField*)subView;
        id delegate = [JRTextFieldHelper class];
        if (textField.enabled) textField.delegate = (id<UITextFieldDelegate>)delegate;
        return NO;
    }];
}

#pragma mark - Keyboard Adjustment

+(void)initialize
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onKeyboardHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onKeyboardShow:) name:UIKeyboardWillShowNotification object:nil];
}

static JsonView* currentJsonView = nil;
static CGPoint jsonviewOriginCenter;
static bool isKeyBoardShowing;
+(void) onKeyboardHide: (NSNotification*)notification
{
    [self restoreJsonViewPosition];
    
    currentJsonView = nil;
    jsonviewOriginCenter = CGPointZero;
    
    isKeyBoardShowing = NO;
}
+(void) onKeyboardShow: (NSNotification*)notification
{
    isKeyBoardShowing = YES;
}

+(BOOL) isKeyBoardShowing
{
    return isKeyBoardShowing;
}


#pragma mark - UITextField Delegate

+(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}


// Keyboard adjustment
+ (void)textFieldDidBeginEditing_:(UITextField *)textField
{
    [self adjustKeyBoardPositions: textField];
}



#pragma mark -

+(void) adjustKeyBoardPositions: (UIView *)textFieldView
{
    UIView* topView = [ViewHelper getTopView];
    
    if (! currentJsonView) {
        JsonView* jsonview = [JsonViewHelper getJsonViewBySubview: textFieldView];
        if (! jsonview) return;
        
        currentJsonView = jsonview;
        jsonviewOriginCenter = jsonview.center;
    }
    
    CGPoint jsonViewPoint = [topView convertPoint: [currentJsonView origin] fromView:currentJsonView.superview];
    CGPoint textFieldPoint = [currentJsonView convertPoint: [textFieldView origin] fromView:textFieldView.superview];
    
    CGFloat stopY = jsonViewPoint.y + textFieldPoint.y + [textFieldView sizeHeight];
    CGFloat keyBoardY = [topView sizeHeight] - KeyBoardHeight;
    float gap = keyBoardY - stopY ;     // gap < 0 , need to go up
    
    float extra = [FrameTranslater convertCanvasHeight: [self isTheBottomTextField: textFieldView inView:currentJsonView]  ? 30 : 80];
    
    if (gap > 0) {
        float goUpDistance = jsonviewOriginCenter.y - currentJsonView.center.y;
        if (goUpDistance > 0) {
            float needDown = goUpDistance > gap ? gap : goUpDistance;
            [UIView beginAnimations:@"showKeyboardAnimation" context:nil];
            [UIView setAnimationDuration:0.30];
            //            [currentJsonView addOriginY: needDown];
            [currentJsonView addOriginY: needDown - extra];
            [UIView commitAnimations];
        }
        
    } else if (gap < 0) {
        [UIView beginAnimations:@"showKeyboardAnimation" context:nil];
        [UIView setAnimationDuration:0.30];
        //        [currentJsonView addOriginY: gap];
        [currentJsonView addOriginY: gap - extra];
        [UIView commitAnimations];
    }
}

+(void) restoreJsonViewPosition
{
    if (! CGPointEqualToPoint(currentJsonView.center, jsonviewOriginCenter)) {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.30];
        currentJsonView.center = jsonviewOriginCenter;
        [UIView commitAnimations];
    }
}

+(JsonView*) getCurrentJsonView: (UIView*)superView {
    JsonView* jsonview = nil;
    for (UIView* view in superView.subviews) {
        if ([view isKindOfClass: [JsonView class]]) {
            jsonview = (JsonView*)view;
            break;
        }
    }
    return jsonview;
}


// UITextField or UITextView
+(BOOL) isTheBottomTextField: (UIView*)obj inView:(UIView*)inView {
    return obj == [self getTheBottomView: inView class:[obj class]];
}

+(id) getTheBottomView: (UIView*)superView class:(Class)class {
    __block UIView* componentView = nil;
    [ViewHelper iterateSubView: superView class:class handler:^BOOL(id subView) {
        UIView* textField = (UIView*)subView;
        CGPoint point = [textField.superview convertPoint: textField.frame.origin toView:superView];
        if (!componentView){
            componentView = textField;
        } else {
            CGPoint bottomPoint = [componentView.superview convertPoint: componentView.frame.origin toView:superView];
            if (point.y > bottomPoint.y) {
                componentView = textField;
            }
        }
        return NO;
    }];
    return componentView;
}


@end
