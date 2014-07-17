//
//  FileBrowser.m
//  XinYuanERP
//
//  Created by bravo on 13-12-5.
//  Copyright (c) 2013年 Xinyuan4. All rights reserved.
//

#import "FileBrowser.h"
#import "DefaultBrowser.h"
#import "AlbumCell.h"
#import "CardCell.h"
#import "AskPasswordPopup.h"

typedef BOOL(^filterBlock)(id element);

@interface FileBrowser ()<HTTPRequesterDelegate,MWPhotoBrowserDelegate>{
    MWPhotoBrowser* photoBrowser;
    int numberOfFolders;
}

@end

@implementation FileBrowser

@synthesize path,collectionView,dataSource,link,passwords,popup,manager,dir_name_id,photos;

//for compatible
-(id) init{
    self = [self initWithPath:@""];
    return self;
}

-(id) initWithPath:(NSString *)newPath{
    self = [super init];
    if (self){
        self.path = newPath;
        self.passwords = [[NSMutableDictionary alloc] init];
        self.dir_name_id = [[NSMutableDictionary alloc] init];
        self.photos = [[NSMutableArray alloc] init];
        photoBrowser = [[MWPhotoBrowser alloc] initWithDelegate:self];
        photoBrowser.zoomPhotosToFill = NO;
        photoBrowser.displayActionButton = YES;
        photoBrowser.displayNavArrows = NO;
        photoBrowser.wantsFullScreenLayout = YES;
        
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.minimumInteritemSpacing = 3.0f;
        layout.minimumLineSpacing = 30.0f;
        layout.sectionInset = UIEdgeInsetsMake(10, 10, 0, 0);
        CGRect frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
        self.collectionView = [[UICollectionView alloc] initWithFrame:frame collectionViewLayout:layout];
        [self.collectionView setDataSource:self];
        [self.collectionView setDelegate:self];
        [self.collectionView registerClass:[AlbumCell class] forCellWithReuseIdentifier:@"albumCell"];
        [self.collectionView registerClass:[CardCell class] forCellWithReuseIdentifier:@"cardCell"];
        self.collectionView.backgroundColor = [UIColor lightTextColor];
        
        UISwipeGestureRecognizer* swipBack = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipBack:)];
        swipBack.direction = UISwipeGestureRecognizerDirectionRight;
        [self.view addGestureRecognizer:swipBack];
    }
    return self;
}

-(void) swipBack:(UISwipeGestureRecognizer*)swipGesture{
    [self.manager stepBack];
}

- (void)downloadThumbnails {
    //request thumbnails
    NSMutableArray *paths = [[NSMutableArray alloc] init];
    NSMutableArray *ids = [[NSMutableArray alloc] init];
    for(int i=0;i<self.dataSource.count;i++){
        NSDictionary *data = self.dataSource[i];
        NSString *fileName = data[@"fileName"];
        NSString *newpath = [[[self.path stringByAppendingPathComponent:@"thumbnails"] stringByAppendingPathComponent:fileName] stringByAppendingPathExtension:@"jpg"];
        [paths addObject:@{@"PATH":newpath}];
        NSString *idstr = [NSString stringWithFormat:@"%@_%d",self.path,i];
        [ids addObject:idstr];
    }
    
    [HTTPBatchRequester startBatchDownloadRequest:paths url:IMAGE_URL(@"getthumbnails") identifications:ids delegate:self completeHandler:nil];
}

