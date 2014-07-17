//
//  FileBrowser.h
//  XinYuanERP
//
//  Created by bravo on 13-12-5.
//  Copyright (c) 2013年 Xinyuan4. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "MAImagePickerController.h"
#import "MWPhotoBrowser.h"
#import "AppInterface.h"
#import "PopupView.h"
#import "BrowserManager.h"

@interface FileBrowser : UIViewController<UICollectionViewDataSource,
                                            UICollectionViewDelegateFlowLayout,
                                            HTTPRequesterDelegate>


@property(nonatomic,strong) NSString* path;
@property(nonatomic,strong) UICollectionView* collectionView;
/*
 Structrure of fnode:
 
 fnode={fileName:string,
 isDirectory: int,
 thumbnail:UIImage}
 
 */
@property(nonatomic,strong) NSArray* dataSource;
@property(nonatomic,strong) NSMutableDictionary *passwords;
@property(nonatomic,strong) NSMutableDictionary *dir_name_id;
@property(nonatomic,strong) FileBrowser* link;
@property(nonatomic,strong) PopupView* popup;
@property(nonatomic,strong) BrowserManager *manager;
@property(nonatomic,strong) NSMutableArray* photos;

-(id) initWithPath:(NSString*)newPath;

-(void) refreshCollectionView;


/**
 *  subclass should override this method
 */
-(void)browserDidRefresh;

/**
 *  subclass should override this method to return next controller.
 *
 *  @return next viewController
 */
-(FileBrowser*)nextBrowserWithPath:(NSString*)newPath;

-(void) didUpdateDataSource;




@end