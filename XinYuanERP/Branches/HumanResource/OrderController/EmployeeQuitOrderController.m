#import "EmployeeQuitOrderController.h"
#import "AppInterface.h"


#define NeedEmployeeFileds @[@"employeeNO", @"department", @"name", @"jobTitle", @"idCard", @"employDate"]

#define QuitOrderId_IN_QuitPassOrder @"employeeQuitOrderId"           // "employeeQuitOrderId" against to the server end



@implementation EmployeeQuitOrderController
{
    JsonDivView* applyDivView ;
    JsonDivView* passDivView ;
}


-(void)viewDidLoad
{
    [super viewDidLoad];
    
    JsonView* jsonView = self.jsonView;
    applyDivView = (JsonDivView*)[jsonView getView:@"NESTED_EmployeeQuitOrder"];
    passDivView = (JsonDivView*)[jsonView getView:@"NESTED_EmployeeQuitPassOrder"];
    
    
    // employeeNO. button
    JRTextField* employeeTextField = ((JRLabelCommaTextFieldView*)[jsonView getView: PROPERTY_EMPLOYEENO]).textField;
    JsonDivView* applyDivBodyView = (JsonDivView*)[applyDivView getView: @"NESTED_QUIT_BODY"];
    employeeTextField.textFieldDidClickAction = ^void(id jrTextField) {
        // popup a users table
        PickerModelTableView* pickView = [PickerModelTableView popupWithModel:MODEL_EMPLOYEE willDimissBlock:nil];
        
        pickView.titleHeaderViewDidSelectAction = ^void(JRTitleHeaderTableView* headerTableView, NSIndexPath* indexPath){
            [PickerModelTableView dismiss];
            
            FilterTableView* filterTableView = (FilterTableView*)headerTableView.tableView.tableView;
            NSIndexPath* realIndexPath = [filterTableView getRealIndexPathInFilterMode: indexPath];
            
            NSString* employeeNO = [filterTableView realContentForIndexPath: realIndexPath];
            NSDictionary* objects = @{PROPERTY_EMPLOYEENO: employeeNO};
            [VIEW.progress show];
            [AppServerRequester readModel: MODEL_EMPLOYEE department:DEPARTMENT_HUMANRESOURCE objects:objects completeHandler:^(ResponseJsonModel *data, NSError *error) {
                [VIEW.progress hide];
                
                NSArray* objects = data.results;
                NSDictionary* tempInfo = [[objects firstObject] firstObject];
                // Automatic fill the textfield .
                NSMutableDictionary* renderInfos = [DictionaryHelper subtract: tempInfo keys:NeedEmployeeFileds];
                if (renderInfos[@"employDate"]) {
                    NSString* covertStr = [DateHelper stringFromString: renderInfos[@"employDate"] fromPattern:DATE_TIME_PATTERN toPattern:DATE_PATTERN];
                    [renderInfos setObject: covertStr forKey:@"employDate"];
                }
                
                [JsonModelHelper clearModel: applyDivBodyView keys: NeedEmployeeFileds];
                [JsonModelHelper renderWithObjectsKeys: renderInfos jrTopView:applyDivBodyView];
            }];
            
        };
    };
    
    [self setApplyDivViewInteractionEnable: NO];
    [self setPassDivViewInteractionEnable: NO];
    
    
    JRButton* returnBTN = ((JRButton*)[self.jsonView getView: JSON_KEYS(json_NESTED_header, json_BTN_Return)]);
    returnBTN.didClikcButtonAction = nil;
}


#pragma mark - Override Super Class Methods


-(void)setControlMode:(JsonControllerMode)controlMode
{
    [super setControlMode:controlMode];
    
    
    if (controlMode == JsonControllerModeCreate) {
        // Quit Order Create Mode
        if (! self.valueObjects) {
            [self setApplyDivViewInteractionEnable: YES];
            [self setPassDivViewInteractionEnable: NO];
        }
        
        // Pass Order Create Mode
        if (self.valueObjects && [self.valueObjects[ORDER_EmployeeQuitPassOrder] count] == 0) {
            [self setApplyDivViewInteractionEnable: NO];
            [self setPassDivViewInteractionEnable: YES];
            [JsonControllerHelper setUserInterfaceEnable: passDivView keys:@[@"NESTED_PASS_FOOTER.createUser"] enable:YES];
        }
    } 

}

#pragma mark - Create

