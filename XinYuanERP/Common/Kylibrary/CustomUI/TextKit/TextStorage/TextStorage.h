//
//  TextStorage.h
//  Reader
//
//  Created by Xinyuan4 on 14-4-14.
//  Copyright (c) 2014年 Xinyuan4. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TextStorage : NSTextStorage
{
     NSMutableAttributedString *_storingText;
}

@property (nonatomic, assign) BOOL dynamicUpdate;

@property (nonatomic, assign) BOOL editTextStatus;

@property (nonatomic, assign) BOOL regExp;

@property (nonatomic, strong) NSMutableArray *regExpArray;


@end
