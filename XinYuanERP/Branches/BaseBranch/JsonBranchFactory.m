#import "JsonBranchFactory.h"
#import "AppInterface.h"

#define FactoryClassName(_DEPARTMENT) [NSString stringWithFormat:@"%@%@",_DEPARTMENT,@"Factory"]

@implementation JsonBranchFactory


#pragma mark - Public Methods

- (void)handleOrderListController: (OrderSearchListViewController*)listController order:(NSString*)order
{
    
    // then , assign the attributes
    __weak JsonBranchFactory* weakInstance = self;
    
    // set common
    
    listController.requestModel = [RequestJsonModel getJsonModel];
    listController.requestModel.path = PATH_LOGIC_READ(self.department);
    
    listController.didTapAddNewOrderBlock = ^void(OrderSearchListViewController* controller, id sender)
    {
        JsonController* jsonController = [JsonBranchFactory getNewJsonControllerInstance: weakInstance.department order:order];
        jsonController.controlMode = JsonControllerModeCreate;
        [VIEW.navigator pushViewController: jsonController animated:YES];
        
    };
    
    listController.appTableDidSelectRowBlock = ^void(AppSearchTableViewController* controller ,NSIndexPath* realIndexPath)
    {
        // set identification
        id identification = [controller getIdentification: realIndexPath];
        JsonController* jsonController = [weakInstance getJsonController: order identification:identification ];
        [VIEW.navigator pushViewController: jsonController animated:YES];
    };
    
    // set from specification
    NSDictionary* config = [JsonBranchFactory getModelsListSpecification: self.department order:order];
    if (config) {
        
        // request
        if (config[list_REQUEST_PATH]) {
            listController.requestModel.path = PATH_LOGIC_READ(config[list_REQUEST_PATH]);
        } else {
            listController.requestModel.path = PATH_LOGIC_READ(self.department);
        }
        if (config[req_MODELS]) {
            [listController.requestModel.models addObjectsFromArray: config[req_MODELS]];
        } else {
            [listController.requestModel addModels: order, nil];
        }
        if (config[req_FIELDS]) [listController.requestModel.fields addObjectsFromArray:config[req_FIELDS]];
        if (config[req_JOINS]) [listController.requestModel.joins addObject: config[req_JOINS]];
        if (config[req_SORTS]) [listController.requestModel.sorts addObjectsFromArray: [ArrayHelper deepCopy: config[req_SORTS]]];
        
        // view
        if (config[list_VIEW_HEADERS]) listController.headers = config[list_VIEW_HEADERS];
        if (config[list_VIEW_HEADERSX]) listController.headersXcoordinates = config[list_VIEW_HEADERSX];
        if (config[list_VIEW_VALUESX]) listController.valuesXcoordinates = config[list_VIEW_VALUESX];
        
        // pre define filter
        if (config[list_VIEW_FILTER]) {
            NSDictionary* filters = config[list_VIEW_FILTER];
            listController.contentsFilter = ^void(int elementIndex , int innerCount, int outterCount, NSString* section, id cellElement, NSMutableArray* cellRepository) {
                NSString* filterName = [filters objectForKey: [[NSNumber numberWithInt: elementIndex] stringValue]];
                
                if (filterName) {
                    ContentFilterElementBlock block = [ContentFilterHelper.contentFiltersMap objectForKey: filterName];
                    if (block) {
                        cellElement = block(cellElement, cellRepository);
                    }
                }
                
                if (cellElement) {
                    [cellRepository addObject: cellElement];
                }
            };
        }
        
    }
    
    
    
    // for suclass
    [self setInstanceVariablesValues: listController order:order];
    
    [self setExceptionAttributes: listController order:order];
    
    [JsonBranchFactory iterateHeaderJRLabel:listController handler:^BOOL(JRLocalizeLabel *label, int index, NSString *attribute) { label.attribute = attribute; return NO; }];
    [self setHeadersSortAction: listController order:order];
}


#pragma mark - SubClass Override Methods

-(void) setInstanceVariablesValues: (OrderSearchListViewController*)listController order:(NSString*)order
{
}

-(void) setExceptionAttributes: (OrderSearchListViewController*)listController order:(NSString*)order
{
    [ListViewControllerHelper setupExceptionAttributes: listController order:order];
}

