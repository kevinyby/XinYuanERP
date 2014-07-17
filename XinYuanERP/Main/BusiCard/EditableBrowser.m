//
//  EditableBrowser.m
//  XinYuanERP
//
//  Created by bravo on 13-12-7.
//  Copyright (c) 2013年 Xinyuan4. All rights reserved.
//

#import "EditableBrowser.h"
#import "DefaultBrowser.h"
#import "SDImageCache.h"

typedef enum{
    BROWSER_IMPORT=0,
    BROWSER_DELETE=1
}BROESER_MODE;

@interface EditableBrowser (){
    UIBarButtonItem *actionButton;
    BOOL selectionEnable;
    NSMutableArray *selected;
    NSMutableArray* covers;
    DefaultBrowser *parent;
    UIButton* done;
}

@end

@implementation EditableBrowser
@synthesize mode;

-(void) viewDidLoad{
    [super viewDidLoad];
    self.collectionView.frame = CGRectMake(0, 20, self.collectionView.bounds.size.width, self.collectionView.bounds.size.height-20);
    done = [UIButton buttonWithType:UIButtonTypeContactAdd];
    done.frame = CGRectMake(self.view.bounds.size.width-100, 10, 100, 50);
    [done addTarget:self action:@selector(selectionPressed) forControlEvents:UIControlEventTouchUpInside];
    done.enabled = NO;
    [self.view addSubview:done];
    selected = [[NSMutableArray alloc] init];
    covers = [[NSMutableArray alloc] init];
}

-(void) viewDidAppear:(BOOL)animated{
    selectionEnable = YES;
    self.collectionView.allowsMultipleSelection = YES;
    [super viewDidAppear:animated];
}
-(void)viewDidDisappear:(BOOL)animated{
    selectionEnable = NO;
    [selected removeAllObjects];
    [super viewDidDisappear:animated];
}

-(void) browserDidRefresh{
//    self.navigationController.navigationBar.hidden = NO;
    actionButton = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:self action:@selector(selectionPressed)];
    self.navigationItem.rightBarButtonItem = actionButton;
    self.navigationItem.titleView = [[UILabel alloc] initWithText:@"导入"];
}

-(FileBrowser*) nextBrowserWithPath:(NSString *)newPath{
    return [[EditableBrowser alloc] initWithPath:newPath];
}