#pragma mark - HTTPRequester delegate method
-(void) didFinishReceiveData:(HTTPRequester *)request data:(ResponseJsonModel *)data{
    
    
    int index;
    if (request.identification){
        NSArray *prefix_id =[request.identification componentsSeparatedByString:@"_"];
        //abandon this data
        if (![prefix_id[0] isEqualToString:self.path]) return;
        index = [prefix_id[1] intValue];
        UIImage* thumb = [UIImage imageWithData:data.binaryData];
        /*
         Structrure of fnode:
         
         fnode={fileName:string,
         isDirectory: int,
         thumbnail:UIImage}
         
         */
        NSDictionary *fnode = [self.dataSource[index] mutableCopy];
        if (thumb){
            [fnode setValue:thumb forKey:@"thumbnail"];
            NSMutableArray* m = [NSMutableArray arrayWithArray:self.dataSource];
            m[index] = fnode;
            self.dataSource = [NSArray arrayWithArray:m];
            
            //cache the thumb in local
            NSString* cachePath = [FileManager libraryCachesPath:[self.path stringByAppendingPathComponent:@"thumbnails"]];
            [FileManager createFolderIfNotExist:cachePath];
            [FileManager saveDataToFile:[[cachePath stringByAppendingPathComponent:fnode[@"fileName"]] stringByAppendingPathExtension:@"jpg"] data:UIImageJPEGRepresentation(thumb, 0.0f)];
            
        }
        NSIndexPath* indexPath = [NSIndexPath indexPathForItem:index inSection:0];
        //prevent crash
        if (self.dataSource.count == 1){
            [self.collectionView reloadData];
        }
        else
            [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
    }
}

-(void) didFailRequestWithError:(HTTPRequester *)request error:(NSError *)error{
    
}

/**
 *  Coompare the new list from server with local list
 *  check whether there is any removal, if yes, return
 *  the removed.
 *
 *  @param newlist new file list grabed from server.
 *
 *  @return removed list if exists, otherwise nil.
 */
-(NSArray*) checkRemove:(NSArray*)newlist{
    //get local cache file list.
    NSString* checkPath = [[FileManager libraryCachesPath:self.path] stringByAppendingPathComponent:@"thumbnails"];
    
    NSArray* localFiles = [FileManager getFileNamesIn:checkPath];
    
    NSMutableArray* truelist = [[NSMutableArray alloc] init];
    for (NSString* f in newlist){
        if (!([f isEqualToString:@"thumbnails"] || [f isEqualToString:@".DS_Store"])){
            if (f.length > 4 && [[f substringFromIndex:f.length-4] isEqualToString:@".jpg"]){
                [truelist addObject:f];
            }else{
                [truelist addObject:[f stringByAppendingPathExtension:@"jpg"]];
            }
        }
    }
    
    
    if (truelist.count < localFiles.count){
        //something must be removed.
        //building hash table from newlist
        NSMutableDictionary* serverSideFilesHash = [[NSMutableDictionary alloc] initWithCapacity:truelist.count];
        for (NSString* filename in truelist){
            [serverSideFilesHash setObject:[NSNumber numberWithInt:1] forKey:filename];
        }
        
        //walk through local files, check whether exists.
        //if not, confirm deleted.
        NSMutableArray* deleted = [[NSMutableArray alloc] init];
        for (NSString* filename in localFiles){
            if (![serverSideFilesHash objectForKey:filename]){
                [deleted addObject:filename];
            }
        }
        
        return deleted;
    }
    return nil;
}

/**
 *  delete file from cache in current folder.
 * if param is nil then delete all files.
 *
 *  @param list A list of files to be delete, if nil then all files would be delete.
 */
-(void) removeFromCache:(NSArray*)list{

    //try to delete the files in current folder which is in the list.
    if (list){
        for (NSString* filename in list){
            [FileManager deleteFile:[[FileManager libraryCachesPath:[self.path stringByAppendingPathComponent:@"thumbnails"]] stringByAppendingPathComponent:filename]];
        }
    }
    else{
        //delete entire directory, because its empty now.
        [FileManager deleteFile:self.path];
    }
}

/**
 *  refresh data for current level of resources
 */
-(void) refreshCollectionView{
    //start a request to file server, get all file names
    [self setupEnviron];
    [DATA.requester startDownloadRequest:IMAGE_URL(DOWNLOAD)
                                   parameters:@{@"PATH":[NSString stringWithFormat:@"/%@/",self.path]}
                         completeHandler:^(HTTPRequester* requester, ResponseJsonModel *data, NSHTTPURLResponse *httpURLReqponse, NSError *error) {
                             NSArray *fileNames = data.results;
                             //empty folder
                             if (fileNames.count < 1){
                                 //delete all files if exits
                                 [self removeFromCache:nil];
                                 self.dataSource = @[];
                                 [self.collectionView reloadData];
                                 [MBProgressHUD hideHUDForView:self.view animated:YES];
                                 return;
                             }
                             //filter out directories and file
                             //the filter logic here is very ad-hoc, which is ugly, improve it!
                            NSArray *classify = [self filter:fileNames withBlock:^BOOL(id element) {
                                 NSString *name = ((NSString*)element);
                                 if (name.length < 4) return NO;
                                 NSString *extend =[name substringFromIndex:name.length-4];
                                 if([extend isEqualToString:@".jpg"])
                                     return YES;
                                 return NO;
                             }];
                             
                             //compare the list
                             NSArray* removed = [self checkRemove: fileNames];
                             if (removed){
                                 [self removeFromCache: removed];
                             }
                             
                             [self.photos removeAllObjects];
                             //fill all the photos in the array
                             /*for (NSString* imageName in fileNames){
                                 if ([imageName isEqualToString:@"thumbnails"]) continue;
                                 if (imageName.length > 4 && [[imageName substringFromIndex:imageName.length-4] isEqualToString:@".jpg"]){
                                     NSString* imageURL = [[NSString stringWithFormat:@"%@?%@/%@",IMAGE_URL(DOWNLOAD),self.path,imageName] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                                     [photos addObject:[MWPhoto photoWithURL:[NSURL URLWithString:imageURL]]];
                                 }else{
                                     //place holder
                                     [photos addObject:[NSNull null]];
                                 }
                             }*/
                             
                             for (NSString* imageName in classify[1]){
                                 NSString* imageURL = [[NSString stringWithFormat:@"%@?%@/%@.jpg",IMAGE_URL(DOWNLOAD),self.path,imageName] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                                 [self.photos addObject:[MWPhoto photoWithURL:[NSURL URLWithString:imageURL]]];
                             }
                             numberOfFolders = ((NSArray*)classify[0]).count;
                            
                             //update dataSource.
                             [self updateDataSourceWithDirectories:classify[0] files:classify[1]];
                             
                             //update password tabel.
                             [self updatePasswordTable:classify[0]];
                             
                             //reload collectionView with new data
                             [self.collectionView reloadData];
                             
                             [MBProgressHUD hideHUDForView:self.view animated:YES];
                         }];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [self browserDidRefresh];
}

-(void) didUpdatePasswords{
    [self getThumbnails:nil];
}

/**
 * get thumbnails for current folder,
 * try to grab thumb from cache, if not cached
 * downlad and cache it.
 * then update data srouce for collection view
 */
-(void) getThumbnails:(NSArray*)filenames{

    NSString* cacheThumbPath = [FileManager libraryCachesPath:[self.path stringByAppendingPathComponent:@"thumbnails"]];
    
    //this arrary stores index for entries in self.dataSource who doesn't have a cached thumbnail.
    NSMutableArray* tobeDownload = [[NSMutableArray alloc] init];
    NSMutableArray* mutableDataSource = [self.dataSource mutableCopy];
    //try to grab file from cache
    for (int i=0;i<self.dataSource.count;i++){
        NSData* thumbData;
        NSDictionary* fnode = [self.dataSource objectAtIndex:i];
        if (((NSString*)self.passwords[fnode[@"fileName"]]).length > 0){
            //this is an encrypt album
            thumbData = UIImageJPEGRepresentation([UIImage imageNamed:@"encryptAlbum.jpg"], 0.0);
        }
        else{
            NSString* thumbPath = [[cacheThumbPath stringByAppendingPathComponent:fnode[@"fileName"]] stringByAppendingPathExtension:@"jpg"];
            thumbData = [NSData dataWithContentsOfFile:thumbPath];
            if (!thumbData){
                //thumbnail do not exits, record the index for downloading.
                [tobeDownload addObject: [NSNumber numberWithInt:i]];
                continue;
            }
        }
        NSMutableDictionary* newNode = [fnode mutableCopy];
        newNode[@"thumbnail"] = [UIImage imageWithData:thumbData];
        mutableDataSource[i]= newNode;
    }
    
    if (tobeDownload.count > 0){
        //missing thumbnail, download then cache.
        NSMutableArray *paths = [[NSMutableArray alloc] init];
        NSMutableArray* ids = [[NSMutableArray alloc] initWithCapacity:tobeDownload.count];
        for (NSNumber *index in tobeDownload){
            NSString* fn = mutableDataSource[[index intValue]][@"fileName"];
            NSString* downPath = [[[self.path stringByAppendingPathComponent:@"thumbnails"] stringByAppendingPathComponent:fn] stringByAppendingPathExtension:@"jpg"];
            [paths addObject:@{@"PATH":downPath}];
            [ids addObject:[index stringValue]];
        }
        
        [HTTPBatchRequester startBatchDownloadRequest:paths
                                                url:IMAGE_URL(@"getthumbnails")
                                    identifications:ids
                                           delegate:nil
                                    completeHandler:^(HTTPRequester *requester, ResponseJsonModel *model, NSHTTPURLResponse *httpURLReqponse, NSError *error) {
                                        
                                        int index = [requester.identification intValue];
                                        if ([httpURLReqponse statusCode]==200 && model.binaryData){
                                            if (model.binaryData.length > 0){
                                                NSMutableDictionary* newnode = [[self.dataSource objectAtIndex:index] mutableCopy];
                                                newnode[@"thumbnail"] = [UIImage imageWithData:model.binaryData];
                                                NSMutableArray* md = [self.dataSource mutableCopy];
                                                md[index] = newnode;
                                                self.dataSource = [NSArray arrayWithArray:md];
                                                
                                                //cache the thumb in local
                                                NSString* cachePath = [FileManager libraryCachesPath:[self.path stringByAppendingPathComponent:@"thumbnails"]];
                                                [FileManager createFolderIfNotExist:cachePath];
                                                [FileManager saveDataToFile:[[cachePath stringByAppendingPathComponent:newnode[@"fileName"]] stringByAppendingPathExtension:@"jpg"] data:model.binaryData];
                                                
                                                NSIndexPath* indexPath = [NSIndexPath indexPathForItem:index inSection:0];
                                                if (self.dataSource.count == 1){
                                                    [self.collectionView reloadData];
                                                }
                                                else{
                                                    [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
                                                }
                                            }
                                        }
        }];
    }
    
    self.dataSource = [NSArray arrayWithArray:mutableDataSource];
    [self.collectionView reloadData];
    
}

#pragma mark - collectionView delegate method
-(void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *currentSelect = self.dataSource[indexPath.row];
    if ([currentSelect[@"isDirectory"] boolValue]){
        //show popup if the password is required.
        NSString *pwd = self.passwords[currentSelect[@"fileName"]];
        NSString *newPath = [self.path stringByAppendingPathComponent:currentSelect[@"fileName"]];
        if (pwd.length > 0){
            popup = [PopupView popWithType:[AskPasswordPopup class]
                                   confirm:^(PopupView *popview, NSDictionary *data) {
                                       if ([pwd isEqualToString:data[@"password"]]){
                                           //password is right.
                                           [self.manager naviTo:newPath];
                                           [popview dismissWithAnimate:YES];
                                       }else{
                                           [((AskPasswordPopup*)popview) showTip:@"密码错误，请重试"];
                                       }
                                   }
                                    cancel:^(PopupView *popview) {
                                        [popview dismissWithAnimate:YES];
                                    }];
            [self.view addSubview:popup];
            [popup showWithAnimate:YES];
        }
        else{
            [self.manager naviTo:newPath];
        }
    }else{
        UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:photoBrowser];
        nc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [self presentModalViewController:nc animated:YES];
        [photoBrowser reloadData];
        [photoBrowser setCurrentPhotoIndex:indexPath.row-numberOfFolders];
    }
}

#pragma mark - WMPotoBrowserDelegate
-(NSUInteger) numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser{
    return photos.count;
}

-(MWPhoto*)photoBrowser:(MWPhotoBrowser*)photoBrowser photoAtIndex:(NSUInteger)index{
    if (index < photos.count && [photos objectAtIndex:index] != [NSNull null]){
//        MWPhoto* selected = [photos objectAtIndex:index];
        
        return [photos objectAtIndex:index];
    }
    return nil;
}


#pragma mark - collectionView data
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.dataSource.count;
}

-(UICollectionViewCell*)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell *cell;
    //choose cell according to data
    NSDictionary* currentData = self.dataSource[indexPath.row];
    if ([currentData[@"isDirectory"] boolValue]){
        //use albumCell
        cell = ((AlbumCell*)[cv dequeueReusableCellWithReuseIdentifier:@"albumCell" forIndexPath:indexPath]);
        
        ((AlbumCell*)cell).label.text = currentData[@"fileName"];
        ((AlbumCell*)cell).image.image = currentData[@"thumbnail"];
    }else{
        //use CardCell
        cell = ((CardCell*)[cv dequeueReusableCellWithReuseIdentifier:@"cardCell" forIndexPath:indexPath]);
        ((CardCell*)cell).image.image = currentData[@"thumbnail"];
        ((CardCell*)cell).title.text = currentData[@"fileName"];
    }
    return cell;
}