-(NSMutableDictionary*) assembleSendObjects: (NSString*)divViewKey
{
    NSMutableDictionary* objects = [super assembleSendObjects: divViewKey];
    
    // when create the EmployeeQuitPassOrder
    if ([divViewKey isEqualToString:@"NESTED_EmployeeQuitPassOrder"]) {
        // EmployeeQuitOrder's id
        id applyOrderId = self.valueObjects[ORDER_EmployeeQuitOrder][PROPERTY_IDENTIFIER];
        if (applyOrderId) {
            [objects setObject: applyOrderId forKey:QuitOrderId_IN_QuitPassOrder];
        }
        
        if (!objects[@"humanResouceDesc"]) {
            NSString* localizeValue = LOCALIZE_MESSAGE_FORMAT(MESSAGE_ValueCannotEmpty, APPLOCALIZE_KEYS(@"(EmployeeQuitOrder.humanResouceDesc)", @"description"));
            [ACTION alertMessage: localizeValue];
            return nil;
        }
    }
    
    return objects;
}


#pragma mark - Apply

-(void) assembleWillApplyObjects: (NSString*)applevel order:(NSString*)order valueObjects:(NSDictionary*)valueObjects divKey:(NSString*)divKey isNeedRequest:(BOOL*)isNeedRequest objects:(NSDictionary**)objects identities:(NSDictionary**)identities
{
    if ([order isEqualToString: ORDER_EmployeeQuitOrder]) {
        NSDictionary* employeeQuitValuesObjects = valueObjects[ORDER_EmployeeQuitOrder];
        [super assembleWillApplyObjects:applevel order:order valueObjects:employeeQuitValuesObjects divKey:divKey isNeedRequest:isNeedRequest objects:objects identities:identities];
        
    } else if ([order isEqualToString: ORDER_EmployeeQuitPassOrder]) {
        NSDictionary* employeeQuitPassValuesObjects = valueObjects[ORDER_EmployeeQuitPassOrder];
        
        [super assembleWillApplyObjects:applevel order:order valueObjects:employeeQuitPassValuesObjects divKey:divKey isNeedRequest:isNeedRequest objects:objects identities:identities];
        
        NSString* localizeValue = nil;
        if ([applevel isEqualToString:levelApp1]) {
            if (!(*objects)[@"warehouseDesc"]) {
                localizeValue = LOCALIZE_MESSAGE_FORMAT(MESSAGE_ValueCannotEmpty, APPLOCALIZE_KEYS(@"(EmployeeQuitOrder.warehouseDesc)", @"description"));
            }
        } else if ([applevel isEqualToString:levelApp2]) {
            if (!(*objects)[@"financeDesc"]) {
                localizeValue = LOCALIZE_MESSAGE_FORMAT(MESSAGE_ValueCannotEmpty, APPLOCALIZE_KEYS(@"(EmployeeQuitOrder.financeDesc", @"description"));
            }
        } else if ([applevel isEqualToString:levelApp3]) {
            if (!(*objects)[@"securityDesc"]) {
                localizeValue = LOCALIZE_MESSAGE_FORMAT(MESSAGE_ValueCannotEmpty, APPLOCALIZE_KEYS(@"(EmployeeQuitOrder.securityDesc)", @"description"));
            }
        }
        if (localizeValue) {
            [ACTION alertMessage: localizeValue];
            *isNeedRequest = NO;
        }
        *identities = [RequestModelHelper getModelIdentities: employeeQuitPassValuesObjects[PROPERTY_IDENTIFIER]];
    }
}


-(NSString *)getFowardUserForFinalApplyOrder:(NSString *)orderType valueObjects:(NSDictionary *)valueObjects appTo:(NSString *)appTo
{
    if ([orderType isEqualToString:ORDER_EmployeeQuitOrder]) {
        return valueObjects[ORDER_EmployeeQuitOrder][appTo];
    } else if ([orderType isEqualToString: ORDER_EmployeeQuitPassOrder]) {
        return valueObjects[ORDER_EmployeeQuitPassOrder][appTo];
    }
    return nil;
}


#pragma mark - Read

// Read
-(RequestJsonModel*) assembleReadRequest:(NSDictionary*)objects
{
    // request model
    RequestJsonModel* requestModel = [RequestJsonModel getJsonModel];
    requestModel.path = PATH_LOGIC_READ(self.department);
    [requestModel addModelsFromArray: @[ORDER_EmployeeQuitOrder, ORDER_EmployeeQuitPassOrder]];
    
    [requestModel addObjects: objects, @{QuitOrderId_IN_QuitPassOrder: self.identification}, nil];
    
    return requestModel;
}

