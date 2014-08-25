//
//  OrderJsonModelFactory.m
//  XinYuanERP
//
//  Created by Xinyuan4 on 13-11-25.
//  Copyright (c) 2013年 Xinyuan4. All rights reserved.
//

#import "RequestJsonModelFactory.h"
#import "AppInterface.h"

@implementation RequestJsonModelFactory

+ (RequestJsonModel*)factoryJsonModelCreate:(NSMutableDictionary*)modelDic
                             departMent:(NSString*)depart
                                  order:(NSString*)iOrder
{
    RequestJsonModel* model = [self factoryJsonModels:iOrder objects:modelDic path:DEPARTMENT_HTTPURL(depart, PERMISSION_CREATE)];
    return model;
}
+ (RequestJsonModel*)factoryJsonModelRead:(NSMutableDictionary*)modelDic
                           departMent:(NSString*)depart
                                order:(NSString*)iOrder
{
    RequestJsonModel* model = [self factoryJsonModels:iOrder objects:modelDic path:DEPARTMENT_HTTPURL(depart, PERMISSION_READ)];
    return model;
}

+ (RequestJsonModel*)factoryJsonModelApply:(NSString*)depart
                                     order:(NSString*)iOrder
                                   objects:(NSMutableDictionary*)iObject
                                  applevel:(NSString*)iApplevel
                                identities:(NSString*)identifier
                                   billKey:(NSString*)iBill
                              apnsforwards:(NSString *)iForwards
                              apnsContents:(NSMutableDictionary*)iContents
{
    RequestJsonModel* model = [self factoryJsonModels:iOrder objects:iObject path:DEPARTMENT_HTTPURL(depart, PERMISSION_APPLY)];
    [model.identities addObject:[NSMutableDictionary dictionaryWithObject:identifier forKey:PROPERTY_IDENTIFIER]];
    [model.parameters setObject:iApplevel forKey:@"APPLEVEL"];
    if (!isEmptyString(iBill))[model.parameters setObject:iBill forKey:@"ISBILL"];
    [model.apns_forwards addObject:iForwards];
    [model.apns_contents addObject:iContents];
    return model;
    
}

+ (RequestJsonModel*)factoryJsonModelModify:(NSMutableDictionary*)modelDic
                             departMent:(NSString*)depart
                                  order:(NSString*)iOrder
                                orderNo:(NSString*)iOrderNo
{
    RequestJsonModel* model = [self factoryJsonModels:iOrder objects:modelDic path:DEPARTMENT_HTTPURL(depart, PERMISSION_MODIFY)];
    [model.identities addObject:[NSMutableDictionary dictionaryWithObject:iOrderNo forKey:PROPERTY_ORDERNO]];
    return model;
}


+ (RequestJsonModel*)factoryJsonModels:(NSString*)iModels objects:(NSMutableDictionary*)iObjects path:(NSString*)iPath{
    
    RequestJsonModel* model = [RequestJsonModel getJsonModel];
    model.path = iPath;
    [model addModels:iModels,nil];
    [model addObjects:iObjects,nil];
    return model;
}

+ (RequestJsonModel*)factoryMultiJsonModels:(NSArray*)iModels objects:(NSArray*)iObjects path:(NSString*)iPath{
    RequestJsonModel* model = [RequestJsonModel getJsonModel];
    model.path = iPath;
    for (NSString* val in iModels) {
        NSString* nval = [NSString stringWithFormat: @".%@",val];
        [model.models addObject:nval];
    }
    [model.objects addObjectsFromArray:iObjects];
    return model;
}

+ (RequestJsonModel*)factoryJsonModelInformApnsforwards:(NSString *)iForwards
                                           apnsContents:(NSMutableDictionary*)iContents
{
    RequestJsonModel* model = [RequestJsonModel getJsonModel];
    model.path = PATH_SETTING_INFORM;
    [model.apns_forwards addObject: iForwards];
    [model.apns_contents addObject: iContents];
    return model;
    
}


@end
