//
//  OrderJsonModelFactory.h
//  XinYuanERP
//
//  Created by Xinyuan4 on 13-11-25.
//  Copyright (c) 2013年 Xinyuan4. All rights reserved.
//

#import <Foundation/Foundation.h>

#define DEPARTMENT_HTTPURL(_DEPARTMENT,_OPERATE)  [NSString stringWithFormat:@"/logic/%@__%@",_DEPARTMENT,_OPERATE]

@class RequestJsonModel;
@interface RequestJsonModelFactory : NSObject

+ (RequestJsonModel*)factoryJsonModelCreate:(NSMutableDictionary*)modelDic
                             departMent:(NSString*)depart
                                  order:(NSString*)iOrder;

+ (RequestJsonModel*)factoryJsonModelRead:(NSMutableDictionary*)modelDic
                           departMent:(NSString*)depart
                                order:(NSString*)iOrder;

+ (RequestJsonModel*)factoryJsonModelApply:(NSString*)depart
                                     order:(NSString*)iOrder
                                   objects:(NSMutableDictionary*)iObject
                                  applevel:(NSString*)iApplevel
                                identities:(NSString*)identifier
                                   billKey:(NSString*)iBill
                              apnsforwards:(NSString *)iForwards
                              apnsContents:(NSMutableDictionary*)iContents;


+ (RequestJsonModel*)factoryJsonModelModify:(NSMutableDictionary*)modelDic
                             departMent:(NSString*)depart
                                  order:(NSString*)iOrder
                                orderNo:(NSString*)iOrderNo;


+ (RequestJsonModel*)factoryJsonModelInformApnsforwards:(NSString *)iForwards
                                           apnsContents:(NSMutableDictionary*)iContents;

+ (RequestJsonModel*)factoryMultiJsonModels:(NSArray*)iModels
                                    objects:(NSArray*)iObjects
                                       path:(NSString*)iPath;

@end
