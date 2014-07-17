//
//  PopPDFViewController.m
//  XinYuanERP
//
//  Created by Xinyuan4 on 14-6-24.
//  Copyright (c) 2014年 Xinyuan4. All rights reserved.
//

#import "PopPDFViewController.h"
#import "AppInterface.h"
#import "OrderMacro.h"
#import "UIViewController+CWPopup.h"

@implementation PopPDFTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code

        UIImage* checkImg = [UIImage imageNamed:@"ListCheck.png"];
        self.imageView.image = checkImg;
        [self.imageView setHidden:YES];
        
        self.textLabel.font = TRANSLATEFONT(16);
        
    }
    return self;
}


- (void)setIsSelected:(BOOL)isSelected
{
    _isSelected = isSelected;
    _isSelected ? [self.imageView setHidden:NO] : [self.imageView setHidden:YES];
    
}

@end



@interface PopPDFViewController ()<UITableViewDelegate,UITableViewDataSource>


@property(nonatomic,strong)UITableView* tableView;
@property(nonatomic,strong)NSMutableArray* dataSource;



@end

@implementation PopPDFViewController

- (id)init
{
    self = [super init];
    if (self) {
          _dataSource = [[NSMutableArray alloc] init];
          _selectedMarks = [[NSMutableArray alloc] init];
    }
    return self;
}

-(void)setSelectedMarks:(NSMutableArray *)selectedMarks
{
    if (_selectedMarks) {
        [_selectedMarks removeAllObjects];
    }
    [_selectedMarks addObjectsFromArray:selectedMarks];
    [self.tableView reloadData];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];

    [self.view setFrame:[FrameTranslater convertCanvasRect: CGRectMake(350, 180, 300, 400)]];
   
    float frameWidth = [FrameTranslater convertCanvasWidth:300];
    float frameHeight = [FrameTranslater convertCanvasWidth:400];
    
    float tableY = [FrameTranslater convertCanvasY:60];
    
    UIView* titleView = [[UIView alloc] init];
    titleView.frame = CGRectMake(0, 0, frameWidth, tableY);
    titleView.backgroundColor = [UIColor colorWithRed:38.0f/255.0f green:195.0f/255.0f blue:253.0f/255.0f alpha:1.0f];
    [self.view addSubview:titleView];
    
    UILabel* titleLabel = [[UILabel alloc] init];
    titleLabel.text = self.title;
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.font = TRANSLATEFONT(18);
    [FrameHelper setFrame:CGRectMake(110, 15, 100, 30) view:titleLabel];
    [titleView addSubview:titleLabel];
    
    UIButton* ensureButton = [[UIButton alloc] init];
    [ensureButton setBackgroundImage:[UIImage imageNamed:@"Pushbutton_08.png"] forState:UIControlStateNormal];
    [ensureButton addTarget:self action:@selector(saveSelectedValue) forControlEvents:UIControlEventTouchUpInside];
    [FrameHelper setFrame:CGRectMake(200, 5, 84, 46) view:ensureButton];
    [ensureButton setTitle:LOCALIZE_KEY(@"OK") forState:UIControlStateNormal];
    ensureButton.titleLabel.font = TRANSLATEFONT(18);
    [titleView addSubview:ensureButton];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, tableY, frameWidth, frameHeight-tableY) style:UITableViewStylePlain];
    if (IOS_VERSION>= 7.0) [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    
    [self readProductDescPDF];
}

-(void)readProductDescPDF
{
    [HTTPBatchRequester startBatchDownloadRequest:self.pathArray url:IMAGE_URL(DOWNLOAD) identifications:@[REQUEST_DOWNLOADIMGNAME(@"PDF")] delegate:nil completeHandler:^(HTTPRequester *requester, ResponseJsonModel *model, NSHTTPURLResponse *httpURLReqponse, NSError *error){
        if (!error) {
            [self.dataSource addObjectsFromArray:model.results];
            [self.tableView reloadData];
        }
    }];
}

#pragma mark -
#pragma mark -  UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    PopPDFTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[PopPDFTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    NSString *text= [self.dataSource objectAtIndex:indexPath.row];
    cell.textLabel.text = text;
    cell.isSelected = [_selectedMarks containsObject:text]? YES : NO;
    
    return cell;
}

#pragma mark -
#pragma mark -  UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (IS_IPHONE) return 25.0f;
    return 50.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *text = [self.dataSource objectAtIndex:[indexPath row]];
    
    if ([_selectedMarks containsObject:text])// Is selected?
        [_selectedMarks removeObject:text];
    else
        [_selectedMarks addObject:text];
    
    [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];

    DBLOG(@"_selectedMarks == %@",_selectedMarks );
}


#pragma mark -

-(void)saveSelectedValue
{
    if (self.selectBlock) self.selectBlock(self.selectedMarks);
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