-(CGSize) collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
     return CGSizeMake(100, 90);
}

/**
 *  Start request to server to grab password info according to directory
 *
 *  @param directories An array of directories
 */
-(void) updatePasswordTable:(NSArray*)directories{
    RequestJsonModel *directoryModel = [RequestJsonModel getJsonModel];
    directoryModel.path = PATH_LOGIC_READ(CATEGORIE_CARDS);
    
    [directoryModel addModels:@"CardsAlbums", nil];
    [directoryModel.fields addObject:@[@"id", @"albumName", @"albumPassword"]];
    NSMutableArray* criterias = directoryModel.criterias;
    NSMutableDictionary* dctionary = [NSMutableDictionary dictionary];
    [criterias addObject:@{CRITERIAL_OR: dctionary}];
    NSString *criteStr = @"";
    for (NSString* directory in directories){
        //construct criterias string eg.: @"EQ<>value1*EQ<>value2"
        criteStr = [NSString stringWithFormat:@"%@%@%@%@",criteStr,CRITERIAL_VAULE_CONNECTOR,CRITERIAL_EQ,directory];
    }
    if (criteStr.length == 0){ [self didUpdatePasswords]; return;}
    criteStr = [criteStr substringFromIndex:1];
    [dctionary setObject: criteStr forKey:@"albumName"];
    //fetch password
    [DATA.requester startPostRequest:directoryModel completeHandler:^(HTTPRequester* requester, ResponseJsonModel *data, NSHTTPURLResponse *httpURLReqponse, NSError *error) {
        NSArray *sets = data.results[0];
        for (NSArray *id_name_pwd_triple in sets){
            //[name,pwd]
            [dir_name_id setObject:id_name_pwd_triple[0] forKey:id_name_pwd_triple[1]];
            [passwords setObject:id_name_pwd_triple[2] forKey:id_name_pwd_triple[1]];
        }
        [self didUpdatePasswords];
    }];
}

