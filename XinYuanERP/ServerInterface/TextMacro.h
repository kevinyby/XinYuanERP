
#ifndef XinYuanERP_TextMacro_h
#define XinYuanERP_TextMacro_h

#pragma mark - Util


#define COMMA @","



#define EMPTY_STRING    @""
#define NIL_STRING      @"(null)"
#define NULL_STRING     @"<null>"


#define CATEGORIES                      @"CATEGORIES"
#define PERMISSIONS                     @"PERMISSIONS"

#define USER_IDENTIFIER                 @"USER_IDENTIFIER"
#define ALL_USERS_PERMISSIONS           @"ALL_USERS_PERMISSIONS"




#pragma mark - Additional Wheels

#define WHEEL_TRACE_STATUS_FILE @"KEYS.Trace.Files"




#pragma mark - DEPARTMENT AND CATEGORY

#define CATEGORIE_VIP               @"VIP"
#define CATEGORIE_USER              @"User"
#define CATEGORIE_CARDS             @"Cards"
#define CATEGORIE_APPROVAL          @"Approval"
#define CATEGORIE_STATISTICS        @"Statistics"
#define CATEGORIE_SHAREDORDER       @"SharedOrder"
#define CATEGORIE_SETTING           @"Setting"

#define SUPERBRANCH                 @"Super"
#define DEPARTMENT_VEHICLE          @"Vehicle"
#define DEPARTMENT_SECURITY         @"Security"

#define DEPARTMENT_WAREHOUSE        @"Warehouse"
#define DEPARTMENT_QUALITYCONTROL   @"QualityControl"

#define DEPARTMENT_FINANCE          @"Finance"
#define DEPARTMENT_PURCHASE         @"Purchase"
#define DEPARTMENT_HUMANRESOURCE    @"HumanResource"
#define DEPARTMENT_BUSINESS         @"Business"




#pragma mark - MODEL AND ORDER

#define MODEL_USER                  @"User"
#define MODEL_CLIENT                @"Client"
#define MODEL_EMPLOYEE              @"Employee"
#define MODEL_VENDOR                @"Vendor"
#define MODEL_APPSETTINGS           @"APPSettings"

#define MODEL_FinanceAccount        @"FinanceAccount"
#define MODEL_WHInventory           @"WHInventory"

// HumanResource
#define ORDER_EmployeeCHOrder       @"EmployeeCHOrder"
#define ORDER_EmployeeQuitOrder     @"EmployeeQuitOrder"
#define ORDER_EmployeeQuitPassOrder @"EmployeeQuitPassOrder"


// Business
#define ORDER_BSConsultOrder        @"BSConsultOrder"


// Finance
#define ORDER_FinancePaymentOrder   @"FinancePaymentOrder"
#define BILL_FinancePaymentBill     @"FinancePaymentBill"

#define ORDER_FinanceSalary         @"FinanceSalary"
#define ORDER_FinanceSalaryCHOrder  @"FinanceSalaryCHOrder"

//Vehicle
#define ORDER_VEHICLEINFO           @"VehicleInfoOrder"









#pragma mark - ALL_USERS_PERMISSIONS

#define PERMISSION_READ                 @"read"
#define PERMISSION_CREATE               @"create"
#define PERMISSION_MODIFY               @"modify"
#define PERMISSION_DELETE               @"delete"
#define PERMISSION_APPLY                @"apply"



#pragma mark - ORDER PROPERTIES

#define PROPERTY_IDENTIFIER        @"id"
#define PROPERTY_ORDERNO           @"orderNO"
#define PROPERTY_CLIENTNO          @"clientNO"
#define PROPERTY_EMPLOYEENO        @"employeeNO"
#define PROPERTY_CREATEDATE        @"createDate"
#define PROPERTY_CREATEUSER        @"createUser"
#define PROPERTY_EXPIREDDATE       @"expiredDate"
#define PROPERTY_EXCEPTION         @"exception"
#define PROPERTY_RETURNED          @"returned"

#define PROPERTY_EMPLOYEE_NAME     @"name"
#define PROPERTY_EMPLOYEE_JOBTITLE @"jobTitle"
#define PROPERTY_EMPLOYEE_DEPARTMENT @"department"

#define PROPERTY_FORWARDUSER        @"forwardUser"
#define PROPERTY_MODIFIEDUSER       @"modifiedUser"

#define BILL_CREATEUSER         @"billCreateUser"




/*
 仓库
 */
#define ORDER_WHLendOutOrder      @"WHLendOutOrder"
#define BILL_WHLendOutBill        @"WHLendOutBill"
#define ORDER_WHScrapOrder        @"WHScrapOrder"
#define ORDER_WHPurchaseOrder     @"WHPurchaseOrder"
#define ORDER_WHInventoryCHOrder  @"WHInventoryCHOrder"
#define ORDER_WHPickingOrder      @"WHPickingOrder"
/*
 质检
 */



#pragma mark -
#define KEY_ASTERISK @"*"
#define KEY_COMMA    @","
#define KEY_PERIOD   @"."
#define KEY_HYPHEN   @"-"
#define KEY_SLASH    @"/"


#pragma mark -
#pragma mark - 用户的权限
#define USER_AUTHORITY_ADMIN   @"*"
#define USER_AUTHORITY_READ    @"read"
#define USER_AUTHORITY_CREATE  @"create"
#define USER_AUTHORITY_MODIFY  @"modify"
#define USER_AUTHORITY_DELETE  @"delete"
#define USER_AUTHORITY_APPLY   @"apply"

#define leveApp         @"app"
#define levelApp1       @"app1"
#define levelApp2       @"app2"
#define levelApp3       @"app3"
#define levelApp4       @"app4"











#pragma mark - APPSettings Table Field

// Administrator

//1
#define APPSettings_TYPE_ADMIN_ORDERSAPPROVALS      @"ADMIN_ORDERS_APPROVALS"
#define APPSettings_APPROVALS_USERS                 @"USERS"
#define APPSettings_APPROVALS_PRAMAS                @"PRAMAS"
#define APPSettings_APPROVALS_PRAMAS_LEVEL          @"LEVEL"

//2
#define APPSettings_TYPE_ADMIN_ORDERSEXPIRATIONS    @"ADMIN_ORDERS_EXPIRATIONS"



// User
#define APPSettings_TYPE_USER_JOBLEVELS             @"USER_JOBLEVELS"
#define APPSettings_TYPE_USER_JOBPOSITIONS          @"USER_JOBPOSITIONS"

#define APPSettings_WHAREHOUSE_PRODUCT_CATEGORY     @"PRODUCT_CATEGORY"
#define APPSettings_PURCHASE_VENDOR_CATEGORY        @"VENDOR_CATEGORY"

#endif


