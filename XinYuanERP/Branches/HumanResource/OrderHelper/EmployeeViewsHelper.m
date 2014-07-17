#import "EmployeeViewsHelper.h"
#import "AppInterface.h"

@implementation EmployeeViewsHelper


+(void) setNameByEmployeeNumber: (NSMutableDictionary*)dictioanry
{
    NSString* employeeNO = [dictioanry objectForKey: PROPERTY_EMPLOYEENO];
    NSString* name = [DATA.usersNONames objectForKey: employeeNO];
    [dictioanry setObject: name forKey:PROPERTY_EMPLOYEE_NAME];
}




#pragma mark -

+(JsonView*) popupJsonView:(NSString*)file key:(NSString*)key dissmiss:(void(^)(UIView* view))block
{
    JsonView* jsonView =  (JsonView*)[JsonViewRenderHelper renderFile:file specificationsKey:key];
    
    NSString* controllerFile = [file stringByAppendingString: json_FILE_CONTROLLER_SUFIX];
    NSString* controllerKey = [key stringByAppendingString: json_FILE_CONTROLLER_SUFIX];
    
    NSDictionary* controllerSpecification = [JsonFileManager getJsonFromFile: controllerFile];
    NSDictionary* config = controllerSpecification[controllerKey];
    [JRComponentHelper setupDatePickerComponents: jsonView pickers:config[kController_DATEPICKERS] patterns:config[kController_DATEPATTERNS]];
    
    [PopupViewHelper popView: jsonView willDissmiss:block];
    return jsonView;
}

@end
