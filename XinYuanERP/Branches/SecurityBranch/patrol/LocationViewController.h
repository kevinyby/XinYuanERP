//
//  LocationViewController.h
//  mapDemo
//
//  Created by bravo on 13-11-29.
//  Copyright (c) 2013年 bravo. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void(^didFinishRecord)();

@interface LocationViewController : UIViewController

@property (nonatomic,copy) didFinishRecord didFinishRecordBlock;

@end