-(void) updateDataSourceWithDirectories:(NSArray*)directories files:(NSArray*)files{
    NSMutableArray *new = [[NSMutableArray alloc] init];
    //update directories
    for (NSString* directory in directories){
        [new addObject:@{@"fileName":directory,@"thumbnail":[UIImage imageNamed:@"loading.jpg"],@"isDirectory":@YES}];
    }
    
    //update files
    for (NSString* file in files){
        [new addObject:@{@"fileName":file,@"thumbnail":[UIImage imageNamed:@"loading.jpg"],@"isDirectory":@NO}];
    }
    
    self.dataSource = [NSArray arrayWithArray:new];
    [self didUpdateDataSource];
}

-(void) didUpdateDataSource{}

-(NSArray*) filter:(NSArray*)array withBlock:(filterBlock)block{
    NSMutableArray *arr1 = [[NSMutableArray alloc] init];
    NSMutableArray *arr2 = [[NSMutableArray alloc] init];
    for (NSString* element in array){
        if (block(element)){
            NSLog(@"file: %@",element);
            [arr1 addObject:[element substringToIndex:element.length-4]];
        }
        else{
            if ([element isEqualToString:@".DS_Store"] || [element isEqualToString:@"thumbnails"])continue;
            NSLog(@"Directory: %@",element);
            [arr2 addObject:element];
        }
    }
    //[directory,file]
    return @[arr2,arr1];
}

-(void) viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
//    [self refreshCollectionView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
//    UIBarButtonItem *back = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:self action:@selector(back)];
//    self.navigationItem.leftBarButtonItem = back;
    [self refreshCollectionView];
    [self.view addSubview:self.collectionView];
    self.view.backgroundColor = [UIColor whiteColor];
}

-(void) setupEnviron{
    //check if current cache directory exists, or create
    NSString *cardCachePath = [FileManager libraryCachesPath:self.path];
    [FileManager createFolderIfNotExist:cardCachePath];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void) browserDidRefresh{}

-(FileBrowser*)nextBrowserWithPath:(NSString *)newPath{
    return [[FileBrowser alloc] initWithPath:newPath];
}

-(void) back{
    [self.manager stepBack];
}

@end
