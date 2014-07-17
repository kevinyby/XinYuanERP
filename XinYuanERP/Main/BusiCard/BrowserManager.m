//
//  BrowserManager.m
//  XinYuanERP
//
//  Created by bravo on 13-12-9.
//  Copyright (c) 2013年 Xinyuan4. All rights reserved.
//

#import "BrowserManager.h"
#import "FileBrowser.h"
#import "DefaultBrowser.h"
#import "EditableBrowser.h"
#import "MAITreeController.h"
#import "MAImagePickerFinalViewController.h"

@interface BrowserManager (){
    MAITreeController *tree;
    DefaultBrowser *defaultBrowser;
    EditableBrowser *editableBrowser;
    
    NSMutableArray *defaultStack;
    NSMutableArray *editableStack;
    
    NSMutableDictionary* defaultMap;
    NSMutableDictionary* editableMap;
    
    MAImagePickerController *imagePicker;
    NSString *rootPath;
}

@end

@implementation BrowserManager

-(id) init{
    self = [super init];
    if (self){
        rootPath = @"BusinessCards"; //<--set the root path first.
        
        defaultBrowser = [[DefaultBrowser alloc] initWithPath:[self getFullPathWith:@""]];
        defaultBrowser.manager = self;
        editableBrowser = [[EditableBrowser alloc] initWithPath:[self getFullPathWith:@""]];
        editableBrowser.manager = self;
        
        defaultStack = [[NSMutableArray alloc] init];
        editableStack = [[NSMutableArray alloc] init];
        
        defaultMap = [[NSMutableDictionary alloc] init];
        editableMap = [[NSMutableDictionary alloc] init];
        
        imagePicker = [[MAImagePickerController alloc] init];
        [imagePicker setDelegate:self];
        [imagePicker setSourceType:MAImagePickerControllerSourceTypeCamera];
        
        self.view.backgroundColor = [UIColor whiteColor];
        tree = [[MAITreeController alloc] initWithRootViewController:defaultBrowser];
    }
    return self;
}

-(NSString*)rootPath{
    return rootPath;
}

-(NSString*)getFullPathWith:(NSString*)path{
    return rootPath == nil?nil:[rootPath stringByAppendingPathComponent:path];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

-(void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

-(void) viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    [self presentModalViewController:tree animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

}

-(void) importBehaviour{
    editableBrowser.mode = 0;
    [tree pushViewController:editableBrowser animated:YES];
    [self naviTo:rootPath];
    //naviTo side effect
    [editableStack removeLastObject];
}

-(void) deleteBehaviour{
    editableBrowser.mode = 1;//delete
    [tree pushViewController:editableBrowser animated:YES];
    [self naviTo:defaultBrowser.path];
    //naviTo side effect
    [editableStack removeLastObject];
}

-(void) cameraBehaviour{
    [tree pushViewController:imagePicker animated:YES];
}

-(void) stepBack{
    //The code is ugly here
    FileBrowser *currentView = (FileBrowser*)tree.visibleViewController;
    if ([currentView isKindOfClass:[DefaultBrowser class]]){
        if (defaultStack.count > 0){
            defaultBrowser.path = defaultStack.lastObject;
            [defaultBrowser refreshCollectionView];
             NSString* folderName = [defaultStack.lastObject componentsSeparatedByString:@"/"].lastObject;
            [defaultMap removeObjectForKey:folderName];
            [defaultStack removeLastObject];
        }else{
            [self dismissModalViewControllerAnimated:YES];
            [VIEW.navigator popViewControllerAnimated:YES];
        }
    }else{
        if (editableStack.count > 0){
            editableBrowser.path = editableStack.lastObject;
            [editableBrowser refreshCollectionView];
            NSString* folderName = [editableStack.lastObject componentsSeparatedByString:@"/"].lastObject;
            [editableMap removeObjectForKey:folderName];
            [editableStack removeLastObject];
        }
        else{
            [tree popToRootViewControllerAnimated:YES];
        }
    }
}


-(void) naviTo:(NSString *)path{
    FileBrowser *fb = (FileBrowser*)tree.visibleViewController;
    if ([fb isKindOfClass:[DefaultBrowser class]]){
        [defaultStack addObject:fb.path];
        defaultBrowser.path = path;
        [defaultBrowser refreshCollectionView];
    }
    else{
        [editableStack addObject:fb.path];
        editableBrowser.path = path;
        [editableBrowser refreshCollectionView];
    }
}

-(NSString*)getPapa{
    return defaultBrowser.path;
}

-(UIViewController*)getRealPapa{
    return defaultBrowser;
}

-(void) comeToPapa{
    [tree popToViewController:defaultBrowser animated:YES];
    [defaultBrowser refreshCollectionView];
}


#pragma mark - imagePicker Delegate
-(void) imagePickerDidCancel{
    if ([tree.topViewController isKindOfClass:[MAImagePickerController class]]){
        [tree popViewControllerAnimated:YES];
    }
}

-(void) imagePickerDidChooseImageWithPath:(NSString *)path{
    NSData* imageMeta = [NSData dataWithContentsOfFile:path];//original image data
    
    if ([tree.visibleViewController isKindOfClass:[MAImagePickerFinalViewController class]]){
        [tree popToViewController:defaultBrowser animated:YES];
        [defaultBrowser uploadImageWithData:imageMeta];
    }

}
@end
