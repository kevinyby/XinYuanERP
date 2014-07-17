//
//  BrowserManager.h
//  XinYuanERP
//
//  Created by bravo on 13-12-9.
//  Copyright (c) 2013年 Xinyuan4. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "MAImagePickerController.h"

@interface BrowserManager : UIViewController<MAImagePickerControllerDelegate>

-(NSString*)rootPath;

-(void) stepBack;

-(void) importBehaviour;

-(void) deleteBehaviour;

-(void) cameraBehaviour;

-(void) naviTo:(NSString*)path;

-(NSString*)getPapa;

-(UIViewController*)getRealPapa;

-(void) comeToPapa;
@end
