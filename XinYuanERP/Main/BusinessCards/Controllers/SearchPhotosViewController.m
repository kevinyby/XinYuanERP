//
//  SearchPhotosViewController.m
//  Photolib
//
//  Created by bravo on 14-6-28.
//  Copyright (c) 2014年 bravo. All rights reserved.
//

#import "SearchPhotosViewController.h"
#import "ExportArrayDataSource.h"
#import "WDSearchTableView.h"
#import "AppDelegate.h"
#import "ExportAlbumCell.h"
#import "MWPhotoBrowser.h"
#import "PhotoDataSource.h"
#import "Card.h"
#import "PasswordController.h"

@interface SearchPhotosViewController ()<WDSearchTableViewDelegate>

@property(nonatomic,strong) ExportArrayDataSource* searchDataSource;
@property(nonatomic,weak) WDSearchTableView* searchController;
@end

@implementation SearchPhotosViewController{
    Card* _currentSelectedItem;
    PhotoDataSource* _searchContent;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"New Title" style:UIBarButtonItemStyleDone target:self action:@selector(dismissView)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)cancelAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark - WDSearchTableView Delegate
-(void) wdsearchview:(WDSearchTableView *)searchview didSelectWithItem:(id)item{
//    [self.delegate searchPhotoController:self didSelectItem:item];
    Card* selected = (Card*)item;
    _currentSelectedItem = selected;
    
    void (^selecteAction)() = ^{
        if (selected.isAlbum){
            [self.delegate searchPhotoController:self dismissedWithJumpPath:[selected.path.absoluteString stringByRemovingPercentEncoding]];
        }
        else{
            _searchContent = [[PhotoDataSource alloc] initWithItems:@[selected.photo]];
            MWPhotoBrowser* b = [[MWPhotoBrowser alloc] initWithDelegate:_searchContent];
            b.displayActionButton = YES;
            b.navigationItem.leftBarButtonItem =[[UIBarButtonItem alloc] initWithTitle:@"back" style:UIBarButtonItemStyleDone target:self action:@selector(dismissPhotoView)];
            [b setCurrentPhotoIndex:0];
            [self.navigationController pushViewController:b animated:YES];
        }
    };
    
    if (selected.password){
        PasswordController* password = [self.storyboard instantiateViewControllerWithIdentifier:@"pwdController"];
        password.title = selected.name;
        password.donePassword = ^(NSString* password){
            if ([password isEqualToString:selected.password]){
                selecteAction();
            }else{
                UIAlertView* deny = [[UIAlertView alloc] initWithTitle:nil message:@"密码错误" delegate:self cancelButtonTitle:@"ok" otherButtonTitles: nil];
                [deny show];
            }
        };
        [self.navigationController pushViewController:password animated:YES];
    }else{
        selecteAction();
    }
}


-(void) dismissPhotoView{
    NSString* jumpPath;
    if (_currentSelectedItem.isAlbum){
        jumpPath = _currentSelectedItem.path.absoluteString;
    }else{
        NSArray* split = [_currentSelectedItem.path.absoluteString componentsSeparatedByString:@"?"];
        jumpPath = [[(NSString*)split[1] stringByRemovingPercentEncoding] stringByDeletingLastPathComponent];
    }
    [self.delegate searchPhotoController:self dismissedWithJumpPath:jumpPath];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"searchControllerEmbed"]){
        self.searchController = [segue destinationViewController];
        self.searchController.delegate = self;
        NSArray* photos = [[AppDelegate sharedDelegate].Store getPhotos];
        NSArray* albums = [[AppDelegate sharedDelegate].Store getAlbums];
        NSMutableArray* source = [[NSMutableArray alloc] initWithArray:albums];
        [source addObjectsFromArray:photos];
        self.searchDataSource = [[ExportArrayDataSource alloc] initWithItems:source
                                                              cellIdentifier:@"ExportAlbumCell"
                                                          configureCellBlock:^(id cell, id item) {
                                                              [((ExportAlbumCell*)cell) configureCell:item];
        }];
        self.searchDataSource.target = self.searchController;
        self.searchController.tableView.dataSource = self.searchDataSource;
        self.searchController.searchDisplayController.searchResultsDataSource = self.searchDataSource;
    }
}


@end
