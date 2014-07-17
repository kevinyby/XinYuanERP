//
//  SelectionBrowser.m
//  XinYuanERP
//
//  Created by bravo on 13-12-5.
//  Copyright (c) 2013年 Xinyuan4. All rights reserved.
//

#import "DefaultBrowser.h"
#import "EditableBrowser.h"
#import "PopupView.h"
#import "CreateAlbumPop.h"
#import "AskImageNamePopup.h"
#import "BubbleMenu.h"
#import "exifTagger.h"
#import "SDImageCache.h"


@interface DefaultBrowser ()<BubbleMenuDelegate>{
    //0->normal, 1->changing name
    int mode;
    BubbleMenu* mainMenu;
}

@end

@implementation DefaultBrowser

//-(void) createNavigationBar{
//    mode = 0;
//    UIBarButtonItem* cameraItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(cameraAction)];
//    UIBarButtonItem *addItem = [[UIBarButtonItem alloc] initWithTitle:@"编辑" style:UIBarButtonItemStylePlain target:self action:@selector(addAction)];
//    NSArray* actionButtonItems =  @[addItem,cameraItem];
//    
//    NSString* lastPart = [[self.path componentsSeparatedByString:@"/"] lastObject];
//    self.navigationItem.title = lastPart;
//    if ([self.path isEqualToString:@"BusinessCards"]){
//        self.navigationItem.title = @"名片夹首页";
//        actionButtonItems = @[addItem];
//    }
//    self.navigationItem.rightBarButtonItems = actionButtonItems;
//}

-(id) initWithPath:(NSString *)newPath{
    if (self = [super initWithPath:newPath]){
        UIImage* normal = [UIImage imageNamed:@"bubbleItem"];
        UIImage* highlighted = [UIImage imageNamed:@"bubbleItem_highlighted.png"];
        BubbleMenuItem* camera = [[BubbleMenuItem alloc] initWithImage:normal title:@"shot" highlightedImage:highlighted contentImage:nil hightedContentImage:nil];
        BubbleMenuItem* edit = [[BubbleMenuItem alloc] initWithImage:normal title:@"edit" highlightedImage:highlighted contentImage:nil hightedContentImage:nil];
        NSArray* menus = [NSArray arrayWithObjects:camera,edit, nil];
        mainMenu = [[BubbleMenu alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height - 145, self.view.bounds.size.width, 140) menus:menus];
        mainMenu.delegate = self;
        [self.view addSubview:mainMenu];
    }
    return self;
}

#pragma mark - bubble menu delegate
-(void) bubbleMenu:(BubbleMenu *)menu didSelectAtIndex:(NSInteger)idx{
    if (idx == 0){
        if ([self.path isEqualToString:@"BusinessCards"]){
            [PopupViewHelper popAlert:@"不允许" message:@"首页不能摆放照片" style:UIAlertViewStyleDefault actionBlock:nil dismissBlock:nil buttons:LOCALIZE_KEY(@"OK"), nil];
        }
        else{
            [self cameraAction];
        }
    }
    else if (idx == 1){
        [self addAction];
    }
}

-(void)browserDidRefresh{
    NSString* lastPart = [[self.path componentsSeparatedByString:@"/"] lastObject];
    [mainMenu setTitle:lastPart];
}

