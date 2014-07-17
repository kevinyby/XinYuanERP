
#ifndef XinYuanERP_RequestMacro_h
#define XinYuanERP_RequestMacro_h


#define JSON_STATUS_SUCCESS   @"1"
#define JSON_STATUS_FAILURE   @"0"



#define REQUEST_JSON          @"JSON"
#define REQUEST_MODELS        @"MODELS"
#define REQUEST_PARAMETERS    @"PARAMETERS"
#define REQUEST_OBJECTS       @"OBJECTS"
#define REQUEST_FIELDS        @"FIELDS"
#define REQUEST_IDENTITYS     @"IDENTITYS"
#define REQUEST_CONDITION     @"JOINS"
#define REQUEST_PASSWORDS     @"PASSWORDS"
#define REQUEST_APNS_FORWARDS @"APNS_FORWARDS"
#define REQUEST_APNS_CONTENTS @"APNS_CONTENTS"

// APPLE
#define REQUEST_APNS_ALERT    @"alert"
#define REQUEST_APNS_SOUND    @"sound"
#define REQUEST_APNS_BADGE    @"badge"

// CUSTOM
#define REQUEST_APNS_INFOS      @"APNS_INFOS"
#define APNS_INFOS_ACTION       @"A"
#define APNS_INFOS_CATEGORY     @"C"
#define APNS_INFOS_MODEL        @"M"
#define APNS_INFOS_ID           @"ID"
#define APNS_INFOS_USER_FROM    @"U_F"
#define APNS_INFOS_USER_TO      @"U_T"





#define REQUEST_PARA_APPLEVEL   @"APPLEVEL"


#pragma mark - CRITERIAL

#define CRITERIAL_CONNECTOR     @"<>"
#define CRITERIAL_AND           @"and"
#define CRITERIAL_OR            @"or"

#define CRITERIAL_BT        @"BT<>"
#define CRITERIAL_BTAND     @"_TO_"

#define CRITERIAL_LK        @"LK<>"
#define CRITERIAL_NLK        @"NLK<>"

#define CRITERIAL_EQ        @"EQ<>"
#define CRITERIAL_NEQ       @"NEQ<>"

#define CRITERIAL_LT        @"LT<>"
#define CRITERIAL_LTEQ      @"LTEQ<>"

#define CRITERIAL_GT        @"GT<>"
#define CRITERIAL_GTEQ      @"GTEQ<>"

#define CRITERIAL_VAULE_CONNECTOR @"*"


#endif
