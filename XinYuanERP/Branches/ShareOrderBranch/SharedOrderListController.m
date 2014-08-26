#import "SharedOrderListController.h"
#import "AppInterface.h"

@implementation SharedOrderListController


-(void) setInstanceVariablesValues
{
    NSString* order = self.order;
    [super setInstanceVariablesValues];
    if ([order isEqualToString:@"SharedCahierOrder"]) {
        [self.requestModel addModels:order, nil];
        [self.requestModel.fields addObjectsFromArray:@[@[PROPERTY_IDENTIFIER,PROPERTY_ORDERNO,@"meetDate",@"meetName"]]];
        
        self.headers = @[PROPERTY_ORDERNO,@"meetDate",@"meetName"];
        self.headersXcoordinates = @[@(50), @(350), @(650)];
        self.valuesXcoordinates = @[@(10), @(310), @(590)];
        
        self.contentsFilter = ^void(int elementIndex, int innerCount, int outterCount, NSString* section, id cellElement, NSMutableArray* cellRepository){
            if (elementIndex != 0) {
                if (cellElement) {
                    [cellRepository addObject: cellElement];
                }
            }
        };
    }
    else if ([order isEqualToString:@"SharedOutOrder"]){
        [self.requestModel.fields addObjectsFromArray:@[PROPERTY_IDENTIFIER,PROPERTY_ORDERNO,@"employeeNO"]];
        [self.requestModel addModels:order, nil];
        self.headers = @[PROPERTY_ORDERNO,@"employeeNO"];
        self.headersXcoordinates = @[@(20), @(220)];
        self.valuesXcoordinates = @[@(20), @(270)];
    }
    else if ([order isEqualToString:@"SharedEventReportOrder"]){
        [self.requestModel.fields addObjectsFromArray:@[@[PROPERTY_IDENTIFIER,PROPERTY_ORDERNO,@"originEmployeeNO",@"proxyEmployeeNO"]]];
        [self.requestModel addModels:order, nil];
        self.headers = @[PROPERTY_ORDERNO,@"origin",@"proxy"];
        self.headersXcoordinates = @[@(20), @(220)];
        self.valuesXcoordinates = @[@(20), @(270)];
    }
}

@end
