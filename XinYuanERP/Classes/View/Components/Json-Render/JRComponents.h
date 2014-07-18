
#import "JsonView.h"

#import "JsonViewHelper.h"
#import "JsonModelHelper.h"
#import "JRTextFieldHelper.h"
#import "JsonViewRenderHelper.h"
#import "JsonViewIterateHelper.h"



// view have attribute

// subclass of JRBaseView : JsonDivView <JRComponentProtocal>
#import "JsonDivView.h"
#import "JRBaseView.h"
#import "JRComplexView.h"
// subclass of JRButtonBaseView
#import "JRButtonBaseView.h"
#import "JRButtonTextFieldView.h"
// subclass of JRLabelBaseView
#import "JRLabelBaseView.h"
#import "JRLabelButtonView.h"
#import "JRLabelCheckBoxView.h"
#import "JRLabelTextView.h"
#import "JRLabelTextFieldView.h"
#import "JRLabelCommaTextView.h"

#import "JRLabelCommaView.h"
#import "JRLabelCommaTextFieldView.h"
#import "JRLabelCommaTextFieldButtonView.h"

#import "JRImageLabelCommaTextView.h"


// element only conform <JRComponentProtocal>
#import "JRLabel.h"
#import "JRLocalizeLabel.h"
#import "JRGradientLabel.h"

#import "JRButton.h"
#import "JRCheckBox.h"
#import "JRTextField.h"
#import "JRTextView.h"
#import "JRImageView.h"


#import "JRTableView.h"
#import "JRHeaderTableView.h"
#import "JRRefreshTableView.h"
#import "JRLazyLoadingTable.h"
#import "JRTitleHeaderTableView.h"
#import "JRButtonsHeaderTableView.h"

#import "JRTextScrollView.h"



// default component
#define JSON_DIVVIEW @"JsonDivView"



// JsonViewRenderHelper

#define JSON_TAG                    @"TAG"
#define JSON_FRAME                  @"JFrame"
#define JSON_BORDER                 @"BORDER"
#define JSON_BORDERWIDTH            @"BORDERWIDTH"
#define JSON_BGCOLOR                @"BGCOLOR"
#define JSON_RADIUS                 @"RADIUS"

#define JSON_SORTEDKEYS             @"SORTEDKEYS"
#define JSON_COMPONENTS             @"COMPONENTS"

#define JSON_LETTER_HORVIEWS        @"LETTER_HOR_VIEWS"         // For the JsonDivView text become longer IN English/Viet_Nam
#define JSON_LETTER_VERTEXTFIELDS   @"LETTER_VER_TEXTFIEDS"


#define JSON_JCOM                   @"JCom"
#define JSON_SubRender              @"JSubRender"


#define JSON_HIDDEN                 @"HIDDEN"


// JRLabel

#define JSON_RESERVECENTER          @"RESERVE_CENTER"


// JRLocalizeLabel

#define JSON_DESCRIPTION_KEY        @"DESCRIPTION_KEY"


// JRLabel && JRButton Title Label


#define JSON_CHWORD_SPACE           @"CH_SPACE"
#define JSON_ENWORD_SPACE           @"EN_SPACE"





// JRBaseView

#define k_Frames                    @"frames"

#define k_SubRenders                @"SubRenders"



// JRTextField

#define k_JR_ENABLE                 @"JR_ENABLE"
#define k_JR_PASSWORD               @"JR_PASSWORD"
#define k_JR_ISNUMBER               @"JR_ISNUMBER"
#define k_JR_LEFTINSET              @"JR_LEFTINSET"
#define k_JR_BORDERSTYLE            @"JR_BORDERSTYLE"

//
#define k_JR_TITLE_KEY              @"JR_TITLE_KEY"

//
#define k_JR_ISBOOL                 @"JR_ISBOOL"
#define k_JR_BOOLKEYS               @"JR_BOOLKEYS"

//
#define k_JR_ISNAME_NUMBER           @"JR_ISNAME_NO"

#define k_JR_MEMBERTYPE             @"JR_MEMBERTYPE"

#define k_JR_ISENUM                 @"JR_ISENUM"
#define k_JR_ENUMVALUES             @"JR_ENUMVALUES"
#define k_JR_ENUMLOCALIZES          @"JR_ENUMLOCALIZES"


// JRImageView

#define k_JR_CORNERRADIUS           @"JR_Radius"

// JRImageView && JRTextField

#define k_JR_Image                  @"JR_IMG"


// JRImageView && JRButton
#define k_JR_ENABLE                 @"JR_ENABLE"

// JRButton

#define k_JR_BGN_Image              @"JR_BGN_IMG"        // Background Normal
#define k_JR_BGH_Image              @"JR_BGH_IMG"        // Background Highlight
#define k_JR_BGS_Image              @"JR_BGS_IMG"        // Background Selected

#define k_JR_FGN_Image              @"JR_FGN_IMG"        // Foreground Normal
#define k_JR_FGH_Image              @"JR_FGH_IMG"        // Foreground Highlight
#define k_JR_FGS_Image              @"JR_FGS_IMG"        // Foreground Selected

#define k_JR_CONT_Insets            @"JR_CONT_Insets"        // Content edgeInsets
#define k_JR_TITLE_Insets           @"JR_TITLE_Insets"        // Title edgeInsets
#define k_JR_FGIMG_Insets           @"JR_FGIMG_Insets"        // Foreground edgeInsets



// JRSignatureView
#define k_JR_GLCOLOR                @"JR_GLCOLOR"

// JRCheckBox

#define k_JR_Check_IMG              @"CHECK_IMG"
#define k_JR_UNCheck_IMG            @"UNCHECK_IMG"


// JRComplexView
#define k_JR_DISABLE_DEFAULTVALUES @"DISABLE_VALUE"




// JRTableView , JRRefreshTableView
#define k_JR_CELLBGN_Image              @"JR_CELLBGN_IMG"
#define k_JR_CELLBGH_Image              @"JR_CELLBGH_IMG"
#define k_JR_TBL_HIDESECTION            @"HIDE_SECTION"
#define k_JR_TBL_SHOWLINENOCONTENTS     @"SHOW_LINES"

#define k_JR_TBL_SECTIONHEIGHT          @"SECTION_HEIGHT"
#define k_JR_TBL_CELLHEIGHT             @"CELL_HEIGHT"
#define k_JR_CELL_BORDER                @"CELL_BORDER"
#define k_JR_CELL_BGCOLOR               @"CELL_BGCOLOR"
#define k_JR_CELL_RADIUS                @"CELL_RADIUS"


// JRRefreshTableView
#define k_JR_TBL_HIDESEARCH             @"HIDE_SEARCH_BAR"          // search table
#define k_JR_TBL_HIDEREFRESH            @"HIDE_REFRESH"             // refresh table

#define k_JR_TBL_headerGap              @"headerGap"
#define k_JR_TBL_headerColor            @"headerColor"
#define k_JR_TBL_headerHeight           @"headerHeight"

#define  k_JR_TBL_headers               @"headers"
#define  k_JR_TBL_headersX              @"headersX"
#define  k_JR_TBL_valuesX               @"valuesX"
#define  k_JR_TBL_headersY              @"headersY"
#define  k_JR_TBL_valuesY               @"valuesY"


