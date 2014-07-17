//
//  PopupView.h
//  XinYuanERP
//
//  Created by bravo on 13-10-29.
//  Copyright (c) 2013年 Xinyuan4. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol PopupViewDelegate <NSObject>

@optional
-(void) didConfirm;
-(void) didCancel;
-(void) success;
-(void) failed;

@end
@class PopupView;
typedef void(^PopupViewConfirmBlock)(PopupView* popview, NSDictionary* data);
typedef void(^PopupViewCancelBlock)(PopupView* popview);

@interface PopupView : UIView<UITextFieldDelegate>{
    UIToolbar* content;
    UIView* mask;
}
@property (nonatomic,strong) PopupViewConfirmBlock confirmBlock;
@property (nonatomic,strong) PopupViewCancelBlock cancleBlock;
@property(nonatomic,strong) id<PopupViewDelegate> delegate;
@property(nonatomic, strong) UIButton* cancel;
@property(nonatomic,strong) UIButton* done;

+(PopupView*) popWithType:(Class)type
            confirm:(PopupViewConfirmBlock)confirm
             cancel:(PopupViewCancelBlock)cancel;

-(id) initWithContentSize:(CGRect)frame;

-(void) cancelAction;
-(void) confirmAction;

/*show pop up*/
-(void) showWithAnimate:(BOOL)animate;

/*dismiss view*/
-(void) dismissWithAnimate:(BOOL)animate;

@end
