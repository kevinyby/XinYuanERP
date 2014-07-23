
//#define kURL @"http://192.168.0.203"        // Isaacs
//#define kURL @"http://61.143.227.60"

#ifdef DEBUG

//#define kURL @"http://61.143.227.60"        // WAN Server

//#define kURL @"http://192.168.0.161"        // LAN Server

//#define kURL @"http://127.0.0.1"            // Simualtor

//#define kURL @"http://192.168.0.202"        // Dan

//#define kURL @"http://192.168.0.204"        // Bo

#define kURL @"http://192.168.0.203"        // Isaacs

#endif

#ifdef RELEASE

#define kURL @"http://61.143.227.60"

#endif


#define kAPP_PORT    7072
#define kRES_PORT    8051


#define URLWITHPORT(_port) [kURL stringByAppendingFormat:@":%d", _port]


#define kURL_BASE_APP URLWITHPORT(kAPP_PORT)
#define kURL_BASE_RES URLWITHPORT(kRES_PORT)


#define kSERVER_NAME @"ERPWebServer"
#define kResource_PATH @"service"
 

#define kAPP_URL [kURL_BASE_APP stringByAppendingPathComponent: kSERVER_NAME]
#define kRES_URL [kURL_BASE_RES stringByAppendingPathComponent: kResource_PATH]


#define MODEL_URL(_subPath) [kAPP_URL stringByAppendingPathComponent: _subPath];
#define IMAGE_URL(_subPath) [kRES_URL stringByAppendingPathComponent: _subPath]

#define DOWNLOAD @"download"
#define UPLOAD @"upload"


#define IMAGE_THUMBNAILS_PATH @"thumbnails"


#pragma mark - URL AND PATH


#pragma mark - 

#define LOGIC_PATH          @"/logic/"

#define PATH_LOGIC_CONNECTOR @"__"

#define PATH_LOGIC(_department, _method) [LOGIC_PATH stringByAppendingFormat: @"%@%@%@", _department, PATH_LOGIC_CONNECTOR, _method]

#define PATH_LOGIC_READ(_department)    PATH_LOGIC(_department, PERMISSION_READ)

#define PATH_LOGIC_CREATE(_department)  PATH_LOGIC(_department, PERMISSION_CREATE)

#define PATH_LOGIC_MODIFY(_department)  PATH_LOGIC(_department, PERMISSION_MODIFY)

#define PATH_LOGIC_DELETE(_department)  PATH_LOGIC(_department, PERMISSION_DELETE)

#define PATH_LOGIC_APPLY(_department)  PATH_LOGIC(_department, PERMISSION_APPLY)


#pragma mark - 

#define ADMIN_PATH      @"/admin/"

#define PATH_ADMIN(_subPath) [ADMIN_PATH stringByAppendingPathComponent: _subPath]


#pragma mark -

#define USER_APTH       @"/user/"

#define PATH_USER(_subPath) [USER_APTH stringByAppendingPathComponent: _subPath]


#pragma mark -

#define SETTING_PATH    @"/setting/"

#define PATH_SETTING(_subPath) [SETTING_PATH stringByAppendingPathComponent: _subPath]

#define PATH_SETTING_INFORM PATH_SETTING(@"inform")




#pragma mark - Local Resource Path

#define ModelsStructurePath @"App/ModelsStructure.txt"

#define SignedInBasicDataPath @"App/SignedInBasicData.txt"

