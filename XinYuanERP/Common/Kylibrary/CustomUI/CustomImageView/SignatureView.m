//
//  SignatureView.m
//  XinYuanERP
//
//  Created by Xinyuan4 on 13-12-31.
//  Copyright (c) 2014年 Xinyuan4. All rights reserved.
//

#import "SignatureView.h"
#import "AppInterface.h"

@implementation SignatureView


- (id)initWithFrame:(CGRect)frame withUrl:(NSString* )url parent:(UIView*)parentView
{
    self = [super initWithFrame:frame];
    if (self) {
        CGRect rect = CGRectMake(0, 0, frame.size.width, frame.size.height);
        _signView = [[NetworkImageView alloc]initWithFrame:rect];
        [self.signView loadImageFromURL:url];
        [self addSubview:self.signView];
      
        self.genieRect = CGRectMake(parentView.origin.x + parentView.superview.origin.x + 2,
                                    parentView.origin.y + parentView.superview.origin.y + 2,
                                    frame.size.width + 5, frame.size.height + 5);
        
        self.userInteractionEnabled = YES;
        UITapGestureRecognizer *signTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(signTapAction:)];
        [self.signView addGestureRecognizer:signTapGesture];
        
    }
    return self;
}



-(void)initDrawViewWithParent:(UIView*)parentView
{
    CGRect canvas = CGRectMake(0, 0, LONG_IPAD, SHORT_IPAD);
    _draggedView = [[NICSignatureView alloc]initWithFrame:canvas context:self.draggedView.context];
    [SignatureView setSignatureViewAttributes: _draggedView];
    [Utility parent:parentView add:self.draggedView rect:canvas];
    
    NSArray* buttons = [SignatureView getSignatureButtons];
    UIButton* cancelBtn = [buttons objectAtIndex: 0];
    UIButton* clearBtn = [buttons objectAtIndex: 1];
    UIButton* saveBtn = [buttons objectAtIndex: 2];
    
    cancelBtn.tag = 1;
    [self.draggedView addSubview: cancelBtn];
    [cancelBtn addTarget:self action:@selector(cancelAction:) forControlEvents:UIControlEventTouchUpInside];
    
    
    clearBtn.tag = 2;
    [self.draggedView addSubview: clearBtn];
    [clearBtn addTarget:self action:@selector(clearScreen:) forControlEvents:UIControlEventTouchUpInside];
    
    
    saveBtn.tag = 3;
    [self.draggedView addSubview: saveBtn];
    [saveBtn addTarget:self action:@selector(saveScreen:) forControlEvents:UIControlEventTouchUpInside];
    
    saveBtn.hidden = YES;
    clearBtn.hidden = YES;
    cancelBtn.hidden = YES;
    
    self.viewIsIn=NO;
    
    [self genieToRect:self.genieRect edge:BCRectEdgeBottom];
    
    
}


+(NSArray*) getSignatureButtons
{
    
    UIImage* buttonImage = [UIImage imageNamed:@"LendOut_签名按钮.png"];
    
    float contentX = 80;
    float contentY = 700;
    CGRect canvas=CGRectMake(contentX, contentY, buttonImage.size.width, buttonImage.size.height);
    UIButton* cancelBtn = [[UIButton alloc]initBackgroundImage:buttonImage title:LOCALIZE_KEY(@"Sign_Cancel") font:TRANSLATEFONT(20)
                                                    titleColor:BLACK_COLOR highColor:BLACK_COLOR ];
    [FrameHelper setFrame:canvas view:cancelBtn];
    
    contentX = contentX + 300;
    canvas=CGRectMake(contentX, contentY, buttonImage.size.width, buttonImage.size.height);
    UIButton* clearBtn = [[UIButton alloc]initBackgroundImage:buttonImage title:LOCALIZE_KEY(@"Sign_Clear") font:TRANSLATEFONT(20)
                                                   titleColor:BLACK_COLOR highColor:BLACK_COLOR ];
    [FrameHelper setFrame:canvas view:clearBtn];
    
    
    contentX = contentX + 300;
    canvas=CGRectMake(contentX, contentY, buttonImage.size.width, buttonImage.size.height);
    UIButton* saveBtn = [[UIButton alloc]initBackgroundImage:buttonImage title:LOCALIZE_KEY(@"Sign_Save") font:TRANSLATEFONT(20)
                                                  titleColor:BLACK_COLOR highColor:BLACK_COLOR ];
    [FrameHelper setFrame:canvas view:saveBtn];
    
    
    return @[cancelBtn, clearBtn, saveBtn];
}

