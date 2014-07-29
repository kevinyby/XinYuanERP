
//
//  MainViewController.m
//  Photolib
//
//  Created by bravo on 14-6-11.
//  Copyright (c) 2014年 bravo. All rights reserved.
//

#import "MainViewController.h"
#import "BrowserViewCotroller.h"
#import "DictionaryDataSource.h"
#import "DataProvider.h"
#import "AppDelegate.h"
#import "Card.h"
#import "itemCell.h"
#import "AlbumCell.h"
#import "PhotoCell.h"
#import "MWPhotoBrowser.h"
#import "PhotoDataSource.h"
#import "NewAlbumController.h"
#import "ExportCardController.h"
#import "ExportArrayDataSource.h"
#import "ExportAlbumCell.h"
#import "WDSearchTableView.h"
#import "SearchPhotosViewController.h"
#import "MAImagePickerController.h"
#import "MBProgressHUD.h"
#import "EditController.h"
#import "YIPopupTextView.h"
#import "PasswordController.h"
#import "UIImage+UIImageAdditions.h"
/*
 This class should work as embaded browser's delegate.
 */
@interface MainViewController ()<UINavigationBarDelegate,
                                WDBrowserDelegate,
                                NewAlbumDelegate,
                                ExportCardProtocol,
                                SearchPhotosDelegate,
                                MAImagePickerControllerDelegate,
                                EditControllerDelegate,
                                UIActionSheetDelegate,
                                YIPopupTextViewDelegate>
//browsers
@property (nonatomic,weak) BrowserViewCotroller* browser;
@property (nonatomic,strong) MWPhotoBrowser* photoViewer;
//camera
@property(nonatomic,strong) MAImagePickerController* imagePicker;
//data sources
@property (nonatomic,strong) DictionaryDataSource* browserDataSource;
@property (nonatomic,strong) PhotoDataSource* photoDataSource;
@property (nonatomic,strong) ExportArrayDataSource* exportArrayDataSource;
//buttons
@property (strong, nonatomic) IBOutlet UIBarButtonItem *backButton;

@end

@implementation MainViewController{
    // is back button been hidden.
    BOOL backHidden;
    // keep track of current selected data model by browser.
    // we update this value from browser's call back.
    NSMutableArray* _currentSelectedModel;
    
    NSData* _processedImageData;
    
    //persistence storage for search list
    PhotoDataSource* _searchListDataSource;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
//    [self backBackHidden:YES];
    
    _currentSelectedModel = [[NSMutableArray alloc] init];
    
    //start request initial data...
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    id<DataProvider>store = [AppDelegate sharedDelegate].Store;
    [store initiateWithComplete:^(NSError* error){
        if (!error){
            self.browser = [[self childViewControllers] firstObject];
            self.browser.current_path = [[AppDelegate sharedDelegate].Store rootPath];
            self.browser.delegate = self;
            
            NSDictionary* initData = [store dataWithPath:self.browser.current_path];
            self.browserDataSource = [[DictionaryDataSource alloc]
                                      initWithItems:initData cellIdentifier:@[@"AlbumCell",@"PhotoCell"]
                                      configureCellBlock:^(itemCell* cell, Card* item) {
                                          cell.browserController = self.browser;
                                          [cell configreCell:item];}];
            [self.browser setDataSource:self.browserDataSource];
            
            NSArray* photos = [[AppDelegate sharedDelegate].Store photosArray];
            self.photoDataSource = [[PhotoDataSource alloc] initWithItems:photos];
            self.photoViewer = [[MWPhotoBrowser alloc] initWithDelegate:self.photoDataSource];
            self.photoViewer.displayActionButton = YES;
            self.photoViewer.displayNavArrows = YES;
            self.photoViewer.alwaysShowControls = YES;
        }
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    }];
}

-(void) viewDidAppear:(BOOL)animated{
    [_currentSelectedModel removeAllObjects];
}

-(void) backBackHidden:(BOOL)hidden{
    if (backHidden == hidden) return;
    backHidden = hidden;
    NSMutableArray *rightButtons  = [self.navigationItem.leftBarButtonItems mutableCopy];
    if (hidden){
        [rightButtons removeObject:self.backButton];
    }else{
        [rightButtons addObject:self.backButton];
    }
    [self.navigationItem setLeftBarButtonItems:rightButtons];
}

#pragma mark - WDBrowser Delegate
-(void) WDBrowser:(BrowserViewCotroller *)browser didEnterFolder:(NSString *)path isRoot:(BOOL)root{
    NSLog(@"Did enter Folder: %@", path);
    NSArray* coms = [path componentsSeparatedByString:@"/"];
    //fixme: dirty trick
    if ([[coms lastObject] isEqualToString:@"BusinessCards"]){
        self.navigationItem.title = @"首页";
    }else{
        self.navigationItem.title = [coms lastObject];
    }
//    if (root){
//        [self backBackHidden:YES];
//    }else{
//        [self backBackHidden:NO];
//    }
    
    [_currentSelectedModel removeAllObjects];
}

