//
//  Patrol.m
//  XinYuanERP
//
//  Created by bravo on 14-1-7.
//  Copyright (c) 2014年 Xinyuan4. All rights reserved.
//

#import "ResultPage.h"
#import "GradientPolylineOverlay.h"
#import "GradientPolylineRenderer.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@interface ResultPage ()<MKMapViewDelegate>{
    MKMapView* mapView;
    CLLocationManager *locationManager;
    
    CLLocationCoordinate2D lt;
    CLLocationCoordinate2D rt;
    CLLocationCoordinate2D rb;
    CLLocationCoordinate2D lb;
    
    MKPolygon* polygon;
    GradientPolylineOverlay* polyline;
    NSString* recordFile;
}

@end

@implementation ResultPage

-(id) init{
    if ((self = [super init])){
    }
    return self;
}

-(id) initWithFileName:(NSString*)fileName{
    if ((self = [super init])){
        
        if (fileName != nil){
            recordFile = [NSString stringWithString:fileName];
        }
        mapView = [[MKMapView alloc] init];
        mapView.delegate = self;
       
    }
    return self;
}

-(NSString*) getDocumentPathWith:(NSString*)file{
    NSString* documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    return [documentsPath stringByAppendingPathComponent:file];
}

-(BOOL) fileExistsInDocument:(NSString*)fileName{
    return [[NSFileManager defaultManager] fileExistsAtPath:[self getDocumentPathWith:fileName]];
}

-(void) viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    mapView.frame = CGRectMake(0, 0, self.view.bounds.size.width+260, self.view.bounds.size.height);
    [self.view addSubview:mapView];
    [self setupBounds];
    [self placeOverlay];
    NSString* timetotime = [recordFile stringByReplacingOccurrencesOfString:@"-" withString:@":"];
    timetotime = [timetotime stringByReplacingOccurrencesOfString:@"_" withString:@"~"];
    timetotime = [timetotime stringByReplacingOccurrencesOfString:@".txt" withString:@""];
    [self.navigationItem setTitle:timetotime];
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2DMake(23.29043, 112.81630), 500, 500);
    [mapView setRegion:region];
    
    if (recordFile){
        //read file from Document first, if not exists try Server
        if ([self fileExistsInDocument:recordFile]){
            //read from local
            [self drawPolyLineFromFile:recordFile];
        }
        else{
            //read from server
        }
    }

}

-(void) exitAction{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:^{
        //
    }];
}

#pragma mark - mk delegate
-(MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay{
    UIColor* purpleColor = [UIColor colorWithRed:0.149f green:0.0f blue:0.40f alpha:0.5f];
    if (overlay == polygon){
        MKPolygonRenderer *polygonRenderer = [[MKPolygonRenderer alloc] initWithOverlay:overlay];
        polygonRenderer.fillColor = purpleColor;
        return polygonRenderer;
    }else if (overlay == polyline){
        GradientPolylineRenderer *polylineRenderer = [[GradientPolylineRenderer alloc] initWithOverlay:overlay];
        polylineRenderer.lineWidth = 12.0f;
        return polylineRenderer;
    }
    return nil;
}

-(void) drawPolyLineFromFile:(NSString*)fileName{
    NSString* filePath = [self getDocumentPathWith:fileName];
    FILE *file = fopen([filePath UTF8String], "r");
    char buffer[256];
#define MAX_POINTS 3000
    int pointCount = 0;
    int pointsMount = MAX_POINTS;
    
    CLLocationCoordinate2D *points;
    float *velocities;
    points = malloc(sizeof(CLLocationCoordinate2D)*MAX_POINTS);
    velocities = malloc(sizeof(float)*MAX_POINTS);
    
    while (fgets(buffer, 256, file) != NULL){
        NSString* result = [NSString stringWithUTF8String:buffer];
        //strip off the newline
        result = [result stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        //0:latitude, 1:longitude, 2:velocity
        NSArray* elements = [result componentsSeparatedByString:@","];
        CLLocationCoordinate2D point = CLLocationCoordinate2DMake([elements[0] doubleValue], [elements[1] doubleValue]);
        if (pointCount > MAX_POINTS){
            //magic number here, needs improvement.
            points = realloc(points, 500);
            pointsMount += 500;
        }
        velocities[pointCount] = [elements[2] floatValue];
        points[pointCount++] = point;
    }
#undef MAX_POINTS
    polyline = [[GradientPolylineOverlay alloc] initWithPoints:points velocity:velocities count:pointCount];
    [mapView addOverlay:polyline];
}

-(void) setupBounds{
    lt = CLLocationCoordinate2DMake(23.29131,112.8155);
    rt = CLLocationCoordinate2DMake(23.29061, 112.8177);
    lb = CLLocationCoordinate2DMake(23.29014, 112.8151);
    rb = CLLocationCoordinate2DMake(23.28949, 112.8173);
}

-(void) placeOverlay{
    CLLocationCoordinate2D highlight[4];
    
    highlight[0] = lt;
    highlight[1] = rt;
    highlight[2] = rb;
    highlight[3] = lb;
    
    polygon = [MKPolygon polygonWithCoordinates:highlight count:4];
    [mapView addOverlay:polygon];
}

-(void) viewWillDisappear:(BOOL)animated{
    //delete the file in Document
    NSString* filePath = [self getDocumentPathWith:recordFile];
    [FileManager deleteFile:filePath];
    
    
    //I forgot to paste stackoverflow link here,
    //but that did release some memory, by changing
    //map type, mapView will realse previous cache.
    mapView.mapType = MKMapTypeStandard;
    [mapView removeFromSuperview];
    mapView = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
