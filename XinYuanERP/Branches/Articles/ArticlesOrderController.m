//
//  ArticlesOrderController.m
//  XinYuanERP
//
//  Created by Xinyuan4 on 14-4-21.
//  Copyright (c) 2014年 Xinyuan4. All rights reserved.
//

#import "ArticlesOrderController.h"
#import "AppInterface.h"

@interface ArticlesOrderController ()
@end

@implementation ArticlesOrderController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    UIImageView* backgroundView = [[UIImageView alloc]initWithFrame:self.view.bounds];
    backgroundView.image = [UIImage imageNamed:@"Articles_02.png"];
    [self.view addSubview:backgroundView];
    
    UIImage* image = [UIImage imageNamed:@"Articles_01.png"];
    UIImage* focuseImg = [ImageHelper applyingAlphaToImage:image alpha:0.8];
    UIButton* button = [[UIButton alloc]init];
    [FrameHelper setFrame:CGRectMake(0, 0, image.size.width, image.size.height) view:button];
    [button setImage:image forState:UIControlStateNormal];
    [button setImage:focuseImg forState:UIControlStateSelected];
    [button setImage:focuseImg forState:UIControlStateHighlighted];
    [button addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    [self.view exchangeSubviewAtIndex:1 withSubviewAtIndex:2];
    
}



#pragma mark -
#pragma mark - Request
-(void) translateReceiveObjects: (NSMutableDictionary*)objects
{
    NSString* contentString = [objects objectForKey:@"articles"];
    NSString* titleString = [objects objectForKey:@"title"];

    int spaceNum =(int) [FrameTranslater convertCanvasWidth:452] /12;
    NSMutableString* spaceString = [[NSMutableString alloc] init];
    for (NSUInteger i = 0 ; i < spaceNum; i++) {
        [spaceString appendString: @" "];
    }
    titleString = [spaceString stringByAppendingString:titleString];
    
    NSString* string = [NSString stringWithFormat:@"%@\n%@",titleString,[self filterRegExpTag:contentString]];
    NSMutableAttributedString *attributedTextHolder = [[NSMutableAttributedString alloc] initWithString:string];
    [attributedTextHolder addAttribute:NSFontAttributeName value:[UIFont preferredFontForTextStyle:UIFontTextStyleBody] range:NSMakeRange(0, attributedTextHolder.length)];
    self.content = [attributedTextHolder copy];
    [super loadPageView];
   
}


- (NSString*)filterRegExpTag:(NSString*)string
{
    static NSRegularExpression *iExpression;
    iExpression = iExpression ?: [NSRegularExpression regularExpressionWithPattern:@"\\</>\\w+\\n*\\</>" options:0 error:NULL];
    
    NSMutableArray* rangeMutArray = [NSMutableArray array];
    [iExpression enumerateMatchesInString:string options:0 range:NSMakeRange(0, string.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        
        NSLog(@"NSStringFromRange(result.range) === %@",NSStringFromRange(result.range));
        NSLog(@"[self.string substringWithRange:result.range] === %@",[string substringWithRange:result.range]);
        [rangeMutArray addObject:[NSValue valueWithRange:result.range]];
    }];
    
    NSMutableString* mutString = [string mutableCopy];
    int accumalate = 0;
    int taglen = 3;
    for (int i = 0; i< [rangeMutArray count]; ++i) {
        NSRange range = [[rangeMutArray objectAtIndex:i] rangeValue];
        [mutString deleteCharactersInRange:NSMakeRange(range.location + accumalate,taglen)];
        accumalate -= taglen;
        [mutString deleteCharactersInRange:NSMakeRange(range.location + accumalate + range.length - taglen,taglen)];
        accumalate -= taglen;
    }
    return mutString;
}


#pragma mark -
#pragma mark - Button Action
-(void)backAction
{
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