-(NSMutableDictionary*) assembleReadResponse: (ResponseJsonModel*)response
{
    // get the result from the request
    NSDictionary* employeeQuitObjects = [[response.results safeObjectAtIndex:0]  firstObject];
    NSDictionary* employeeQuitPassObjects = [[response.results safeObjectAtIndex:1]  firstObject];
    
    employeeQuitObjects = employeeQuitObjects ? employeeQuitObjects : @{};
    employeeQuitPassObjects = employeeQuitPassObjects ? employeeQuitPassObjects : @{};
    
    NSMutableDictionary* objects = [DictionaryHelper deepCopy:@{ORDER_EmployeeQuitOrder:employeeQuitObjects, ORDER_EmployeeQuitPassOrder:employeeQuitPassObjects}];
    
    self.valueObjects = [DictionaryHelper deepCopy: objects];
    
    return objects;
}

-(void) enableViewsWithReceiveObjects: (NSMutableDictionary*)objects
{
    NSDictionary* employeeQuitObjects = objects[ORDER_EmployeeQuitOrder];
    NSDictionary* employeeQuitPassObjects = objects[ORDER_EmployeeQuitPassOrder];
    
    // to do ..... , the returned button
    
    // check if is returned, then enable and disable the Submit Buttons
    [JsonControllerHelper enableSubmitButtonsForApplyMode: self withObjects:employeeQuitObjects order:ORDER_EmployeeQuitOrder];
    [JsonControllerHelper enableSubmitButtonsForApplyMode: self withObjects:employeeQuitPassObjects order:ORDER_EmployeeQuitPassOrder];
    
    BOOL isQuitAllApproved = [JsonControllerHelper isAllApplied: ORDER_EmployeeQuitOrder valueObjects:employeeQuitObjects];
    BOOL isQuitPassAllApproved = [JsonControllerHelper isAllApplied: ORDER_EmployeeQuitPassOrder valueObjects:employeeQuitPassObjects];
    
    if (! isQuitAllApproved) {
        [self setApplyDivViewInteractionEnable: YES];
        [self setPassDivViewInteractionEnable: NO];
    } else if (isQuitAllApproved && employeeQuitPassObjects.count == 0) {
        self.controlMode = JsonControllerModeCreate;
    } else if (! isQuitPassAllApproved && employeeQuitPassObjects.count != 0) {
        [self setApplyDivViewInteractionEnable: NO];
        [self setPassDivViewInteractionEnable: YES];
    }
    
    // exception and delete button
    [JsonControllerHelper enableExceptionButtonAfterFinalApprovas:self objects:objects];
    [JsonControllerHelper enableDeleteButtonByCheckPermission: self ];
}

-(void) setApplyDivViewInteractionEnable: (BOOL)enable
{
//    applyDivView.userInteractionEnabled = enable;
    NSArray* keys = @[@"NESTED_QUIT_BODY.NESTED_QUIT_1", @"NESTED_QUIT_BODY.NESTED_QUIT_2", @"NESTED_QUIT_BODY.NESTED_QUIT_3", @"NESTED_QUIT_BODY.quitReason", @"NESTED_QUIT_BODY.signature"];
    [JsonControllerHelper setUserInterfaceEnable: applyDivView keys:keys enable:enable];
}


-(void) setPassDivViewInteractionEnable: (BOOL)enable
{
    passDivView.userInteractionEnabled = enable;
}


-(void) translateReceiveObjects: (NSMutableDictionary*)objects
{
    NSMutableDictionary* employeeQuitObjects = objects[ORDER_EmployeeQuitOrder];
    NSMutableDictionary* employeeQuitPassObjects = objects[ORDER_EmployeeQuitPassOrder];
    
    [super translateReceiveObjects: employeeQuitObjects];
    [super translateReceiveObjects: employeeQuitPassObjects];
}

-(void) renderWithReceiveObjects: (NSMutableDictionary*)objects
{
    NSDictionary* employeeQuitObjects = objects[ORDER_EmployeeQuitOrder];
    NSDictionary* employeeQuitPassObjects = objects[ORDER_EmployeeQuitPassOrder];
    [applyDivView setModel: employeeQuitObjects];
    [passDivView setModel: employeeQuitPassObjects];
}



@end