-(void) selectionPressed{
    selectionEnable = NO;
    NSMutableArray* deleteIds = [[NSMutableArray alloc] init];
    if (mode == BROWSER_DELETE){
        if (selectionEnable){
            self.collectionView.allowsMultipleSelection = YES;
        }
        else{
            if (selected.count > 0){
                //start request to delete remote file
                //delete cache file
                //dismiss current controller
                
                NSMutableDictionary* deleteParam = [[NSMutableDictionary alloc] init];
                NSString* currentPath = [self.manager getPapa];
                for (int i=0; i<selected.count; i++){
                    NSString* fileName = selected[i][@"fileName"];
                    
                    NSString* thumbPath = [[[currentPath stringByAppendingPathComponent:@"thumbnails"] stringByAppendingPathComponent:fileName] stringByAppendingPathExtension:@"jpg"];
                    
                    [deleteParam setObject:thumbPath forKey:[NSString stringWithFormat:@"thumb_%d",i]];
                    //delete thumb cache
                    [FileManager deleteFile:[FileManager libraryCachesPath:thumbPath]];
                    
                    if (![selected[i][@"isDirectory"] boolValue])
                        fileName = [fileName stringByAppendingPathExtension:@"jpg"];
                    else{
                        NSString* validId = self.dir_name_id[selected[i][@"fileName"]];
                        if (validId)
                            [deleteIds addObject: validId];
                    }
                    
                    NSString* filePath = [currentPath stringByAppendingPathComponent:fileName];
                    SDImageCache* imagecache = [SDImageCache sharedImageCache];
                    
                    [imagecache removeImageForKey:[[NSString stringWithFormat:@"%@?%@",IMAGE_URL(DOWNLOAD),filePath] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
                    
                    [FileManager deleteFile:[FileManager libraryCachesPath:filePath]];
                    [deleteParam setObject:filePath forKey:[NSString stringWithFormat:@"%d",i]];
                }
                
                
                
                [DATA.requester startPostRequest:IMAGE_URL(@"delete") parameters:deleteParam completeHandler:^(HTTPRequester *requester, ResponseJsonModel *model, NSHTTPURLResponse *httpURLReqponse, NSError *error) {
                    if (!error){
                        [actionButton setTitle:@"Select"];
                        self.collectionView.allowsMultipleSelection = NO;
                        selectionEnable = NO;
                        [self.manager comeToPapa];
                    }
                }];
                
                RequestJsonModel* requestModel = [RequestJsonModel getJsonModel];
                requestModel.path = PATH_LOGIC_DELETE(CATEGORIE_CARDS);

                for (NSDictionary* curId in deleteIds) {
                    [requestModel addModel: @"CardsAlbums"];
                    [requestModel.identities addObject: @{@"id": curId}];
                }
                

                [DATA.requester startPostRequest:requestModel completeHandler:^(HTTPRequester* requester, ResponseJsonModel *data, NSHTTPURLResponse *httpURLReqponse, NSError *error) {
                    if (data.status) {
                        [ACTION alertMessage: LOCALIZE_MESSAGE(@"DeleteSuccessfully")];
                    } else {
                        if (error) [ACTION alertError: error];
                        else [ACTION alertError: LOCALIZE_MESSAGE(@"DeleteFailed")];
                    }
                }];
            }
        }
    }
    else if (mode == BROWSER_IMPORT){
        if (selectionEnable){
            [actionButton setTitle:@"Done"];
            self.collectionView.allowsMultipleSelection = YES;
        }
        else{
            if (selected.count > 0){
                NSString *dstRoot = [self.manager getPapa];
                NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
                
                for (int i = 0; i < selected.count; i++){
                    NSString *fileName = selected[i][@"fileName"];
                    if (![selected[i][@"isDirectory"] boolValue])
                        fileName = [fileName stringByAppendingPathExtension:@"jpg"];
                    
                    NSString *dstImage = [dstRoot stringByAppendingPathComponent:fileName];
                    NSString *dstThumb = [[[dstRoot stringByAppendingPathComponent:@"thumbnails"] stringByAppendingPathComponent:selected[i][@"fileName"]] stringByAppendingPathExtension:@"jpg"];
                    
                    NSString *srcImage = [self.path stringByAppendingPathComponent:fileName];
                    NSString *srcThumb = [[[self.path stringByAppendingPathComponent:@"thumbnails"]stringByAppendingPathComponent:selected[i][@"fileName"]] stringByAppendingPathExtension:@"jpg"];
                    
                    [parameters setObject:dstImage forKey:srcImage];
                    [parameters setObject:dstThumb forKey:srcThumb];
                }
                //send request, pop this view
                [DATA.requester startPostRequest:IMAGE_URL(@"move") parameters:parameters completeHandler:^(HTTPRequester* requester, ResponseJsonModel *data, NSHTTPURLResponse *httpURLReqponse, NSError *error) {
                    if (!error){
                        [actionButton setTitle:@"Select"];
                        self.collectionView.allowsMultipleSelection = NO;
                        selectionEnable = NO;
                        [self.manager comeToPapa];
                    }
                    //empty the selection for next round.
                    [selected removeAllObjects];
                }];
            }
        }
    }
    
    
    //clear covers
    if (covers.count > 0){
        for (UIView* view in covers){
            [view removeFromSuperview];
        }
    }
}


-(void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
//    NSDictionary *currentData = self.dataSource[indexPath.row];
    if (!selectionEnable || ([self.dataSource[indexPath.row][@"isDirectory"] boolValue] && mode==BROWSER_IMPORT)){
        [super collectionView:collectionView didSelectItemAtIndexPath:indexPath];
    }
    else{
//        actionButton.title = @"完成";
        UICollectionViewCell* selectedCell = [self.collectionView cellForItemAtIndexPath:indexPath];
        UIView* cover = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 80, 110)];
        cover.tag = 33;
        cover.backgroundColor = [UIColor whiteColor];
        cover.alpha = 0.4f;
        [selectedCell addSubview:cover];
        [covers addObject:cover];
        NSDictionary *selectedfNode = self.dataSource[indexPath.row];
        [selected addObject:selectedfNode];
        done.enabled = YES;
    }
}

-(void) collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (!selectionEnable){
//        [super collectionView:collectionView didDeselectItemAtIndexPath:indexPath];
    }
    else{
        UICollectionViewCell* selectedCell = [self.collectionView cellForItemAtIndexPath:indexPath];
        [covers removeObject:[selectedCell viewWithTag:33]];
        [selectedCell removeSubview:33];
        
        NSDictionary *deselectedfNode = self.dataSource[indexPath.row];
        [selected removeObject:deselectedfNode];
        if (selected.count == 0){
            done.enabled = NO;
        }
    }
}


-(void) didUpdateDataSource{
    for (int i=0; i<self.dataSource.count; i++){
        NSDictionary *currentData = self.dataSource[i];
        NSString *clickPath = [self.path stringByAppendingPathComponent:currentData[@"fileName"]];
        if ([clickPath isEqualToString:[self.manager getPapa]]){
            NSMutableArray *m = [NSMutableArray arrayWithArray:self.dataSource];
            [m removeObjectAtIndex:i];
            self.dataSource = [NSArray arrayWithArray:m];
            break;
        }
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
