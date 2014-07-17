//
//  UserInstance.h
//  XinYuanERP
//
//  Created by Xinyuan4 on 13-9-18.
//  Copyright (c) 2013年 Xinyuan4. All rights reserved.
//

#import <Foundation/Foundation.h>


#define GLOBAL [UserInstance sharedInstance]

@interface UserInstance : NSObject
{
    
    NSString *_DGUDID;
    NSString *_userName;
    NSString *_userJobNum;
    NSString *_userPwd;
    NSString *_permissions;//权限级别
    
}

@property(nonatomic,strong) NSString *DGUDID;
@property(nonatomic,strong) NSString *userName;
@property(nonatomic,strong) NSString *userJobNum;
@property(nonatomic,strong) NSString *userPwd;
@property(nonatomic,strong) NSString *permissions;

@property(nonatomic,strong) NSMutableDictionary* allEmployeesInfos;

/*Client data instance*/
@property(nonatomic,strong) NSDictionary* CLIENTDATA;


+ (UserInstance *)sharedInstance;

@end