-(void) setHeadersSortAction: (OrderSearchListViewController*)listController order:(NSString*)order
{
    [JsonBranchFactory iterateHeaderJRLabel:listController handler:^BOOL(JRLocalizeLabel *label, int index, NSString *attribute) {
        label.jrLocalizeLabelDidClickAction = ^void(JRLocalizeLabel* label) {
            [JsonBranchHelper clickHeaderLabelSortRequestAction: label listController:listController];
        };
        return NO;
    }];
}

     
     
     
-(JsonController*) getJsonController: (NSString*)order identification:(id)identification
{
    JsonController* jsonController = [JsonBranchFactory getNewJsonControllerInstance: self.department order:order];
    jsonController.controlMode = JsonControllerModeRead;
    jsonController.identification = identification;
    return jsonController;
}














#pragma mark - Class Methods
+(void) iterateHeaderJRLabel: (OrderSearchListViewController*)listController handler:(BOOL(^)(JRLocalizeLabel* label, int index, NSString* attribute))handler
{
    NSArray* headers = listController.headers;
    UIView* headerView = listController.headerTableView.headerView;
    for (int i = 0; i < headers.count; i++) {
        NSString* attribute = headers[i];
        JRLocalizeLabel* jrLabel = (JRLocalizeLabel*)[headerView viewWithTag:ALIGNTABLE_HEADER_LABEL_TAG(i)];
        if (handler) {
            if (handler(jrLabel, i, attribute)) {
                return;
            }
        }
    }
}

+(JRLocalizeLabel*) getHeaderJRLabelByAttribute: (OrderSearchListViewController*)listController attribute:(NSString*)attribute
{
    NSArray* headers = listController.headers;
    UIView* headerView = listController.headerTableView.headerView;
    for (int i = 0; i < headers.count; i++) {
        JRLocalizeLabel* jrLabel = (JRLocalizeLabel*)[headerView viewWithTag:ALIGNTABLE_HEADER_LABEL_TAG(i)];
        if ([jrLabel.attribute isEqualToString: attribute]) {
            return jrLabel;
        }
    }
    return nil;
}

+ (id)factoryCreateBranch:(NSString*)department
{
    JsonBranchFactory* branchFactory = [[NSClassFromString(FactoryClassName(department)) alloc] init];
    branchFactory.department = department;
    
    if (! branchFactory) {
        branchFactory = [[JsonBranchFactory alloc] init];
    }
    
    return branchFactory;
}


+(void) navigateToOrderController: (NSString*)department order:(NSString*)order identifier:(id)identifier
{
    UIViewController* controller = [self getOrderController: department order:order identifier:identifier];
    [VIEW.navigator pushViewController: controller animated:YES];
}


+(UIViewController*) getOrderController: (NSString*)department order:(NSString*)order identifier:(id)identifier
{
    UIViewController* controller = nil;
    JsonBranchFactory* jsonBranch = [JsonBranchFactory factoryCreateBranch: department];
    JsonController* jsonController = [jsonBranch getJsonController: order identification: identifier];
    controller = jsonController;
    
    return controller;
}



+(JsonController*) getNewJsonControllerInstance:(NSString*)department order:(NSString*)order
{
    // controller
    NSString* controllerCalzzstring = [NSString stringWithFormat: @"%@%@", order, @"Controller"];
    Class controllerCalzz = NSClassFromString(controllerCalzzstring);
    if (controllerCalzz == Nil) controllerCalzz = [JsonController class];
    JsonController* jsonController = [[controllerCalzz alloc] init];
    jsonController.order = order;
    jsonController.department = department;
    jsonController.controlMode = JsonControllerModeNull;
    return jsonController;
}


+(NSDictionary*) getModelsListSpecification: (NSString*)department
{
    NSString* departmentListFileName = [department stringByAppendingString: @"List.json"];
    NSDictionary* result = [JsonFileManager getJsonFromFile: departmentListFileName];
    return result;
}

+(NSDictionary*) getModelsListSpecification: (NSString*)department order:(NSString*)order
{
    NSDictionary* result = [self getModelsListSpecification: department];
    if (order) {
        result = result[order];
    }
    return result;
}


@end
