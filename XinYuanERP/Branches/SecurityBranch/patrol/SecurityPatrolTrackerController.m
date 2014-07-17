//
//  SecurityPatrolTrackerController.m
//  XinYuanERP
//
//  Created by bravo on 14-1-18.
//  Copyright (c) 2014年 Xinyuan4. All rights reserved.
//

#import "SecurityPatrolTrackerController.h"
#import <CoreLocation/CoreLocation.h>
#import "ResultPage.h"

static int MAX_LOCATIONS = 3000;

@interface SecurityPatrolTrackerController()<CLLocationManagerDelegate>{
    
    ResultPage* resultPage;
    CLLocationManager *locationManager;
    CLLocationCoordinate2D *allLocations;
    float *allSpeed;
    int locationCount;
    
    
    JRButton* Button;
    NSString* startTime;
    NSString* endTime;
    
    BOOL recording;
    UIAlertView* alertView;
    
    
    NSString* uploadPath;
    
    JRImageView* lights;
    BOOL flashing;
    UIImage* lightsOff;
    UIImage* lightsOn;
    
    int recordVal;
}

@end

@implementation SecurityPatrolTrackerController

- (void)viewDidLoad
{
    [super viewDidLoad];
    //This path is crucial, should be well defined some where.
    uploadPath = @"Security/Tracker";
    
    if (self.controlMode == JsonControllerModeCreate){
        locationManager = [[CLLocationManager alloc] init];
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        locationManager.delegate = self;
        self.view.frame = [UIScreen mainScreen].bounds;
        locationCount = 0;
        allLocations = malloc(sizeof(CLLocationCoordinate2D)*MAX_LOCATIONS);
        allSpeed = malloc(sizeof(float)*MAX_LOCATIONS);
        
        Button = (JRButton*)[self.jsonView getView:@"Button"];
        [self registerEvent];
        
        lightsOff = [UIImage imageNamed:@"tracker_light_off.png"];
        lightsOn = [UIImage imageNamed:@"tracker_light_on.png"];
        lights = (JRImageView*)[self.jsonView getView:@"lights"];
        
        //One way to watch the signal is, start the location update rightaway
        // when we enter the current view. but its not for recording,
        // its just for signal watching. if the signal is not ok, we need
        // to pop to warn user that recording may fail if
        // he continue the procedure.
        recording = NO;
        flashing = NO; //for lights
        [locationManager startUpdatingLocation];
        alertView = nil;
        
        recordVal = 0;
    }
}

-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    NSLog(@"%@",keyPath);
}

-(NSString*) getCurrentTime{
    return [DateHelper stringFromDate:[NSDate date] pattern:@"HH-mm-ss"];
}

-(void) setStartTime{
    startTime = [self getCurrentTime];
}

-(void) setEndTime{
    endTime =[self getCurrentTime];
}

-(void) registerEvent{
    __weak id weak_self = self;
    __weak CLLocationManager* weak_lm = locationManager;
    __weak JRButton* weak_button = Button;
    
    Button.didClikcButtonAction = ^(id sender){
        if (![weak_self getRecording]){
            [weak_self setStartTime];
            [weak_self setRecording:YES];
            [weak_button setBackgroundImage:[UIImage imageNamed:@"tracker_button_disable.png"] forState:UIControlStateNormal];
        }else{
            [weak_self setEndTime];
            [weak_self setRecording:NO];
            [weak_self saveRecord];
            [weak_button setBackgroundImage:[UIImage imageNamed:@"tracker_button_enable.png"] forState:UIControlStateNormal];
        }
    };
    
    //rewrite the event for back button, cuz super class does not provide
    //any call back. btw having a willExitView should be good ;)
    JRButton* backBTN = (JRButton*)[self.jsonView getView: JSON_KEYS(json_NESTED_header, json_BTN_Back)];
    backBTN.didClikcButtonAction = ^void(id sender){
        [weak_lm stopUpdatingLocation];
        if (recording){
            [self saveRecord];
        }
        else{
            [VIEW.navigator popViewControllerAnimated:YES];
            //don't forget to delete the file in Document.
        }
    };
    
}