-(void) WDBrowser:(BrowserViewCotroller *)browser didViewPhotoAtIndex:(NSInteger)index{
//    NSLog(@"view photo at: %d",index);
    [self startPhotoViewAtIndex:index];
}

-(void) WDBrowser:(BrowserViewCotroller *)browser didUpdateDataWithPath:(NSString *)path{
    NSDictionary* newData = [[AppDelegate sharedDelegate].Store dataWithPath:path];
    [self.browserDataSource updateItems:newData];
    [self.photoDataSource updateItems:[[AppDelegate sharedDelegate].Store photosArray]];
}

-(void) WDBrowser:(BrowserViewCotroller *)browser didSelectItemAtIndex:(NSIndexPath*)index{
    Card* currentSelected = [self.browserDataSource itemAtIndex:index];
    [_currentSelectedModel addObject:currentSelected];
}

-(void) WDBrowser:(BrowserViewCotroller *)browser didDeselectItemAtIndex:(NSIndexPath *)index{
    Card* deselectedItem = [self.browserDataSource itemAtIndex:index];
    [_currentSelectedModel removeObject:deselectedItem];
}

-(void) WDBrowser:(BrowserViewCotroller *)browser didAskPasswordForData:(id)data path:(NSString *)apath{
    Card* selected = data;
    PasswordController* password = [self.storyboard instantiateViewControllerWithIdentifier:@"pwdController"];
    password.title = selected.name;
    password.donePassword = ^(NSString* password){
        if ([password isEqualToString:selected.password]){
            [self.navigationController popViewControllerAnimated:YES];
            [self.browser pushPath:apath];
            self.browser.current_pwd = password;
        }
        else{
            UIAlertView* deny = [[UIAlertView alloc] initWithTitle:nil message:@"密码错误" delegate:self cancelButtonTitle:@"ok" otherButtonTitles: nil];
            [deny show];
        }
    };
    [self.navigationController pushViewController:password animated:YES];
//    [self presentViewController:password animated:YES completion:nil];
}


#pragma mark -
#pragma mark - NewAlbum Delegate
-(void) newAlbumController:(NewAlbumController *)controller didDoneWithName:(NSString *)name passwd:(NSString *)passwd {
    [self dismissViewControllerAnimated:YES completion:nil];
    NSLog(@"create album:%@ pwd: %@",name,passwd);
    id<DataProvider>store = [AppDelegate sharedDelegate].Store;
    NSString* newPath = [NSString stringWithFormat:@"%@.content.%@",self.browser.current_path, name];
    if ([store hasAlbumInPath:newPath]){
        NSLog(@"Error: duplicate album in the same path!");
        return;
    }
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[AppDelegate sharedDelegate].Store createAlbumAtPath:self.browser.current_path name:name passwd:passwd complete:^(NSError* error, id current_data){
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [self.browserDataSource updateItems:current_data];
        [self.browser refresh];
    }];
}
-(void) newAlbumControllerDidCancle:(NewAlbumController *)controller{
    [self dismissViewControllerAnimated:YES completion:nil];
}


-(void) startPhotoViewAtIndex:(NSInteger)index{
    //issue here: https://github.com/mwaterfall/MWPhotoBrowser/issues/208
    MWPhotoBrowser* temp_b = [[MWPhotoBrowser alloc] initWithDelegate:self.photoDataSource];
    temp_b.displayActionButton = YES;
    temp_b.displayNavArrows = YES;
    [temp_b setCurrentPhotoIndex:index];
    [self.navigationController pushViewController:temp_b animated:YES];
//    [self presentViewController:temp_b animated:YES completion:nil];
}

-(void) viewPhotoWithItem:(Card*)item{
    _searchListDataSource = [[PhotoDataSource alloc] initWithItems:@[item.photo]];
    MWPhotoBrowser* b = [[MWPhotoBrowser alloc] initWithDelegate:_searchListDataSource];
    b.displayActionButton = YES;
    b.alwaysShowControls = YES;
    [b setCurrentPhotoIndex:0];
    [self.navigationController pushViewController:b animated:YES];
//    [self presentViewController:b animated:YES completion:nil];
}

#pragma mark - NavigationBar Delegate


