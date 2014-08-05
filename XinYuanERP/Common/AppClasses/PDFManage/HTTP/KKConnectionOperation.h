//
//  KKConnectionOperation.h
//  XinYuanERP
//
//  Created by Xinyuan4 on 14-7-24.
//  Copyright (c) 2014年 Xinyuan4. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KKConnectionOperation : NSOperation<NSURLConnectionDelegate, NSURLConnectionDataDelegate>

+ (NSArray *)batchOfRequestOperations:(NSArray *)operations
                        progressBlock:(void (^)(NSUInteger numberOfFinishedOperations, NSUInteger totalNumberOfOperations,KKConnectionOperation* operation))progressBlock
                      completionBlock:(void (^)(NSArray *operations))completionBlock;

@end
