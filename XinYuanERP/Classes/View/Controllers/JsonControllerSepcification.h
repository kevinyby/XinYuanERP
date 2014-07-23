//
//  JsonControllerSepcification.h


typedef enum {
    JsonControllerModeNull = -1,
    JsonControllerModeCreate = 0,
    JsonControllerModeRead,
    JsonControllerModeApply,
    JsonControllerModeModify
} JsonControllerMode;

typedef enum {
    JsonControllerSubmitButtonTypeSaveOrUpdate = 0 ,
    JsonControllerSubmitButtonTypeApprove = 1
} JsonControllerSubmitButtonType;


// ---------------------- JsonController Begin---------------------------------------------

#define json_SHARE_FILE         @"Share"
#define json_FILE_CONTROLLER_SUFIX  @"_Controller"


/*
 * Occupied Key Words
 */

#define JSON_KEYS(k1,k2) [NSString stringWithFormat:@"%@.%@",k1, k2]

// NESTED_header
#define json_NESTED_header      @"NESTED_header"
#define json_BTN_Return         @"BTN_Return"
#define json_BTN_Back           @"BTN_Back"
#define json_BTN_Delete         @"BTN_Delete"
#define json_BTN_Exception      @"exception"


// NESTED_footer
#define json_NESTED_footer      @"NESTED_footer"
#define json_app1               @"app1"
#define json_app2               @"app2"
#define json_app3               @"app3"
#define json_app4               @"app4"
#define json_createUser         @"createUser"


// Pages
#define json_BTN_NextPage       @"BTN_NextPage"
#define json_BTN_PriorPage      @"BTN_PriorPage"


// Title
#define json_OrderTitle         @"ORDER_TITLE"


// Tabs
#define json_NESTED_TABS        @"NESTED_TABS"
#define json_NESTED_SCROLL      @"NESTED_SCROLL"




// In ****_Controller.json

/*
 * IMAGES Config
 */
#define kController_IMAGES                  @"IMAGES"

// Read - Get Images
#define kController_IMAGES_LOAD             @"IMAGES_LOAD"

// Create - Image Data & Name ----------------
// Name
#define kController_IMAGES_NAMES            @"IMAGES_NAMES"
#define kController_IMGNAME_PRE             @"PRE"
#define kController_IMGNAME_SUF             @"SUF"
#define kController_IMGNAME_MAIN            @"MAINNAME"
// Data
#define kController_IMAGES_DATAS                @"IMAGES_DATAS"
#define kController_IMAGE_FIX_ORIENTATION       @"FIX_Orientation"
#define kController_JPG_CompressionQuality      @"JPG_CompressionQuality"
#define kController_IMAGE_DATA_IS_PNG           @"IS_SAVE_AS_PNG_DATA"
// Create: Image Data & Name ----------------

// Picker
#define kController_IMAGE_PICKER            @"IMAGE_PICKER"

// Preview
#define kController_IMAGES_PREVIEWS         @"IMAGES_PREVIEWS"
#define kController_IMAGES_PREVIEWS_X       @"X"
#define kController_IMAGES_PREVIEWS_IPhoneRation       @"IPhone_Ratio"






/*
 * Server Config
 */
#define kController_SERVER                          @"SERVER"

#define kController_SUBMIT_BUTTONGROUP              @"SUBMIT_BUTTONS"
#define kController_SUBMIT_BUTTONS_TYPE             @"BUTTON_TYPE"
#define kController_SUBMIT_BUTTONS_SENDVIEW         @"MODEL_SENDVIEW"
#define kController_SUBMIT_BUTTONS_SENDORDER        @"MODEL_SENDORDER"
#define kController_SUBMIT_BUTTONS_APPTO            @"MODEL_APPTO"
#define kController_SUBMIT_BUTTONS_APPFROM          @"MODEL_APPFROM"

#define kController_SUBMIT_CREATE_FAILED_RESET      @"CREATE_FAILED_RESET"  // when create failed , such a duplicated key

// Create/Modify - Validate Data
#define json_CHECK_NOTEMPTY                         @"CHECK_NOTEMPTY"

#define json_CHECK_FORMAT                           @"CHECK_FORMAT"
#define json_CHECK_FORMAT_DIGIT                     @"digit"








/*
 * Client Config
 */
#define kController_CLIENT                  @"CLIENT"

// --- Auto Fill
#define kController_CREATE_AUTOFILL         @"CREATE_AUTOFILL"
#define kController_CREATE_AUTOFILL_NOWUSER @"NOW_USER"
#define kController_CREATE_AUTOFILL_NOWDATE @"NOW_DATE"

// --- Control Mode
#define kController_CONTROL_MODE            @"CONTROL_MODE"

#define json_DEFAULT_MODE                   @"DEFAULT_MODE"
#define json_READ_MODE                      @"READ_MODE"
#define json_APPLY_MODE                     @"APPLY_MODE"
#define json_CREAT_MODE                     @"CREAT_MODE"
#define json_MODIFY_MODE                    @"MODIFY_MODE"

#define json_ENABLE                         @"ENABLE"
#define json_UNENABLE                       @"UNENABLE"

// subclass
#define json_MODE_SUB   @"_SUB"
// --- Control Mode

// Date
#define kController_DATEPICKERS            @"COMS_DATE_PICKERS"
#define kController_DATEPATTERNS           @"COMS_DATE_PATTERNS"

// Signature
#define kController_SIGNATURESBUTTONS      @"COMS_SIGNATURE_BUTTONS"


// Toggle Buttons
#define kController_TOGGLES_BUTTONS         @"TOGGLES_BUTTONS"
#define kTOGGLEButton                       @"button"
#define kTOGGLEValue                        @"default_value"

// QRCode Buttons
#define kController_QRCODES_BUTTONS         @"QRCODES_BUTTONS"
#define QRButton                            @"button"
#define QRImage                             @"image"
#define QRContentKeys                       @"contentKeys"
#define QRTipsKeys                          @"tipsKeys"
#define QRImageWidth                        @"width"



// Pop Values To Select
#define kController_ValuesPicker    @"VALUES_PICKER"
#define VALUES_PICKER_gender        @"gender"
#define VALUES_PICKER_department    @"department"
#define VALUES_PICKER_jobLevel      @"jobLevel"
#define VALUES_PICKER_eduDegree     @"eduDegree"
#define VALUES_PICKER_eduRecord     @"eduRecord"

// ---------------------- JsonController End---------------------------------------------