#pragma mark -
#pragma mark - Export Delegate
-(void) exportCardController:(ExportCardController *)controller didExportToItem:(id)item{
    [self dismissViewControllerAnimated:YES completion:nil];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSMutableArray* names = [[NSMutableArray alloc] initWithCapacity:_currentSelectedModel.count];
    for (Card* c in _currentSelectedModel){
        [names addObject:c.name];
    }
    
    if ([((Card*)item).path.path isEqualToString:self.browser.current_path]){
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }
    
    [[AppDelegate sharedDelegate].Store moveItemWithName:names toPath:((Card*)item).path.path complete:^(NSError *error) {
        if (!error){
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            NSDictionary* newData = [[AppDelegate sharedDelegate].Store dataWithPath:self.browser.current_path];
            [self.browserDataSource updateItems:newData];
            [self.browser refresh];
        }
    }];
}

-(void) exportCardControllerDidCancle:(ExportCardController *)controller{
    [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark -
#pragma mark - searchPhotos delegate
//-(void) searchPhotoController:(SearchPhotosViewController *)controller didSelectItem:(id)item{
//    [self viewPhotoWithItem:item];
//}

-(void) searchPhotoController:(SearchPhotosViewController *)controller dismissedWithJumpPath:(NSString *)path{
    [self.navigationController popToRootViewControllerAnimated:YES];
    [self.browser popToRoot];
    // push in chain
    NSArray* t = [path componentsSeparatedByString:@"/"];
    if (t.count > 1){
        for (int i=2; i<t.count+1; i++){
            NSArray* subComs = [t subarrayWithRange:(NSRange){0, i}];
            NSString* subPath = [subComs componentsJoinedByString:@"/"];
            [self.browser pushPath:subPath];
        }
    }
}

#pragma mark - 
#pragma mark - MAImagePicker Delegate
-(void) imagePickerDidCancel{
    self.navigationController.navigationBarHidden = NO;
    [self.navigationController popToRootViewControllerAnimated:YES];
}

-(void)imagePickerDidChooseImageWithPath:(NSString *)path{
    [self.navigationController popToRootViewControllerAnimated:YES];
    _processedImageData = [NSData dataWithContentsOfFile:path];
    UIImage* pi = [UIImage imageWithData:_processedImageData];
    pi = [UIImage fixOrientation:pi];
    _processedImageData = UIImageJPEGRepresentation(pi, 1);
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    YIPopupTextView* popup = [[YIPopupTextView alloc] initWithPlaceHolder:@"输入名字" maxCount:10];
    popup.tag = 12345;
    popup.delegate = self;
    [popup showInView:self.view];
}

#pragma mark - 
#pragma mark - YIPopupTextView Delegate
- (void)popupTextView:(YIPopupTextView*)textView willDismissWithText:(NSString*)text{
    
    if (textView.tag == 12345){
        //photo name
        NSAssert(_processedImageData != nil, @"null image data");
        
        NSString* photoPath = [self.browser.current_path stringByAppendingPathComponent:text];
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        __block __weak id<DataProvider> store = [AppDelegate sharedDelegate].Store;
        [store addPhotoAtPath:photoPath
                     withData:_processedImageData
                     complete:^(NSError* error, UIImage* image){
                         [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                         if (error || image == nil){
                             UIAlertView* failalert = [[UIAlertView alloc] initWithTitle:nil message:@"上传失败" delegate:self cancelButtonTitle:@"ok" otherButtonTitles:nil];
                             [failalert show];
                             return;
                         }
                         // refresh file structure
                         NSDictionary* data = [store dataWithPath:self.browser.current_path];
                         [self.browserDataSource updateItems:data];
                         [self.browser refresh];
                         
                         // refresh current photo data source
                         NSArray* currentPhotos = [store photosArray];
                         [self.photoDataSource updateItems:currentPhotos];
                         [self.photoViewer reloadData];
        }];
    }
}

- (void)popupTextView:(YIPopupTextView*)textView didDismissWithText:(NSString*)text{
    [self.navigationController setNavigationBarHidden:NO];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}
#pragma mark -
#pragma mark - EditController Delegate
-(void) editController:(EditController *)controller didConfirmWithName:(NSString *)name{
    [self.navigationController popViewControllerAnimated:YES];
    Card* selectedItem = [_currentSelectedModel firstObject];
    id<DataProvider>store = [AppDelegate sharedDelegate].Store;
    NSDictionary* data = @{@"name":name};
    NSString* newPath = [NSString stringWithFormat:@"%@/%@",self.browser.current_path, name];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [store replaceItemAtPath:[self.browser.current_path stringByAppendingPathComponent:selectedItem.name] toNewPath:newPath withData:data complete:^(NSError *error) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        NSDictionary* newData = [store dataWithPath:self.browser.current_path];
        [self.browserDataSource updateItems:newData];
        [self.browser refresh];
    }];
}

#pragma mark - UIActionSheet Delegate

#pragma mark -
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark -
#pragma mark - Button Actions

-(IBAction)performBack:(id)sender{
    if ([self.browser.current_path isEqualToString:@"BusinessCards"]){
        [[self.navigationController presentingViewController] dismissViewControllerAnimated:YES completion:nil];
    }else{
        [self.browser back];
    }
}


/*
  export button clicked, push export controller
 */
- (IBAction)exportAction:(id)sender {
    NSArray* indexPaths = [self.browser indexPathsForSelectedItems];
    if (indexPaths.count < 1){
        UIAlertView* exportAlert = [[UIAlertView alloc] initWithTitle:nil message:@"請選擇需要移動的項目" delegate:self cancelButtonTitle:@"ok" otherButtonTitles:nil];
        [exportAlert show];
        return;
    }
    UINavigationController* navi = [self.storyboard instantiateViewControllerWithIdentifier:@"ExportController"];
    ExportCardController* exportController = navi.viewControllers[0];
    exportController.delegate = self;
    exportController.moves = [NSArray arrayWithArray:_currentSelectedModel];
    NSArray* albums = [[AppDelegate sharedDelegate].Store getAlbums];

    self.exportArrayDataSource = [[ExportArrayDataSource alloc] initWithItems:albums
                                                               cellIdentifier:@"ExportAlbumCell"
                                                           configureCellBlock:^(id cell, id item) {
                                                               [((ExportAlbumCell*)cell) configureCell:item];
    }];
    
    [exportController setDataSourceObj:self.exportArrayDataSource];
    
    [self presentViewController:navi animated:YES completion:nil];
}


- (IBAction)cameraAction:(id)sender {
    if ([self.browser.current_path isEqualToString:[AppDelegate sharedDelegate].Store.rootPath]){
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"不允许" message:@"首页无法放置照片" delegate:self cancelButtonTitle:@"好" otherButtonTitles:nil];
        [alert show];
        return;
    }
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:nil
                                  delegate:self
                                  cancelButtonTitle:@"取消"
                                  destructiveButtonTitle:@"相机"
                                  otherButtonTitles:@"从相册导入",nil];
    actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    [actionSheet showInView:self.view];
}

