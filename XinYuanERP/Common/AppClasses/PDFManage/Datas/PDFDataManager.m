//
//  PDFDataManager.m
//  XinYuanERP
//
//  Created by Xinyuan4 on 14-7-24.
//  Copyright (c) 2014年 Xinyuan4. All rights reserved.
//

#import "PDFDataManager.h"

#import "_HTTP.h"


#ifdef DEBUG

//#define test_ip  @"http://192.168.0.204:8051/service/"
#define test_ip  @"http://61.143.227.60:8051/service/"

#endif

#ifdef RELEASE

#define test_ip @"http://61.143.227.60:8051/service/"

#endif



@implementation PDFDataManager


+(instancetype)sharedManager
{
    static PDFDataManager* sharedDataSource = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedDataSource = [[PDFDataManager alloc] init];
        sharedDataSource->_PDFStack = [[NSMutableArray alloc] init];
        
    });
    return sharedDataSource;
}



-(NSString*) requestURL:(NSString*)url{
    return [test_ip stringByAppendingPathComponent:url];
}

-(NSString*) assemblePath:(NSString*)subPath{
    NSString* rootPath = @"PDF/";
    return [rootPath stringByAppendingString:subPath];
}


-(void)requestWithParameter:(NSString*)path WithComplete:(void(^)(NSError* error))callback{
    
    HTTPPostRequest* request = [[HTTPPostRequest alloc] initWithURLString:[self requestURL:@"struct"] parameters:@{@"PATH":[self assemblePath:path]}];
    [request startAsynchronousRequest:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (!connectionError){
            NSDictionary* jsonDic = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
            NSLog(@"jsonDic == %@",jsonDic);
            self.PDFDic = [self assembleDataSource:jsonDic[path][@"content"] key:path];
//            NSLog(@"self.PDFDic == %@",jsonDic);
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            callback(connectionError);
        });
    }];
}



-(NSMutableDictionary*)assembleDataSource:(NSDictionary*)source key:(NSString*)basekey
{
    NSMutableDictionary* assembleDictionary = [NSMutableDictionary dictionary];
    NSMutableArray* subArray = [NSMutableArray array];
    for (NSString* key in [source allKeys]) {
        if ([source[key] isKindOfClass:[NSDictionary class]]) {
            NSDictionary* subDic = source[key];
            if (subDic[@"content"]) {
                 NSDictionary* contentDic = subDic[@"content"];
                [subArray addObject:[self assembleDataSource:contentDic key:key]];
            }else{
                [subArray addObject:key];
            }
        }
    }
    [assembleDictionary setObject:subArray forKey:basekey];
    
    return assembleDictionary;
}


#pragma mark -
#pragma mark -

+ (NSString*)getDictionaryKey:(NSDictionary*)dictionary
{
    NSString* key = [[dictionary allKeys] lastObject];
    return key;
}

+ (NSArray*)getDictionaryArray:(NSDictionary*)dictionary
{
    NSString* key = [PDFDataManager getDictionaryKey:dictionary];
    NSArray* content = [dictionary objectForKey:key];
    return content;
}

#pragma mark -
#pragma mark - 

+(void)addTextToContain:(NSString*)text contain:(NSMutableArray*)containArray
{
    if ([[[PDFDataManager sharedManager] PDFStack] count] == 0) return;
    
    NSString* stackString = [self assembleStackString:text];
    [containArray addObject:stackString];
    
}

+(void)removeTextFromContain:(NSString*)text contain:(NSMutableArray*)containArray
{
    if ([[[PDFDataManager sharedManager] PDFStack] count] == 0) return;
    NSString* stackString = [self assembleStackString:text];
    [containArray removeObject:stackString];
}

+(BOOL)judgeTextInContain:(NSString*)text contain:(NSMutableArray*)containArray
{
    if ([[[PDFDataManager sharedManager] PDFStack] count] == 0) return NO;
    
    NSString* stackString = [self assembleStackString:text];
    return [containArray containsObject:stackString];
    
}

+ (NSString*)assembleStackString:(NSString*)text
{
    NSString* stackString = @"";
    int count = [[[PDFDataManager sharedManager] PDFStack] count];
    NSMutableArray* stackArray = [[PDFDataManager sharedManager] PDFStack];
    for (int i = 0; i<count; ++i) {
        NSDictionary* dic = stackArray[i];
        NSString* subKey = [PDFDataManager getDictionaryKey:dic];
        stackString = [stackString stringByAppendingString:subKey];
        stackString = [stackString stringByAppendingString:@"/"];
    }
    
    stackString = [stackString stringByAppendingString:text];
    return stackString;
}



@end
