//
//  PDFMainViewController.m
//  XinYuanERP
//
//  Created by Xinyuan4 on 14-7-24.
//  Copyright (c) 2014年 Xinyuan4. All rights reserved.
//

#import "PDFMainViewController.h"
#import "PDFDataManager.h"
#import "PDFCollectionCell.h"
#import "PDFFloderCollectionCell.h"
#import "KATransition.h"

#import "_Localize.h"
#import "TextMacro.h"

@interface PDFMainViewController ()
{
    NSMutableArray* _currentPDFArray;
    NSDictionary* _currentPDFDictionary;
}

@end

@implementation PDFMainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    self.navigationController.navigationBar.translucent = NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UICollectionViewFlowLayout* layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumInteritemSpacing = 10;
    layout.minimumLineSpacing = 10;
    layout.itemSize = CGSizeMake(150, 150);
    layout.sectionInset = UIEdgeInsetsMake(5, 10, 5, 10);
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];

    [self.collectionView registerClass:[PDFCollectionCell class] forCellWithReuseIdentifier:@"PDFCell"];
    [self.collectionView registerClass:[PDFFloderCollectionCell class] forCellWithReuseIdentifier:@"PDFFloderCell"];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    
    self.collectionView.backgroundColor = [UIColor orangeColor];
    
    [self.view addSubview:self.collectionView];
    
    UIButton *backButton = [UIButton buttonWithType:101];
    [backButton addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    [backButton setTitle:@"返回" forState:UIControlStateNormal];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.navigationItem.leftBarButtonItem = backItem;
    
    _currentPDFDictionary = [NSDictionary dictionaryWithDictionary:[[PDFDataManager sharedManager] PDFDic]];
    _currentPDFArray =[NSMutableArray arrayWithArray:[PDFDataManager getDictionaryArray:_currentPDFDictionary]];
    
    [[[PDFDataManager sharedManager] PDFStack]addObject:_currentPDFDictionary];

}

-(void)setPDFSelectArray:(NSMutableArray *)PDFSelectArray
{
    if (_PDFSelectArray) {
        [_PDFSelectArray removeAllObjects];
    }else{
        _PDFSelectArray = [NSMutableArray array];
    }
    [_PDFSelectArray addObjectsFromArray:PDFSelectArray];
}

#pragma mark -
#pragma mark - UICollectionViewDataSource Methods

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [_currentPDFArray count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    id object = [_currentPDFArray objectAtIndex:indexPath.row];

    if ([object isKindOfClass:[NSDictionary class]]) {
        
          PDFFloderCollectionCell* cell = (PDFFloderCollectionCell*)[collectionView dequeueReusableCellWithReuseIdentifier:@"PDFFloderCell" forIndexPath:indexPath];
          cell.floderSource = object;
          NSString* text = [PDFDataManager getDictionaryKey:cell.floderSource];
          [cell setTextString:text];
          cell.tapBlock = ^(PDFFloderCollectionCell* cell){
                [_currentPDFArray removeAllObjects];
                _currentPDFDictionary =  [cell.floderSource copy];
                [[[PDFDataManager sharedManager] PDFStack]addObject:_currentPDFDictionary];
                [_currentPDFArray addObjectsFromArray:[PDFDataManager getDictionaryArray:cell.floderSource]];
                [KATransition runTransition: UIViewAnimationTransitionCurlUp forView:self.view];
                [self.collectionView reloadData];
                
            };
        
            return cell;
        
    }else if([object isKindOfClass:[NSString class]]){
        
        PDFCollectionCell* cell = (PDFCollectionCell*)[collectionView dequeueReusableCellWithReuseIdentifier:@"PDFCell" forIndexPath:indexPath];
        NSString* text = object;
        [cell setTextString:text];
        cell.isSelected = [PDFDataManager judgeTextInContain:text contain:_PDFSelectArray]? YES : NO;
        cell.tapBlock = ^(PDFCollectionCell* cell){
            if ([PDFDataManager judgeTextInContain:cell.label.text contain:_PDFSelectArray])
                [PDFDataManager removeTextFromContain:cell.label.text contain:_PDFSelectArray];
            else
                
               [PDFDataManager addTextToContain:cell.label.text contain:_PDFSelectArray];
        };
        
        
        return cell;
    }

    return nil;
}

-(void)backAction
{
    if ([[[PDFDataManager sharedManager] PDFStack] count] > 1) {
       
        [[[PDFDataManager sharedManager] PDFStack]removeLastObject];
        _currentPDFDictionary = [[[PDFDataManager sharedManager] PDFStack] lastObject];
        [_currentPDFArray removeAllObjects];
        [_currentPDFArray addObjectsFromArray:[PDFDataManager getDictionaryArray:_currentPDFDictionary]];
        [self.collectionView reloadData];
        [KATransition runTransition: UIViewAnimationTransitionCurlDown forView:self.view];

    }else{
        
        NSArray *viewControllers = self.navigationController.viewControllers;
        UIViewController *preViewController = [viewControllers objectAtIndex:viewControllers.count - 2];
        [self.navigationController popToViewController:preViewController animated:YES];
        
        [[[PDFDataManager sharedManager] PDFStack] removeAllObjects];
        
        if (self.selectBlock) {
            self.selectBlock(_PDFSelectArray);
        }
    }
    
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
