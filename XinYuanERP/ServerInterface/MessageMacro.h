//
//  MessageMacro.h
//  XinYuanERP
//
//  Created by Xinyuan4 on 13-10-7.
//  Copyright (c) 2013年 Xinyuan4. All rights reserved.
//

#ifndef XinYuanERP_MessageMacro_h
#define XinYuanERP_MessageMacro_h

#define APNS_ORDERAPPLYALERTMESSAGE(_ORDER)   [NSString stringWithFormat:@"您有新的 %@ 需要审核",LOCALIZE_KEY(_ORDER)]
#define APNS_ORDERAPPROVEALERTMESSAGE(_ORDER) [NSString stringWithFormat:@"你的创建 %@ 得到核准",LOCALIZE_KEY(_ORDER)]
#define APNS_ORDERREJECTALERTMESSAGE(_ORDER)  [NSString stringWithFormat:@"你创建/审核的 %@ 被退回",LOCALIZE_KEY(_ORDER)]


/*所有单共用的提示语*/
#define ALERTMESSAGE_ORDERFAIL_READ(_ORDER)   [NSString stringWithFormat:@"%@查询失败",LOCALIZE_KEY(_ORDER)]
#define ALERTMESSAGE_ORDERFAIL_CREATE(_ORDER) [NSString stringWithFormat:@"%@生成失败",LOCALIZE_KEY(_ORDER)]
#define ALERTMESSAGE_ORDERFAIL_APPLY(_ORDER)  [NSString stringWithFormat:@"%@通知失败",LOCALIZE_KEY(_ORDER)]
#define ALERTMESSAGE_ORDERFAIL_DELETE(_ORDER) [NSString stringWithFormat:@"%@删除失败",LOCALIZE_KEY(_ORDER)]
#define ALERTMESSAGE_ORDERFAIL_MODIFY(_ORDER) [NSString stringWithFormat:@"%@审查失败",LOCALIZE_KEY(_ORDER)]

#define ALERTMESSAGE_IMAGEFAIL_UPLOAD         @"上传图片失败"
#define ALERTMESSAGE_IMAGEFAIL_DOWNLOAD       @"读取图片失败"

#define ALERTMESSAGE_PUBLIC_PHOTO        @"请拍照，再上传保存"
#define ALERTMESSAGE_PUBLIC_SIGN         @"请保存签名档"
#define ALERTMESSAGE_PUBLIC_NEXTAPPROVE  @"请选择下级核准人"

#define ALERTMESSAGE_BASESETTING_CANCEL    @"您确定要取消当前的单吗？"
#define ALERTMESSAGE_BASESETTING_ABNORMAL  @"您确定要使当前的单异常吗？"
#define ALERTMESSAGE_BASESETTING_REJECT    @"您确定要退回当前的单吗？"


/*借出单*/
#define ALERTMESSAGE_JCD_DATENOTPERTODAY @"预计还入时间不能早于当天"



#pragma mark -
#pragma mark 网络请求返回错误Code
#define WEB_CONNECT_ERROR    LOCALIZE_KEY(@"WEB_LJSB")
#define WEB_REQUEST_ERROR    LOCALIZE_KEY(@"WEB_FWYC")

#endif
