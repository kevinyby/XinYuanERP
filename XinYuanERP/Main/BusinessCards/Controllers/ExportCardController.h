//
//  ImportCardController.h
//  Photolib
//
//  Created by bravo on 14-6-20.
//  Copyright (c) 2014年 bravo. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ExportCardController;
@protocol ExportCardProtocol <NSObject>

-(void) exportCardControllerDidCancle:(ExportCardController*)controller;
-(void) exportCardController:(ExportCardController*)controller didExportToItem:(id)item;

@end

@interface ExportCardController : UIViewController

/* model objects selected to be moved. */
@property(nonatomic,strong) NSArray* moves;

@property(nonatomic, strong) id<ExportCardProtocol> delegate;

-(void) setDataSourceObj:(id)obj;

@end