- (IBAction)editAction:(id)sender {
    if (_currentSelectedModel.count != 1){
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:nil message:@"請僅選擇一個項目進行更改" delegate:self cancelButtonTitle:@"好" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    //pop edit controller
    EditController* editController = [self.storyboard instantiateViewControllerWithIdentifier:@"EditController"];
    editController.delegate = self;
    Card* tar = [_currentSelectedModel firstObject];
    editController.theNewName = tar.name;
    [self.navigationController pushViewController:editController animated:YES];
}

- (IBAction)deleteAction:(id)sender {
    NSArray* selected = [self.browser indexPathsForSelectedItems];
    NSMutableArray* result = [[NSMutableArray alloc] initWithCapacity:selected.count];
    if (selected.count){
        //        [[AppDelegate sharedDelegate].Store removeItemAtIndexPaths:selected];
        //        [self.browser refresh];
        
        for (NSIndexPath* indexpath in selected){
            Card* c = [self.browserDataSource itemAtIndex:indexpath];
            [result addObject:c.name];
        }
        
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [[AppDelegate sharedDelegate].Store removeItemWithNames:result complete:^(NSError *error, id current_data) {
            if (error){
                NSLog(@"delete failed");
            }else{
                [self.browserDataSource updateItems:current_data];
                [self.browser refresh];
            }
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        }];
    }else{
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:nil message:@"請選擇需要刪除的項目" delegate:self cancelButtonTitle:@"ok" otherButtonTitles:nil];
        [alert show];
    }
    
}
#pragma mark -
-(void) actionSheetCancel:(UIActionSheet*)actionSheet{
    NSLog(@"cancle action sheet");
}
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    self.imagePicker = [[MAImagePickerController alloc] init];
    [self.imagePicker setDelegate:self];
    if (buttonIndex == 0){
        [self.imagePicker setSourceType:MAImagePickerControllerSourceTypeCamera];
    }else if (buttonIndex == 1){
        [self.imagePicker setSourceType:((MAImagePickerControllerSourceType*)1)];
    }
    
    if (buttonIndex != 2)
        [self.navigationController pushViewController:self.imagePicker animated:YES];
}
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    NSLog(@"hi");
    if ([segue.identifier isEqualToString:@"newAlbum"]){
        ((NewAlbumController*)((UINavigationController*)[segue destinationViewController]).viewControllers[0]).delegate = self;
    }
    else if ([segue.identifier isEqualToString:@"searchPhoto"]){
        SearchPhotosViewController* searchController = [segue destinationViewController];
        searchController.delegate = self;
    }
}


@end
