#import "SharedOrderListController.h"
#import "AppInterface.h"

@implementation SharedOrderListController


-(void) setInstanceVariablesValues: (BaseOrderListController*)orderlist order:(NSString*)order {
    [super setInstanceVariablesValues: orderlist order:order];
    if ([order isEqualToString:@"SharedCahierOrder"]) {
        [orderlist.requestModel addModels:order, nil];
        [orderlist.requestModel.fields addObjectsFromArray:@[@[PROPERTY_IDENTIFIER,PROPERTY_ORDERNO,@"meetDate",@"meetName"]]];
        
        orderlist.headers = @[PROPERTY_ORDERNO,@"meetDate",@"meetName"];
        orderlist.headersXcoordinates = @[@(50), @(350), @(650)];
        orderlist.valuesXcoordinates = @[@(10), @(310), @(590)];
        
        orderlist.contentsFilter = ^void(int elementIndex, int innerCount, int outterCount, NSString* section, id cellElement, NSMutableArray* cellRepository){
            if (elementIndex != 0) {
                if (cellElement) {
                    [cellRepository addObject: cellElement];
                }
            }
        };
    }
    else if ([order isEqualToString:@"SharedOutOrder"]){
        [orderlist.requestModel.fields addObjectsFromArray:@[PROPERTY_IDENTIFIER,PROPERTY_ORDERNO,@"employeeNO"]];
        [orderlist.requestModel addModels:order, nil];
        orderlist.headers = @[PROPERTY_ORDERNO,@"employeeNO"];
        orderlist.headersXcoordinates = @[@(20), @(220)];
        orderlist.valuesXcoordinates = @[@(20), @(270)];
    }
    else if ([order isEqualToString:@"SharedEventReportOrder"]){
        [orderlist.requestModel.fields addObjectsFromArray:@[@[PROPERTY_IDENTIFIER,PROPERTY_ORDERNO,@"originEmployeeNO",@"proxyEmployeeNO"]]];
        [orderlist.requestModel addModels:order, nil];
        orderlist.headers = @[PROPERTY_ORDERNO,@"origin",@"proxy"];
        orderlist.headersXcoordinates = @[@(20), @(220)];
        orderlist.valuesXcoordinates = @[@(20), @(270)];
    }
}

@end
