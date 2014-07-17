//
//  PatrolController.m
//  XinYuanERP
//
//  Created by bravo on 14-1-7.
//  Copyright (c) 2014年 Xinyuan4. All rights reserved.
//

#import "PatrolController.h"
#import "LocationViewController.h"
#import "ResultPage.h"

@interface PatrolController (){
    LocationViewController* recorder;
    ResultPage* result;
}

@end

@implementation PatrolController

-(id) initWithOrder:(NSString *)order department:(NSString *)department{
    if ((self = [super init])){
        __weak id weak_self = self;
        recorder = [[LocationViewController alloc] init];
        recorder.didFinishRecordBlock = ^{
            [weak_self dismissViewControllerAnimated:YES completion:^{
                [weak_self showRecord:@""];
            }];
        };
        result = [[ResultPage alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (self.controlMode != JsonControllerModeRead){
        [self startRecorder];
    }
    else {
        [self showRecord:self.identification];
    }
    UIButton* recorderButton = [UIButton buttonWithType:UIButtonTypeSystem];
    recorderButton.frame = CGRectMake(100, 100, 100, 50);
    [recorderButton setTitle:@"Recorder" forState:UIControlStateNormal];
    [recorderButton addTarget:self action:@selector(startRecorder) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:recorderButton];
    
    UIButton* resultButton = [UIButton buttonWithType:UIButtonTypeSystem];
    resultButton.frame = CGRectMake(100, 300, 100, 50);
    [resultButton setTitle:@"Result" forState:UIControlStateNormal];
    [resultButton addTarget:self action:@selector(showRecord:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:resultButton];
}

-(void) startRecorder{
    [self presentViewController:recorder animated:YES completion:^{
        //
    }];
}

-(void) showRecord:(NSString*)recordID{
    //fetch record file form server using recordID
    [self presentViewController:result animated:YES completion:^{
        //
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

}

@end
