
#import "SNPopupView+UsingPrivateMethod.h"

@implementation SNPopupView(UsingPrivateMethod)


-(void)showFrom:(UIButton*)button inView:(UIView*)inView PopDown:(BOOL)down animated:(BOOL)animated{
    
    UIView *targetSuperview = [button superview];
	
	CGRect rect = [targetSuperview convertRect:button.frame toView:inView];
	
	CGPoint p;
    if (down) {
        p.x = rect.origin.x + (int)rect.size.width/2 + 15;
        p.y = rect.origin.y + (int)button.frame.size.height - 5;
        self.direction = SNPopupViewDown;
        
    }else{
        
        p.x = rect.origin.x + (int)rect.size.width/2 + 15;
        p.y = rect.origin.y ;
         self.direction = SNPopupViewUp;
    }
    
	
	[self showAtPoint:p inView:inView animated:animated];
}


@end
