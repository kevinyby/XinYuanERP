//
//  SelectionBrowser.h
//  XinYuanERP
//
//  Created by bravo on 13-12-5.
//  Copyright (c) 2013年 Xinyuan4. All rights reserved.
//

#import "FileBrowser.h"

@protocol HTTPRequesterDelegate;


@interface DefaultBrowser : FileBrowser

-(void) uploadImageWithData:(NSData*)imageData;

@end