-(void) saveRecord{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSString *text = @"";
    for (int i=0;i<locationCount;i++){
        CLLocationCoordinate2D l =[self transfrom:allLocations[i]];
        float speed = allSpeed[i];
        NSString *subStr = [NSString stringWithFormat:@"%lf,%lf,%f\n",l.latitude,l.longitude,speed];
        text = [text stringByAppendingString:subStr];
    }
    
    NSError *error;
    /**
     *  upload this file to server, and also keep the copy in local Document,
     *  when exit the tracker, delete it.
     */
    NSString* filePath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_%@.txt",startTime,endTime]];
    [text writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:&error];
    
    if (!error){
        NSLog(@"save to Document");
    }else {
        NSLog(@"save to local Document failed!");
    }
    //upload this one
    NSData* fileData = [text dataUsingEncoding:NSUTF8StringEncoding];
    // use current date as folder name.
    NSString* currentdate = [DateHelper stringFromDate:[NSDate date] pattern:@"yyyyMMdd"];
    //HH:mm:ss_HH:mm:ss.txt
    NSString* uploadFileName = [NSString stringWithFormat:@"%@/%@",currentdate,[NSString stringWithFormat:@"%@_%@.txt",startTime,endTime]];
    
    [MBProgressHUD showHUDAddedTo:self.jsonView.contentView animated:YES];
    NSDictionary* uploadModel = @{UPLOAD_Data:fileData,UPLOAD_FileName:[uploadPath stringByAppendingPathComponent:uploadFileName]};
    [HTTPBatchRequester startBatchUploadRequest:@[uploadModel]
                                            url:IMAGE_URL(UPLOAD)
                                identifications:@[@"record"]
                                       delegate:nil
                                completeHandler:^(HTTPRequester *requester,
                                                  ResponseJsonModel *model,
                                                  NSHTTPURLResponse *httpURLReqponse,
                                                  NSError *error)
                                                    {
                                                        [MBProgressHUD hideAllHUDsForView:self.jsonView.contentView animated:YES];
                                                        if (!error){
                                                            //upload success
                                                            NSLog(@"upload success");
                                                            //create data in dataBase
                                                            [AppServerRequester
                                                             createModel:@"SecurityPatrolTracker"
                                                             department:DEPARTMENT_SECURITY
                                                             objects:@{@"endTime":[NSString stringWithFormat:@"%@ %@",@"0000-00-00",[endTime stringByReplacingOccurrencesOfString:@"-" withString:@":"]],@"startTime":[NSString stringWithFormat:@"%@ %@",@"0000-00-00",[startTime stringByReplacingOccurrencesOfString:@"-" withString:@":"]]}
                                                             completeHandler:^(ResponseJsonModel *data, NSError *error) {
                                                                 NSLog(@"hey");
                                                                 if (!error){
                                                                     //jump to map view
                                                                     [self switchToResultPage];
                                                                 }
                                                            }];
                                                        }
                                                    }
     ];
    
}

-(void) setRecording:(BOOL)on{
    recording = on;
}
-(BOOL) getRecording{
    return recording;
}

-(void) switchToResultPage{
    resultPage = [[ResultPage alloc] initWithFileName:[NSString stringWithFormat:@"%@_%@.txt",startTime,endTime]];
    [VIEW.navigator pushViewController:resultPage animated:YES];
}

-(void) flashLights{
    if (flashing){
        [lights setImage:lightsOn];
    }else{
        [lights setImage:lightsOff];
    }
    flashing = !flashing;
}

