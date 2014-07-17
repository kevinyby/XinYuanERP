/*
 扫描二维码
 */
#import <UIKit/UIKit.h>
#import "ZBarReaderViewController.h"

typedef void (^QRReaderScanBlock)(NSString* result);

@interface QRCodeReaderViewController : ZBarReaderViewController<UINavigationControllerDelegate,UIImagePickerControllerDelegate,ZBarReaderDelegate>

@property (nonatomic, copy)QRReaderScanBlock resultBlock;

@end
