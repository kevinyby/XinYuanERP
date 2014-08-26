#import "VehicleListController.h"
#import "AppInterface.h"

@implementation VehicleListController

-(void) setInstanceVariablesValues
{
    NSString* order = self.order;
    [super setInstanceVariablesValues];
    if ([order isEqualToString: ORDER_VEHICLEINFO]){
        [self.requestModel addModels: order, nil];//which table you want to search
        [self.requestModel.fields //which fileds you want to pick, note the double nested array here
            addObjectsFromArray:@[@[PROPERTY_IDENTIFIER, PROPERTY_ORDERNO,@"vehicleNo"]]];
        
        self.headers = @[@"单号",@"车牌号"];
        self.headersXcoordinates = @[@(50),@(300)];
        self.valuesXcoordinates = @[@(40),@(300)];
        
        
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
