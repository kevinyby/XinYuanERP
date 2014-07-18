//
//  WHPickingDetailsCell.m
//  XinYuanERP
//
//  Created by Xinyuan4 on 14-6-14.
//  Copyright (c) 2014年 Xinyuan4. All rights reserved.
//

#import "WHPickingDetailsCell.h"
#import "AppInterface.h"

@interface WHPickingDetailsCell() <UITextFieldDelegate>

@property(nonatomic,strong)JRTextField* projectNameTxtField;
@property(nonatomic,strong)JRTextField* productCodeTxtField;
@property(nonatomic,strong)JRTextField* productNameTxtField;
@property(nonatomic,strong)JRTextField* pickingAmountTxtField;
@property(nonatomic,strong)JRTextField* unitTxtField;
@property(nonatomic,strong)JRTextField* pickingStaffTxtField;
@property(nonatomic,strong)JRTextField* recycleAmountTxtField;

@end

@implementation WHPickingDetailsCell


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        _projectNameTxtField = [[JRTextField alloc] init];
        
        _productCodeTxtField = [[JRTextField alloc] init];
        
        _productNameTxtField = [[JRTextField alloc] init];
        
        _pickingAmountTxtField = [[JRTextField alloc] init];
        
        _unitTxtField = [[JRTextField alloc] init];

        _pickingStaffTxtField = [[JRTextField alloc] init];

        _recycleAmountTxtField = [[JRTextField alloc] init];
        

        [self.contentView addSubview:_projectNameTxtField];
        [self.contentView addSubview:_productCodeTxtField];
        [self.contentView addSubview:_productNameTxtField];
        [self.contentView addSubview:_pickingAmountTxtField];
        [self.contentView addSubview:_unitTxtField];
        [self.contentView addSubview:_pickingStaffTxtField];
        [self.contentView addSubview:_recycleAmountTxtField];
        
        self.backgroundColor = [UIColor clearColor];
        
        [super renderCellSubView:@"WHPickingDetailsOrder"];
        
        [self setTextFieldDidClickAction];
        
    }
    return self;
}

#pragma mark - 
#pragma mark - Handle

-(void)setTextFieldDidClickAction
{
    __weak WHPickingDetailsCell* weakSelf = self;
    
    _projectNameTxtField.textFieldDidClickAction = ^void(JRTextField* jrTextField){
        
        NSArray* needFields = @[@"application",@"productCode",@"productName",@"pickingAmount",@"unit",@"pickingStaff",@"recycleAmount"];
        PickerModelTableView* pickView = [PickerModelTableView popupWithRequestModel:ORDER_WHPickingOrder fields:needFields willDimissBlock:nil];
        pickView.tableView.headersXcoordinates = @[@(20), @(120),@(230),@(300),@(400),@(460),@(560)];
        pickView.titleHeaderViewDidSelectAction = ^void(JRTitleHeaderTableView* headerTableView, NSIndexPath* indexPath){
            FilterTableView* filterTableView = (FilterTableView*)headerTableView.tableView.tableView;
            NSIndexPath* realIndexPath = [filterTableView getRealIndexPathInFilterMode: indexPath];
            
            NSArray* array = [filterTableView realContentForIndexPath: realIndexPath];
            
            weakSelf.projectNameTxtField.text   =  OBJECT_EMPYT([array objectAtIndex:1]) ? @"" : [array objectAtIndex:1];
            weakSelf.productCodeTxtField.text   =  OBJECT_EMPYT([array objectAtIndex:2]) ? @"" : [array objectAtIndex:2];
            weakSelf.productNameTxtField.text   =  OBJECT_EMPYT([array objectAtIndex:3]) ? @"" : [array objectAtIndex:3];
            weakSelf.pickingAmountTxtField.text =  OBJECT_EMPYT([array objectAtIndex:4]) ? @"" : [[array objectAtIndex:4] stringValue];
            weakSelf.unitTxtField.text          =  OBJECT_EMPYT([array objectAtIndex:5]) ? @"" : [array objectAtIndex:5];
            weakSelf.pickingStaffTxtField.text  =  OBJECT_EMPYT([array objectAtIndex:6]) ? @"" : [array objectAtIndex:6];
            weakSelf.recycleAmountTxtField.text =  OBJECT_EMPYT([array objectAtIndex:7]) ? @"" : [[array objectAtIndex:7] stringValue];
            
            [PickerModelTableView dismiss];
            
            if (weakSelf.didEndEditNewCellAction) weakSelf.didEndEditNewCellAction(weakSelf);
        };
        
    };
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
