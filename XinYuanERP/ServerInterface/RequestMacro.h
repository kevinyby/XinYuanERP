
#ifndef XinYuanERP_RequestMacro_h
#define XinYuanERP_RequestMacro_h


#pragma mark - APNS

// APPLE
#define REQUEST_APNS_ALERT    @"alert"
#define REQUEST_APNS_SOUND    @"sound"
#define REQUEST_APNS_BADGE    @"badge"

// CUSTOM
#define REQUEST_APNS_INFOS              @"IS"
#define APNS_INFOS_CATEGORY_MODEL       @"CM"
#define APNS_INFOS_ID                   @"ID"
#define APNS_INFOS_USER_FROM            @"F"
#define APNS_INFOS_USER_TO              @"T"




#pragma mark - 

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
