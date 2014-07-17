
#import "QRCodeReaderViewController.h"

@interface QRCodeReaderViewController ()
{
    int num;
    BOOL upOrdown;
    NSTimer * timer;
    
}
@property (nonatomic, strong) UIImageView * line;

@end

@implementation QRCodeReaderViewController

- (id)init
{
    self = [super init];
    if (self) {
        
        self.readerDelegate = self;
        self.supportedOrientationsMask = ZBarOrientationMask(UIInterfaceOrientationPortrait);//支持界面旋转
        self.showsHelpOnFail = NO;
        self.showsZBarControls = NO;
        self.scanCrop = CGRectMake(0.1, 0.2, 0.8, 0.8);//扫描的感应框
        
    }
    return self;
}

//隐藏状态栏
- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    num = 0;
    upOrdown = NO;
    
    ZBarImageScanner * ImageScanner = self.scanner;
    [ImageScanner setSymbology:ZBAR_I25
                   config:ZBAR_CFG_ENABLE
                       to:0];
    float contentX;
    float contentY;
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
        contentX = 0;
        contentY = 50;
    }else{
        contentX = 230;
        contentY = 250;
    }
    UIView * view = [[UIView alloc] initWithFrame:CGRectMake(contentX, contentY, 320, 420)];
    view.backgroundColor = [UIColor clearColor];
    [self.view addSubview:view];
    
    UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, 280, 40)];
    label.text = @"请将扫描的二维码至于下面的框内！";
    label.textColor = [UIColor whiteColor];
    label.textAlignment = 1;
    label.lineBreakMode = 0;
    label.numberOfLines = 2;
    label.backgroundColor = [UIColor clearColor];
    [view addSubview:label];
    
    UIImageView * image = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pick_bg.png"]];
    image.frame = CGRectMake(20, 80, 280, 280);
    [view addSubview:image];
    
    
    _line = [[UIImageView alloc] initWithFrame:CGRectMake(30, 10, 220, 2)];
    _line.image = [UIImage imageNamed:@"line.png"];
    [image addSubview:_line];
    //定时器，设定时间过1.5秒，
    timer = [NSTimer scheduledTimerWithTimeInterval:.02 target:self selector:@selector(animation) userInfo:nil repeats:YES];
    
    

    //底部view
    UIView * bottomView =[[UIView alloc] initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height - 60, [UIScreen mainScreen].bounds.size.width, 60)];
    bottomView.alpha = 0.4;
    bottomView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:bottomView];
   
    //用于取消操作的button
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [cancelButton setFrame:CGRectMake([UIScreen mainScreen].bounds.size.width/2 - 25, 10, 50, 40)];
    [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    [cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [cancelButton.titleLabel setFont:[UIFont boldSystemFontOfSize:20]];
    [cancelButton addTarget:self action:@selector(dismissOverlayView:)forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:cancelButton];
}

-(void)animation
{
    if (upOrdown == NO) {
        num ++;
        _line.frame = CGRectMake(30, 10+2*num, 220, 2);
        if (2*num == 260) {
            upOrdown = YES;
        }
    }
    else {
        num --;
        _line.frame = CGRectMake(30, 10+2*num, 220, 2);
        if (num == 0) {
            upOrdown = NO;
        }
    }
    
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [timer invalidate];
    _line.frame = CGRectMake(30, 10, 220, 2);
    num = 0;
    upOrdown = NO;
    [picker dismissViewControllerAnimated:YES completion:^{
        [picker removeFromParentViewController];
    }];
}
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [timer invalidate];
    _line.frame = CGRectMake(30, 10, 220, 2);
    num = 0;
    upOrdown = NO;
    [picker dismissViewControllerAnimated:YES completion:^{
        [picker removeFromParentViewController];
        UIImage * image = [info objectForKey:UIImagePickerControllerOriginalImage];
        //初始化
        ZBarReaderController * read = [ZBarReaderController new];
        //设置代理
        read.readerDelegate = self;
        CGImageRef cgImageRef = image.CGImage;
        ZBarSymbol * symbol = nil;
        id <NSFastEnumeration> results = [read scanImage:cgImageRef];
        for (symbol in results)
        {
            break;
        }
        NSString * result;
        if ([symbol.data canBeConvertedToEncoding:NSShiftJISStringEncoding])
            
        {
            result = [NSString stringWithCString:[symbol.data cStringUsingEncoding: NSShiftJISStringEncoding] encoding:NSUTF8StringEncoding];
        }
        else
        {
            result = symbol.data;
        }
        
        NSLog(@"result=========%@",result);
        NSArray* array = [result componentsSeparatedByString:@"\n"];
        NSLog(@"array====%@",array);
        
        if (self.resultBlock) {
            self.resultBlock([array firstObject]);
        }
        
    }];
}


- (void)dismissOverlayView:(id)sender{
    [self dismissModalViewControllerAnimated: YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*支持竖屏*/
#pragma mark -
#pragma mark - UIInterfaceOrientation
// for ios5.0 , 6.0 deprecated
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return (toInterfaceOrientation == UIInterfaceOrientationPortrait);
}

- (NSUInteger) supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    
    return UIInterfaceOrientationPortrait;
}

// for ios6.0 supported
- (BOOL) shouldAutorotate {
    return YES ;//YES;
}



@end
