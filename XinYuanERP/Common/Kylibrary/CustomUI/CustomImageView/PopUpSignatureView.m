//
//  PopUpSignatureView.m
//  XinYuanERP
//
//  Created by Xinyuan4 on 14-3-11.
//  Copyright (c) 2014年 Xinyuan4. All rights reserved.
//

#import "PopUpSignatureView.h"
#import "AppInterface.h"

@implementation PopUpSignatureView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = YES;
        UITapGestureRecognizer *signTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(signTapAction:)];
        [self addGestureRecognizer:signTapGesture];
    }
    return self;
}

-(void)signTapAction:(UITapGestureRecognizer*)tap{
    
    if (self.image)
    {
        [BrowseImageView browseImage:self];
    }
    else
    {
        
        JsonView* signatureJsonView =  (JsonView*)[JsonViewRenderHelper renderFile:@"Components" specificationsKey:@"SignatureViewWithButtons"];
        signatureJsonView.scrollEnabled = NO;
        JRSignatureView* signatureView = (JRSignatureView*)[signatureJsonView getView:@"SignatureView"];
        signatureView.color = GLKVector4Make(240/255.0f, 240/255.0f,  240/255.0f, 1.0f);
        JRButton* cancelBTN = (JRButton*)[signatureJsonView getView:@"Sign_Cancel"];
        JRButton* saveBTN = (JRButton*)[signatureJsonView getView:@"Sign_Save"];
        JRButton* clearBTN = (JRButton*)[signatureJsonView getView:@"Sign_Clear"];
        __weak JRSignatureView* weaksignatureView = signatureView;
        clearBTN.didClikcButtonAction = ^void(id sender) {
            [weaksignatureView erase];
        };
        cancelBTN.didClikcButtonAction = ^void(id sender) {
            //        containerImageView.image = nil;
            [PopupViewHelper dissmissCurrentPopView];
        };
        saveBTN.didClikcButtonAction = ^void(id sender) {
            if (weaksignatureView.signatureImage) self.image = weaksignatureView.signatureImage;
            [PopupViewHelper dissmissCurrentPopView];
        };
        
        [PopupViewHelper popView: signatureJsonView willDissmiss: nil];
    }
    
}


@end