#pragma mark - locationManager delegate
-(void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    CLLocation *location = (CLLocation*)locations.lastObject;
    NSLog(@"%f",location.horizontalAccuracy);
    if (recording){
        [self flashLights];
        CLLocationCoordinate2D currentlocation = location.coordinate;
        float currentSpeed = ((CLLocation*)locations.lastObject).speed;
        if (locationCount-1 > MAX_LOCATIONS ){
            allLocations = realloc(allLocations, sizeof(CLLocationCoordinate2D)*500);
            allSpeed = realloc(allSpeed, sizeof(float)*500);
            MAX_LOCATIONS+= 500;
        }
        if (++recordVal > 11){
            recordVal = 0;
            allSpeed[locationCount] = currentSpeed;
            allLocations[locationCount++] = currentlocation;
        }
    }
    else{
        //watching the signal
        if (location.horizontalAccuracy < 0 ||
            location.horizontalAccuracy > 163)
        {
            if (alertView == nil){
                alertView = [PopupViewHelper popAlert:@"信号差" message:@"检测到GPS信号异常，移动至开阔地可使信号恢复" style:0 actionBlock:^(UIView *popView, NSInteger index) {
                    NSLog(@"%d",index);
                } dismissBlock:nil buttons:@"忽略并继续", nil];
            }
        }
        else{
            if (alertView){
                [alertView dismissWithClickedButtonIndex:0 animated:YES];
                alertView = nil;
            }
            else if (location.horizontalAccuracy > 48)
            {
                //average
            }
            else{
                //strong
            }
        }
    }
}

#pragma mark - gps corecteness
-(CLLocationCoordinate2D) transfrom:(CLLocationCoordinate2D)oldCoord{
    static double a = 6378245.0;
    static double ee = 0.00669342162296594323;
    
    if ([self outOfChina:oldCoord]){
        return oldCoord;
    }
    double dLat = [self transformLat:oldCoord.longitude - 105.0 y:oldCoord.latitude - 35.0];
    double dLon =[self transformLon:oldCoord.longitude - 105.0 y:oldCoord.latitude - 35.0];
    double radLat = oldCoord.latitude / 180.0 * M_PI;
    
    double magic = sin(radLat);
    magic = 1 - ee * magic * magic;
    double sqrtMagic = sqrt(magic);
    
    dLat = (dLat * 180.0) / ((a*(1-ee)) / (magic * sqrtMagic) * M_PI);
    dLon = (dLon * 180.0) / (a / sqrtMagic * cos(radLat) * M_PI);
    
    return CLLocationCoordinate2DMake(oldCoord.latitude+dLat, oldCoord.longitude+dLon);
}

-(double) transformLat:(double)x y:(double)y{
    double ret = -100.0 + 2.0 * x + 3.0 * y + 0.2 * y * y + 0.1 * x * y + 0.2 * sqrt(ABS(x));
    ret += (20.0 * sin(6.0 * x * M_PI) + 20.0 * sin(2.0 * x * M_PI)) * 2.0 / 3.0;
    ret += (20.0 * sin(y * M_PI) + 40.0 * sin(y / 3.0 * M_PI)) * 2.0 / 3.0;
    ret += (160.0 * sin(y / 12.0 * M_PI) + 320 *sin(y * M_PI / 30.0)) * 2.0 / 3.0;
    return ret;
}

-(double) transformLon:(double)x y:(double)y{
    double ret = 300.0 + x + 2.0 * y + 0.1 * x * x + 0.1 * x * y + 0.1 * sqrt(ABS(x));
    ret += (20.0 * sin(6.0 * x * M_PI) + 20.0 * sin(2.0 * x * M_PI)) * 2.0 / 3.0;
    ret += (20.0 * sin(x * M_PI) + 40.0 * sin(x / 3.0 * M_PI)) * 2.0 / 3.0;
    ret += (150.0 * sin(x / 12.0 * M_PI) + 300.0 * sin(x / 30.0 * M_PI)) * 2.0 / 3.0;
    return ret;
}

-(BOOL) outOfChina:(CLLocationCoordinate2D)coord{
    if (coord.longitude < 72.004 || coord.longitude > 137.8347)
        return true;
    if (coord.latitude < 0.8293 || coord.latitude > 55.8271)
        return true;
    return false;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void) viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    if (allLocations && allSpeed){
        free(allLocations);
        free(allSpeed);
        allLocations = nil;
        allSpeed = nil;
    }
    [locationManager stopUpdatingLocation];
}

//Never call?
-(void) dealloc{
    free(allLocations);
    free(allSpeed);
}

@end
