//
//  PhotoButton.h
//  XinYuanERP
//
//  Copyright (c) 2014年 Xinyuan4. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomButton.h"

@interface PhotoButton : CustomButton<UIImagePickerControllerDelegate,UINavigationControllerDelegate>

-(id)initWithButtonImage:(UIImage*)btnImage ButtonFocusImage:(UIImage*)btnFocusImage presentImageView:(UIImageView*)imgView presentClass:(id)selfClass;


@end
