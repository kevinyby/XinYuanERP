#import "SecurityListController.h"

#import "AppInterface.h"
#import "ResultPage.h"

//join two strings by '.'
#define LK(order,attribute) [NSString stringWithFormat:@"%@%@%@", order, LOCALIZE_KEY_CONNECTOR, attribute]

@implementation SecurityListController

-(void) setInstanceVariablesValues
{
    NSString* order = self.order;
    [super setInstanceVariablesValues];
    /* Note: this long long if-else statements can be refactored with polymorphism
              by moving these individual statement into each "order" calss*/
    if ([order isEqualToString:@"SecurityPatrolOrder"]){
        [self.requestModel addModels:order, nil];
        [self.requestModel.fields addObjectsFromArray:@[@[PROPERTY_IDENTIFIER, PROPERTY_ORDERNO, @"protralDate"]]];
        self.headers = @[PROPERTY_ORDERNO,LK(order,@"protralDate")];
        self.headersXcoordinates = @[@(100), @(500)];
    }
    else if ([order isEqualToString:@"Patrol"]){
        
    }
    else if ([order isEqualToString:@"SecurityVisitorOrder"]){
        [self.requestModel addModels:order, nil];
        [self.requestModel.fields addObjectsFromArray:@[@[PROPERTY_IDENTIFIER,PROPERTY_ORDERNO,@"visitEmployeeNO"]]];
        self.headers = @[PROPERTY_ORDERNO, LK(order,@"visit")];
        self.headersXcoordinates = @[@(100),@(500)];
    }
    else if ([order isEqualToString:@"SecurityPatrolTracker"]){
        [self.requestModel addModels:order, nil];
        [self.requestModel.fields addObjectsFromArray:@[@[PROPERTY_IDENTIFIER,PROPERTY_ORDERNO,@"createDate",@"startTime",@"endTime"]]];
        self.headers =@[@"年",@"月",@"日",@"时段"];
        self.headersXcoordinates= @[@(50),@(100),@(150),@(450)];
        self.valuesXcoordinates = @[@(40),@(400),@(530)];
        
        //we don't need orderID, orderNO to be presented here,
        //so we filter them out, then we have to split the orderDate
        //and join the startTime and endTime with '~'
        //format: yyyy mm dd hh:mm~hh:mm
        self.contentsFilter = ^void(int elementIndex, int innerCount, int outterCount, NSString* section, id cellElement, NSMutableArray* cellRepository){
            id valueObj = nil;
            if (elementIndex < 2){
                return ; //filter first two
            }else if (elementIndex == 2){
                //split time with format
                NSString* rawDate = [NSString stringWithString:cellElement];
                //["yyyy-mm-dd","hh:mm:ss"]
                NSArray* td = [rawDate componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                //pick the first part
                NSString* newDate = [td[0] stringByReplacingOccurrencesOfString:@"-" withString:@"    "];
                valueObj = newDate;
            }
            else if (elementIndex == 3){
                //start time
                valueObj = [NSString stringWithFormat:@"%@ ~ ",[cellElement componentsSeparatedByString:@" "][1]];
            }
            else if (elementIndex == 4){
                valueObj = [cellElement componentsSeparatedByString:@" "][1];
            }
            
            if (valueObj) {
                [cellRepository addObject: valueObj];
            }
        };
        
        //We should avoid entering the tracker controloller(default behaviour)
        //instead, rewritting the select event is a better trick.
        self.appTableDidSelectRowBlock = ^void(AppSearchTableViewController* controller ,NSIndexPath* realIndexPath)
        {
            //grab the data from previous list.
            NSArray* controllers = VIEW.navigator.viewControllers;
            BaseOrderListController* listController = (BaseOrderListController*)[controllers lastObject] ;
            FilterTableView* tableViewObj = listController.headerTableView.tableView;
            NSIndexPath* selectIndexPath = [tableViewObj getRealIndexPathInFilterMode: [tableViewObj indexPathForSelectedRow]];
            
            NSArray* realValues = [listController valueForIndexPath: selectIndexPath];
            
            NSString* date = [NSString stringWithString:realValues[2]];
            NSString* start = [NSString stringWithString:realValues[3]];
            NSString* end = [NSString stringWithString:realValues[4]];
            //filter out the annoying chinese chars
            NSArray* startArr = [start componentsSeparatedByString:@" "];
            NSArray* endArr = [end componentsSeparatedByString:@" "];
            
            
            start = startArr[1];
            end = endArr[1];
            //yyyy-MM-dd HH:mm:ss
            NSDate* newDate =  [DateHelper dateFromString:date pattern:PATTERN_DATE_TIME];
            NSString* fixedDate = [DateHelper stringFromDate:newDate pattern:@"yyyyMMdd"];
            
            //compose file name
            start = [start stringByReplacingOccurrencesOfString:@":" withString:@"-"];
            end = [end stringByReplacingOccurrencesOfString:@":" withString:@"-"];
            NSString* fileName = [NSString stringWithFormat:@"%@/%@_%@.txt",fixedDate,start,end];
            NSString* filePath = [@"Security/Tracker" stringByAppendingPathComponent:fileName];
            
            
            UIView* presentView  = ((UIViewController*)(VIEW.navigator.viewControllers).lastObject).view;
            [MBProgressHUD showHUDAddedTo:presentView animated:YES];
            [HTTPBatchRequester startBatchDownloadRequest:@[@{@"PATH":filePath}] url:IMAGE_URL(@"gettrackfile") identifications:@[@"tracker"] delegate:nil completeHandler:^(HTTPRequester *requester, ResponseJsonModel *model, NSHTTPURLResponse *httpURLReqponse, NSError *error) {
                if (!error && model.binaryData != nil){
                    NSString* currentFile = [[NSString alloc] initWithData:model.binaryData encoding:NSUTF8StringEncoding];
                    //save the file into the local Document, switch to result view.
                    //The problem is, Apple says this kinda of data should be
                    //save to Cache, not Document, doing this would have risk of being rejected
                    NSString* fname = [NSString stringWithFormat:@"%@_%@.txt",start,end];
                    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                    NSString *documentsDirectory = [paths objectAtIndex:0];
                    NSString* filePath = [documentsDirectory stringByAppendingPathComponent:fname];
                    NSError* error;
                    [currentFile writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:&error];
                    [MBProgressHUD hideHUDForView:presentView animated:YES];
                    if (!error){
                        //save success, jump
                        ResultPage* result = [[ResultPage alloc] initWithFileName:fname];
                        [VIEW.navigator pushViewController:result animated:YES];
                    }
                    else{
                        //failed, exit
                    }
                }
                NSLog(@"l");
            }];
        };
        
        
    }
}

@end
