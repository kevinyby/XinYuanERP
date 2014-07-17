//
//  UserInstance.m
//  XinYuanERP
//
//  Created by Xinyuan4 on 13-9-18.
//  Copyright (c) 2013年 Xinyuan4. All rights reserved.
//

#import "UserInstance.h"


@implementation UserInstance

@synthesize DGUDID=_DGUDID;
@synthesize userName=_userName;
@synthesize userJobNum=_userJobNum;
@synthesize userPwd=_userPwd;
@synthesize permissions=_permissions;


@synthesize allEmployeesInfos;

@synthesize CLIENTDATA;


+ (UserInstance *)sharedInstance
{
    static UserInstance* sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[UserInstance alloc] init];
    });
    return sharedInstance;
}

-(id)init{
    if(self= [super init]){
        self.DGUDID = @"";
        self.userName = @"";
        self.userJobNum=@"";
        self.userPwd=@"";
        self.permissions=@"";
        
        
    }
    return self;
}


@end
