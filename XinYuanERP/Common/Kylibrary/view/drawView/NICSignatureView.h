//
//  NICSignatureView.h
//  SignatureViewTest
//


#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>

@interface NICSignatureView : GLKView

@property (assign, nonatomic) BOOL hasSignature;
@property (strong, nonatomic) UIImage *signatureImage;

@property (assign, nonatomic) BOOL hasGenie;
@property (assign, nonatomic) GLKVector4 color;

- (void)erase;


@end
