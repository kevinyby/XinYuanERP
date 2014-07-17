//
//  PhotoButton.m
//  XinYuanERP
//
//  Copyright (c) 2014年 Xinyuan4. All rights reserved.
//

#import "PhotoButton.h"
#import "PhotoPickerViewController.h"

@interface PhotoButton()

@property(nonatomic,weak)id presentClass;
@property(nonatomic,weak)UIImageView* presentImageView;


@end

@implementation PhotoButton

-(id)initWithButtonImage:(UIImage*)btnImage ButtonFocusImage:(UIImage*)btnFocusImage presentImageView:(UIImageView*)imgView presentClass:(id)class
{
	
	if (self=[super init]) {
		self.backgroundColor = [UIColor clearColor];
		[self setImage:btnImage forState:UIControlStateNormal];
		[self setImage:btnFocusImage forState:UIControlStateHighlighted];
		[self setImage:btnFocusImage forState:UIControlStateSelected];
		[self addTarget:self action:@selector(photoAction:) forControlEvents:UIControlEventTouchUpInside];
        self.presentClass = class;
        self.presentImageView = imgView;
	}
	return self;
}


- (void)photoAction:(id)sender {
    
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        PhotoPickerViewController *imagePickerController = [[PhotoPickerViewController alloc] init];
        imagePickerController.delegate = self;
        [self.presentClass presentViewController:imagePickerController animated:YES completion:^{}];
    }
    
}

#pragma mark - Image Picker Delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
	[picker dismissViewControllerAnimated:YES completion:^{}];
    
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    [self.presentImageView setImage:image];
    
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
	[self.presentClass  dismissViewControllerAnimated:YES completion:^{}];
}



@end
