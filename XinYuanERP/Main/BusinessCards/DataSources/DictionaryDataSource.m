//
//  ArrayDataSource.m
//  Photolib
//
//  Created by bravo on 14-6-9.
//  Copyright (c) 2014年 bravo. All rights reserved.
//

#import "DictionaryDataSource.h"
#import "AlbumCell.h"
#import "PhotoCell.h"
#import "CollectionHeaderView.h"

@interface DictionaryDataSource()
@property (nonatomic, strong) NSDictionary *items;
@property (nonatomic, strong) NSArray *cellIdentifier;
@property (nonatomic, copy) CollectionViewCellConfigureBlock configureCellBlock;
@end

@implementation DictionaryDataSource{
    NSMutableArray* mutableCellIndentifier;
}


-(id) initWithItems:(NSDictionary *)anItems cellIdentifier:(NSArray *)cellIdentifilers configureCellBlock:(CollectionViewCellConfigureBlock)aConfigureBlock{
    if ((self = [super init])){
        self.cellIdentifier = cellIdentifilers;
        [self updateItems:anItems];
        self.configureCellBlock = aConfigureBlock;
    }
    return self;
}

-(void) updateItems:(NSDictionary *)anItems{
    NSMutableDictionary* mut = [anItems mutableCopy];
    mutableCellIndentifier = [self.cellIdentifier mutableCopy];
    
    for (id key in anItems){
        if (((NSArray*)mut[key]).count < 1){
            [mutableCellIndentifier removeObject:key];
            [mut removeObjectForKey:key];
        }
    }
    self.items = [[NSDictionary alloc] initWithDictionary:mut];
}

-(id) itemAtIndex:(NSIndexPath *)indexPath{
    NSString* tag = mutableCellIndentifier[indexPath.section];
    return self.items[tag][indexPath.row];
}

#pragma mark - UICollectionViewDataSource

-(UICollectionReusableView*)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    UICollectionReusableView *reusableview = nil;
    if (kind == UICollectionElementKindSectionHeader) {
        CollectionHeaderView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderView" forIndexPath:indexPath];
        NSString *title = [[NSString alloc]initWithFormat:@"---Group %i---", indexPath.section + 1];
        headerView.title.text = title;
        
        reusableview = headerView;
    }
    return reusableview;
}

-(NSInteger) numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return self.items.count;
}

-(NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    NSString* tag = mutableCellIndentifier[section];
    return ((NSArray*)[self.items objectForKey:tag]).count;
}

-(UICollectionViewCell*) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:mutableCellIndentifier[indexPath.section] forIndexPath:indexPath];
    
    id item = [self itemAtIndex:indexPath];
    self.configureCellBlock(cell, item);

    return cell;
}

@end
