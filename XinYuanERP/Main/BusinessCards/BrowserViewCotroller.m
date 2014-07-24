//
//  ViewController.m
//  Photolib
//
//  Created by bravo on 14-5-22.
//  Copyright (c) 2014年 bravo. All rights reserved.
//

#import "BrowserViewCotroller.h"
#import "DictionaryDataSource.h"
#import "Card.h"
#import "DictionaryDataSource.h"
/*
 This class should handle function himself, like
 navigation, refresh, stack managing..etc
 */
@interface BrowserViewCotroller ()<UICollectionViewDelegateFlowLayout>

@property(nonatomic,strong) NSMutableArray* stack;

@end

@implementation BrowserViewCotroller

@synthesize current_path,delegate, current_pwd;

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupCollectionView];
}

-(void) refresh{
    [self.collectionView reloadData];
}

-(void) setDataSource:(id)dataSource{
    self.collectionView.dataSource = dataSource;
}

- (void)setupCollectionView{
    self.stack = [[NSMutableArray alloc] init];
    self.collectionView.allowsMultipleSelection = YES;
    UICollectionViewFlowLayout *collectionViewLayout = (UICollectionViewFlowLayout*)self.collectionView.collectionViewLayout;
    collectionViewLayout.sectionInset = UIEdgeInsetsMake(0, 5, 0, 0);
}

-(void) changeSelection:(BOOL)selected onCell:(UICollectionViewCell *)cell{
    NSIndexPath* indexpath = [self.collectionView indexPathForCell:cell];
    [self.collectionView deselectItemAtIndexPath:indexpath animated:NO];
    [self collectionView:self.collectionView didDeselectItemAtIndexPath:indexpath];
}

-(void) clearSelection{
    NSArray* selections = self.collectionView.indexPathsForSelectedItems;
    for (NSIndexPath* index in selections){
        [self.collectionView deselectItemAtIndexPath:index animated:NO];
    }
}

-(void) enterCell:(UICollectionViewCell *)cell{
    NSIndexPath* indexPath = [self.collectionView indexPathForCell:cell];
    Card* current_data = [((DictionaryDataSource*)self.collectionView.dataSource) itemAtIndex:indexPath];
    if (current_data.isAlbum){
        [self enterAlbumWithData:current_data atIndexPath:indexPath];
    }else {
        [self viewPhotoWithData:current_data atIndexPath:indexPath];
    }
}

#pragma mark - CollectionView Delegate
-(void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
//    Card* current_data = [((DictionaryDataSource*)self.collectionView.dataSource) itemAtIndex:indexPath];
    [self.delegate WDBrowser:self didSelectItemAtIndex:indexPath];
}

-(void) collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath{
    [self.delegate WDBrowser:self didDeselectItemAtIndex:indexPath];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
    if ([collectionView numberOfSections] < 2){
        return CGSizeZero;
    }
    return CGSizeMake(self.collectionView.bounds.size.width, 50);
}

-(void) enterAlbumWithData:(Card*)data atIndexPath:(NSIndexPath*)indexPath{
//    if (self.delegate && [self.delegate conformsToProtocol:@protocol(WDBrowserDelegate)]){
//        [self.delegate WDBrowser:self didEnterFolder:data.path.path];
//    }
    if (data.password && ![data.password isEqualToString:self.current_pwd]){
        [self.delegate WDBrowser:self didAskPasswordForData:data path:[self.current_path stringByAppendingPathComponent:data.name]];
    }else{
        NSString* pushPath = [self.current_path stringByAppendingPathComponent:data.name];
        [self pushPath:pushPath];
    }
}

-(void) viewPhotoWithData:(Card*)data atIndexPath:(NSIndexPath*)indexPath{
    if (self.delegate && [self.delegate conformsToProtocol:@protocol(WDBrowserDelegate)]){
        [self.delegate WDBrowser:self didViewPhotoAtIndex:indexPath.row];
    }
}

-(void) pushPath:(NSString *)path{
    [self.stack addObject:[self.current_path copy]];
    self.current_path = path;
    [self.delegate WDBrowser:self didUpdateDataWithPath:path];
    [self.collectionView reloadData];
    [self.delegate WDBrowser:self didEnterFolder:path isRoot:NO];
}

-(void) back{
    self.current_path = [self.stack lastObject];
    [self.stack removeLastObject];
    [self.delegate WDBrowser:self didUpdateDataWithPath:self.current_path];
    [self.collectionView reloadData];
    BOOL root = self.stack.count < 1 ? YES : NO;
    [self.delegate WDBrowser:self didEnterFolder:self.current_path isRoot:root];
}

-(void) popToRoot{
    if (self.stack.count > 0){
        self.current_path = [self.stack firstObject];
        [self.stack removeAllObjects];
    }
}

-(NSArray*)indexPathsForSelectedItems{
    return self.collectionView.indexPathsForSelectedItems;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self clearSelection];
}

@end