-(FileBrowser*) nextBrowserWithPath:(NSString *)newPath{
    return [[DefaultBrowser alloc] initWithPath:newPath];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

-(void) addAction{
    [PopupViewHelper popSheet:@"编辑" inView:self.view actionBlock:^(UIView *popView, NSInteger index) {
        if (index == 0){
            //create album
            [self albumAction];
        }else if (index == 1){
            if ([self.path isEqualToString:@"BusinessCards"]){
                [PopupViewHelper popAlert:@"不允许" message:@"首页不能导入" style:UIAlertViewStyleDefault actionBlock:nil dismissBlock:nil buttons:LOCALIZE_KEY(@"OK"), nil];
            }
            else{
            [self.manager importBehaviour];
            }
            
        }
        else if (index == 2){
            if (mode==0){
                mode = 1;
            }
        }
        else if (index == 3){
            //delete
            [self.manager deleteBehaviour];
        }
        else if (index == 4){
            if (mode != 2){
                mode = 2;
            }
        }
    } buttons:@"新名片夹",@"从其他资料夹导入",@"更改档名",@"删除",@"备注",@"取消", nil];
}

-(void) cameraAction{
    [self.manager cameraBehaviour];
}

-(void) albumAction{
    self.popup = [PopupView popWithType:[CreateAlbumPop class]
                                confirm:^(PopupView* view,NSDictionary* data){
                                    //check data
                                    RequestJsonModel* model = [RequestJsonModel getJsonModel];
                                    model.path = PATH_LOGIC_CREATE(CATEGORIE_CARDS);
                                    [model addModels:@"CardsAlbums", nil];
                                    [model addObjects:data, nil];
                                    NSString* albumName = data[@"albumName"];
                                    [DATA.requester startPostRequest:model
                                                     completeHandler:^(HTTPRequester* requester,ResponseJsonModel *data, NSHTTPURLResponse *httpURLReqponse, NSError *error) {
                                                         if (error) {
                                                             NSLog(@"create album failed");
                                                         } else {
                                                             NSLog(@"create success");

                                                             NSString *newPath = [self.path stringByAppendingPathComponent:albumName];
                                                             NSDictionary *createBaseModel = @{UPLOAD_Data:[[NSData alloc] init],UPLOAD_FileName:[[newPath stringByAppendingPathComponent:@".Ds_Store"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]};
                                                             
                                                             NSDictionary *createThumbModel = @{UPLOAD_Data:[[NSData alloc] init],UPLOAD_FileName:[[[newPath stringByAppendingPathComponent:@"thumbnails"] stringByAppendingPathComponent:@".Ds_Store"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]};
                                                             
                                                             [HTTPBatchRequester startBatchUploadRequest:@[createBaseModel,createThumbModel] url:IMAGE_URL(UPLOAD) identifications:@[@"create1",@"create2"] delegate:self completeHandler:^(HTTPRequester *requester, ResponseJsonModel *model, NSHTTPURLResponse *httpURLReqponse, NSError *error) {
                                                                 
                                                                 [self refreshCollectionView];
                                                                 [MBProgressHUD hideHUDForView:self.view animated:YES];
                                                             }];
                                                         }
                                                     }];
                                    [self.popup dismissWithAnimate:YES];
                                }
                                 cancel:^(PopupView* view){
                                     //do something cancle here.
                                     NSLog(@"create cancel");
                                 }];
    [self.view addSubview:self.popup];
    [self.popup showWithAnimate:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void) uploadImageWithData:(NSData *)imageData{
    UIImage* image = [UIImage imageWithData:imageData];
    imageData = [ImageHelper resizeWithImage:image scale:0.3 compression:0.5f];
    
    //create thumbnal
    NSData* thumbData = [ImageHelper resizeWithImage:image scale:0.1 compression:0.25f];
    UIImage* thumb = [UIImage imageWithData:thumbData];
    /* the method above suffer some orientation problem, but we used these thumb as reframed, so its looked just ok in the cell */
    PopupView* popup = [PopupView popWithType:[AskImageNamePopup class] confirm:^(PopupView *popview, NSDictionary *data) {
        NSString* imageName = [NSString stringWithFormat:@"%@.jpg",data[@"imageName"]];
        
        NSString* file_upload_path = [[self.path stringByAppendingPathComponent:imageName] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        NSString* thumb_upload_path = [[[self.path stringByAppendingPathComponent:@"thumbnails"] stringByAppendingPathComponent:imageName] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        //here I cache thumb first.
        NSString* cachePath = [[self.path stringByAppendingPathComponent:@"thumbnails"] stringByAppendingPathComponent:imageName];
        [FileManager saveDataToFile:[FileManager libraryCachesPath:cachePath] data:thumbData];
        //update album thumb as well
        NSArray* fileRoutine = [self.path componentsSeparatedByString:@"/"];
        NSString* currentAlbumName = fileRoutine.lastObject;
        //using currentAlbumName as fileName to replace the previous file
        if (fileRoutine.count >= 2){
            NSString* targetPath = [[[[[fileRoutine subarrayWithRange:NSMakeRange(0, fileRoutine.count-1)] componentsJoinedByString:@"/"] stringByAppendingPathComponent:@"thumbnails"] stringByAppendingPathComponent:currentAlbumName] stringByAppendingPathExtension:@"jpg"];
            
            [FileManager saveDataToFile:[FileManager libraryCachesPath:targetPath] data:thumbData];
            
        }
        
        NSDictionary* realImageModel = @{UPLOAD_Data:imageData,UPLOAD_FileName:file_upload_path};
        NSDictionary* thumbModel = @{UPLOAD_Data:thumbData,UPLOAD_FileName:thumb_upload_path};
        //update:2013.12.10-->I decide move the album thumbnail method
        //to server side by executing
        //'rm originfile && ln -s uploadedfile newfile' in bash command.
        
        //update data sourcek
        NSMutableArray *newDataSource = [NSMutableArray arrayWithArray:self.dataSource];
        NSDictionary* newData = @{@"fileName":data[@"imageName"],@"thumbnail":[thumb copy],@"isDirectory":@NO};
        [newDataSource addObject:newData];
        
        self.dataSource = [NSArray arrayWithArray:newDataSource];
        NSString* newPhotoURL = [NSString stringWithFormat:@"%@?%@",IMAGE_URL(DOWNLOAD), file_upload_path];
        [self.photos addObject:[[MWPhoto alloc] initWithURL:[NSURL URLWithString:newPhotoURL]]];
        
        [HTTPBatchRequester startBatchUploadRequest:@[realImageModel,thumbModel] url:IMAGE_URL(UPLOAD) identifications:@[@"real",@"thumb"] delegate:self completeHandler:nil];
        [popview dismissWithAnimate:YES];
        
    } cancel:^(PopupView *popview) {
        [popview dismissWithAnimate:YES];
    }];
     
    [self.view addSubview:popup];
    [popup showWithAnimate:YES];
}

#pragma mark - http delegate
-(void) didFailRequestWithError:(HTTPRequester *)request error:(NSError *)error{
    
}

-(void) didFinishReceiveData:(HTTPRequester *)request data:(ResponseJsonModel *)data{
        if ([request.identification isEqualToString:@"real"]){
            //upload

            [self.collectionView reloadData];
            
        }
        else if ([request.identification isEqualToString:@"create2"]){
            
        }
        else{
            [super didFinishReceiveData:request data:data];
        }
}

-(void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (mode==0){
        [super collectionView:collectionView didSelectItemAtIndexPath:indexPath];
    }else if (mode == 1){//rename
        NSMutableDictionary* currentSelect = [self.dataSource[indexPath.row] mutableCopy];
        NSMutableArray* multiCopy = [self.dataSource mutableCopy];
        PopupView* newName = [PopupView popWithType:[AskImageNamePopup class] confirm:^(PopupView *popview, NSDictionary *data) {
            //
            NSString* src = [self.path stringByAppendingPathComponent:currentSelect[@"fileName"]];
            NSString* thumb_src = [[[self.path stringByAppendingPathComponent:@"thumbnails"] stringByAppendingPathComponent:currentSelect[@"fileName"]] stringByAppendingPathExtension:@"jpg"];
            
            NSString* dst = [self.path stringByAppendingPathComponent:data[@"imageName"]];
            NSString* thumb_dst = [[[self.path stringByAppendingPathComponent:@"thumbnails"] stringByAppendingPathComponent:data[@"imageName"]]stringByAppendingPathExtension:@"jpg"];
            
            if (![currentSelect[@"isDirectory"] boolValue]){
                src = [src stringByAppendingPathExtension:@"jpg"];
                dst = [dst stringByAppendingPathExtension:@"jpg"];
            }
            
            [HTTPBatchRequester startBatchDownloadRequest:@[@{src:dst},@{thumb_src:thumb_dst}] url:IMAGE_URL(@"rename") identifications:@[@"rename1",@"rename2"] delegate:nil completeHandler:^(HTTPRequester *requester, ResponseJsonModel *model, NSHTTPURLResponse *httpURLReqponse, NSError *error) {
                if (!error){
                    
                    currentSelect[@"fileName"] = data[@"imageName"];
                    multiCopy[indexPath.row] = currentSelect;
                    self.dataSource = multiCopy;
                    [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
                    if([currentSelect[@"isDirectory"] boolValue]){
                        //request server to change name
                        [AppServerRequester modifyModel:@"CardsAlbums" department:CATEGORIE_CARDS objects:@{@"albumName":data[@"imageName"]} identities:@{} completeHandler:^(ResponseJsonModel *data, NSError *error) {
                            if (!error){
                                NSLog(@"name refresh!");
                            }
                        }];
                    }
                    else{
                        //another request?
                    }
                    mode = 0;
                    [popview dismissWithAnimate:YES];
                }
            }];
        } cancel:^(PopupView *popview) {
            mode = 0;
        }];
        
        [self.view addSubview:newName];
        [newName showWithAnimate:YES];
    }
    else if (mode == 2){//add description
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        NSDictionary* selected = [self.dataSource objectAtIndex:indexPath.row];
        NSString* fileName = [selected[@"fileName"] stringByAppendingPathExtension:@"jpg"];
        [HTTPBatchRequester startBatchDownloadRequest:@[@{@"PATH":[[self.path stringByAppendingPathComponent:fileName] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]}]
                                                  url:IMAGE_URL(DOWNLOAD)
                                      identifications:nil
                                             delegate:nil
                                      completeHandler:^(HTTPRequester *requester, ResponseJsonModel *response, NSHTTPURLResponse *httpURLReqponse, NSError *error) {
            
                                          [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                                          mode = 0;
                                          if (!error){
                                              NSLog(@"hahaha");
                                              NSData* rawImageData = response.binaryData;
                                              if (rawImageData){
                                                  PopupView* comment = [PopupView popWithType:[AskImageNamePopup class] confirm:^(PopupView *popview, NSDictionary *data) {
                                                      NSData* newData = [exifTagger tagUserComment:data[@"imageName"] ToImageData:rawImageData];
                                                      if (newData){
                                                          [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                                                          NSString* replace =  [[self.path stringByAppendingPathComponent:fileName] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                                                          
                                                          SDImageCache* imagecache = [SDImageCache sharedImageCache];
                                                          NSString* imageURL = [NSString stringWithFormat:@"%@?%@",IMAGE_URL(DOWNLOAD),replace];
                                                          [imagecache removeImageForKey:imageURL];
                                                          self.photos[indexPath.row] = [[MWPhoto alloc] initWithURL:[NSURL URLWithString:imageURL]];
                                                          
                                                          
                                                          [HTTPBatchRequester startBatchUploadRequest:@[@{UPLOAD_Data:newData,UPLOAD_FileName:replace}] url:IMAGE_URL(UPLOAD) identifications:nil delegate:nil completeHandler:^(HTTPRequester *requester, ResponseJsonModel *response, NSHTTPURLResponse *httpURLReqponse, NSError *error) {
                                                              [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                                                              if (!error){
                                                                  [popview dismissWithAnimate:YES];
                                                                  [PopupViewHelper popAlert:@"success" message:@"备注成功" style:UIAlertViewStyleDefault actionBlock:nil dismissBlock:nil buttons:@"ok", nil];
                                                              }else{
                                                                  [PopupViewHelper popAlert:@"failed" message:@"备注失败" style:UIAlertViewStyleDefault actionBlock:nil dismissBlock:nil buttons:@"ok", nil];
                                                              }
                                                          }];
                                                      }
                                                  } cancel:^(PopupView *popview) {
                                                      //
                                                  }];
                                                  [self.view addSubview:comment];
                                                  [comment showWithAnimate:YES];
                                              }
                                          }

        }];
    }
}

@end