+(void) setSignatureViewAttributes: (NICSignatureView*)draggedView
{
    draggedView.backgroundColor = RGB(240, 240, 240);
    draggedView.color = GLKVector4Make(240/255.0f, 240/255.0f,  240/255.0f, 1.0f);
    draggedView.layer.cornerRadius = IS_IPHONE? 6.0f : 10.0f;
    draggedView.clipsToBounds = TRUE;
}


#pragma mark -
#pragma mark - Sketchpad
-(void)clearScreen:(id)sender
{
    self.scrollView.scrollEnabled = NO;
    [self.draggedView erase];
}

- (void)saveScreen:(id)sender {
    
    PARENTTYPEVIEW(UIView, self.draggedView,1).hidden = YES;
    PARENTTYPEVIEW(UIView, self.draggedView,2).hidden = YES;
    PARENTTYPEVIEW(UIView, self.draggedView,3).hidden = YES;
    
    self.scrollView.scrollEnabled = YES;
    self.draggedView.hasGenie=YES;
    self.viewIsIn=NO;
    
    [self genieToRect:self.genieRect edge:BCRectEdgeBottom];
    
    self.signView.image = self.draggedView.signatureImage;
    
    [self.draggedView removeFromSuperview];
    self.draggedView = nil;

}

-(void)cancelAction:(id)sender
{
    
    [UIView animateWithDuration:0.3 animations:^{
        PARENTTYPEVIEW(UIView, self.draggedView,1).hidden = NO;
        PARENTTYPEVIEW(UIView, self.draggedView,2).hidden = NO;
        PARENTTYPEVIEW(UIView, self.draggedView,3).hidden = NO;
    }];
    
    self.scrollView.scrollEnabled = YES;
    self.firstIn=YES;
    [self genieToRect:self.genieRect edge:BCRectEdgeBottom];
}

#pragma mark -
#pragma mark - GenieEffectDelegate

-(void)signTapAction:(UITapGestureRecognizer*)tap{
    
    self.scrollView.scrollEnabled = NO;
    
    if (self.draggedView == nil) {
        
        [BrowseImageView browseImage:self.signView];
        
    }else{
        
        [UIView animateWithDuration:0.3 animations:^{
            PARENTTYPEVIEW(UIView, self.draggedView,1).hidden = NO;
            PARENTTYPEVIEW(UIView, self.draggedView,2).hidden = NO;
            PARENTTYPEVIEW(UIView, self.draggedView,3).hidden = NO;
        }];
        
        self.firstIn=YES;
        [self genieToRect:self.genieRect edge:BCRectEdgeBottom];
    }
}

- (void) genieToRect: (CGRect)rect edge: (BCRectEdge) edge
{
    NSTimeInterval duration  ;
    if (!self.firstIn) {
        duration=0;
    }else{
        duration=0.5;
    }
    CGRect endRect = CGRectInset(rect, 5.0, 5.0);
    
    if (self.viewIsIn) {
        [self.draggedView genieOutTransitionWithDuration:duration startRect:endRect startEdge:edge completion:^{
            self.draggedView.userInteractionEnabled = YES;
            
        }];
    } else {
        self.draggedView.userInteractionEnabled = NO;
        [self.draggedView genieInTransitionWithDuration:duration destinationRect:endRect destinationEdge:edge completion:
         ^{
             
         }];
        [UIView animateWithDuration:0 animations:^{
            PARENTTYPEVIEW(UIView, self.draggedView,1).hidden = YES;
            PARENTTYPEVIEW(UIView, self.draggedView,2).hidden = YES;
            PARENTTYPEVIEW(UIView, self.draggedView,3).hidden = YES;
        }];
        
       
    }
    self.viewIsIn = ! self.viewIsIn;
    self.draggedView.hasGenie=NO;
}



@end
