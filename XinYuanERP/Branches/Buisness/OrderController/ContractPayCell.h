//
//  ContractPayCell.h
//  XinYuanERP
//
//  Created by Xinyuan4 on 14-6-21.
//  Copyright (c) 2014年 Xinyuan4. All rights reserved.
//

#import "BaseJRTableViewCell.h"

@class JRTextField;
@interface ContractPayCell : BaseJRTableViewCell

@property(nonatomic,strong)JRTextField* installmentTxtField;
@property(nonatomic,strong)JRTextField* willPayDateTxtField;
@property(nonatomic,strong)JRTextField* payRateTxtField;
@property(nonatomic,strong)JRTextField* payAmountTxtField;

@property (nonatomic,assign)id textFieldDelegate;


@end

