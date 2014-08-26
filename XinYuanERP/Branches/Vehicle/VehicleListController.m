#import "VehicleListController.h"
#import "AppInterface.h"

@implementation VehicleListController

-(void) setInstanceVariablesValues: (BaseOrderListController*)orderlist order:(NSString*)order {
    [super setInstanceVariablesValues: orderlist order:order];
    if ([order isEqualToString: ORDER_VEHICLEINFO]){
        [orderlist.requestModel addModels: order, nil];//which table you want to search
        [orderlist.requestModel.fields //which fileds you want to pick, note the double nested array here
            addObjectsFromArray:@[@[PROPERTY_IDENTIFIER, PROPERTY_ORDERNO,@"vehicleNo"]]];
        
        orderlist.headers = @[@"单号",@"车牌号"];
        orderlist.headersXcoordinates = @[@(50),@(300)];
        orderlist.valuesXcoordinates = @[@(40),@(300)];
        
        
        //there is nothing to filter about at present
        /*self.contentFilterBlock = ^id(int elementIndex, int innerCount, int outterCount, NSString* section, id cellElement, NSMutableArray* cellRepository){
            return nil;
        };*/
        
//        self.didSelectRowBlock = ^void(AppSearchTableViewController* controller, NSIndexPath* indexPath){
//            
//        };
        
    }
}

@end
