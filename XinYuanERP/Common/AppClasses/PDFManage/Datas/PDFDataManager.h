//
//  PDFDataManager.h
//  XinYuanERP
//
//  Created by Xinyuan4 on 14-7-24.
//  Copyright (c) 2014年 Xinyuan4. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PDFDataManager : NSObject

@property(nonatomic,strong)NSMutableDictionary* PDFDic;

@property(nonatomic,strong)NSMutableArray* PDFStack;

+ (instancetype)sharedManager;

- (void)requestWithParameter:(NSString*)path WithComplete:(void(^)(NSError* error))callback;

+ (NSString*)getDictionaryKey:(NSDictionary*)dictionary;
+ (NSArray*)getDictionaryArray:(NSDictionary*)dictionary;

+ (void)addTextToContain:(NSString*)text contain:(NSMutableArray*)containArray;
+ (void)removeTextFromContain:(NSString*)text contain:(NSMutableArray*)containArray;
+ (BOOL)judgeTextInContain:(NSString*)text contain:(NSMutableArray*)containArray;

@end
