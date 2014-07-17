//
//  WHPurchaseOrderController.m
//  XinYuanERP
//
//  Created by Xinyuan4 on 14-1-23.
//  Copyright (c) 2014年 Xinyuan4. All rights reserved.
//

#import "WHPurchaseOrderController.h"
#import "AppInterface.h"

#import "WHPurchaseStorageCell.h"


@interface WHPurchaseOrderController ()
{
    JRRefreshTableView* _purchaseTableView;
    NSMutableArray* _purchaseCellContents;
    
    JRTextField* _deliveryTotalTxtField;
    JRTextField* _storageTotalTxtField;
}

@end

@implementation WHPurchaseOrderController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    __weak WHPurchaseOrderController* weakSelf = self;
    __block WHPurchaseOrderController* blockSelf = self;
    
    
    _deliveryTotalTxtField = ((JRLabelCommaTextFieldView*)[self.jsonView getView:@"NESTED_Middle_bottom.deliveryTotal"]).textField;
    _storageTotalTxtField = ((JRLabelCommaTextFieldView*)[self.jsonView getView:@"NESTED_Middle_bottom.storageTotal"]).textField;
    
    
    _purchaseCellContents = [[NSMutableArray alloc] init];

    _purchaseTableView = (JRRefreshTableView*)[self.jsonView getView:@"NESTED_Middle_top.TABLE_Purchase"];
    _purchaseTableView.tableView.tableViewBaseNumberOfSectionsAction = ^NSInteger(TableViewBase* tableViewObje){
        return 1;
    };
    _purchaseTableView.tableView.tableViewBaseNumberOfRowsInSectionAction = ^NSInteger(TableViewBase* tableViewObj, NSInteger section) {
        return weakSelf.controlMode == JsonControllerModeCreate ? blockSelf->_purchaseCellContents.count + 1 : blockSelf->_purchaseCellContents.count;
    };
    _purchaseTableView.tableView.tableViewBaseCellForIndexPathAction = ^UITableViewCell*(TableViewBase* tableViewObj, NSIndexPath* indexPath, UITableViewCell* oldCell) {
        static NSString *CellIdentifier = @"Cell";
        WHPurchaseStorageCell* cell = [tableViewObj dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[WHPurchaseStorageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            cell.didEndEditNewCellAction = ^void(BaseJRTableViewCell* cell){
                WHPurchaseStorageCell* purchaseCell = (WHPurchaseStorageCell*)cell;
                NSIndexPath* indexPath = [tableViewObj indexPathForCell: purchaseCell];
                int row = indexPath.row;
                if (row == blockSelf->_purchaseCellContents.count) {
                    [blockSelf->_purchaseCellContents addObject:[cell getDatas]];
                } else {
                    [blockSelf->_purchaseCellContents replaceObjectAtIndex:row withObject:[cell getDatas]];
                }
                
                [tableViewObj reloadData];
                [tableViewObj scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
            };
        }
        [cell setDatas: [blockSelf->_purchaseCellContents safeObjectAtIndex: indexPath.row]];
        [weakSelf refreshTotal];
        return cell;
    };
    
    
}

#pragma mark -
#pragma mark - Request

-(RequestJsonModel*) assembleReadRequest:(NSDictionary*)objects
{
    
    OrderSearchListViewController* list = [VIEW.navigator.viewControllers objectAtIndex: VIEW.navigator.viewControllers.count - 2];
    NSString* orderNO = [[list.headerTableView.tableView realContentForIndexPath: list.selectedIndexPath] objectAtIndex: 1];
    
    RequestJsonModel* requestModel = [OrderJsonModelFactory factoryMultiJsonModels:@[@"Warehouse.WHPurchaseOrder",@"Finance.FinancePaymentBill",@"Finance.FinancePaymentOrder"]
                                                                           objects:@[@{PROPERTY_ORDERNO:orderNO},@{@"referenceOrderNO":orderNO},@{}]
                                                                              path:DEPARTMENT_HTTPURL(SUPERBRANCH, PERMISSION_READ)];
    [requestModel.fields addObjectsFromArray:@[@[],@[@"paymentOrderNO",@"realPaid"],@[@"createDate"]]];
    [requestModel.joins addObjectsFromArray:@[@{},@{@"FinancePaymentBill.paymentOrderNO":@"EQ<>FinancePaymentOrder.orderNO"}]];
    
    return requestModel;
}


-(NSMutableDictionary*) assembleSendObjects: (NSString*)divViewKey
{
    NSMutableDictionary* objects = [super assembleSendObjects: divViewKey];
    
    [objects setObject:_purchaseCellContents forKey:@"WHPurchaseBills"];
    
    return objects;
}

#pragma mark -
#pragma mark - Response

-(NSMutableDictionary*) assembleReadResponse: (ResponseJsonModel*)response
{
    
    NSArray* results = response.results;
    NSMutableDictionary* responseObject = [NSMutableDictionary dictionary];
    
    NSArray* financePayMentArr = [results firstObject];
    NSArray* purchaseArr = [results lastObject];
    
    [responseObject setObject:financePayMentArr forKey:@"finance"];
    [responseObject setObject:[purchaseArr firstObject] forKey:@"purchase"];
    
    NSMutableDictionary* resultsObj = [DictionaryHelper deepCopy: responseObject];
    self.valueObjects = resultsObj[@"purchase"];
    
    DBLOG(@"resultsObj === %@", resultsObj);
    
    return resultsObj;
    
}

-(void) translateReceiveObjects: (NSMutableDictionary*)objects
{
    NSMutableDictionary* orderObjdect = [objects objectForKey:@"purchase"];
    [super translateReceiveObjects: orderObjdect];
}

-(void) renderWithReceiveObjects: (NSMutableDictionary*)objects
{
    NSMutableDictionary* purchaseDic = [objects objectForKey:@"purchase"];
    [self.jsonView setModel: purchaseDic];
    _purchaseCellContents = [purchaseDic objectForKey:@"WHPurchaseBills"];
    [_purchaseTableView reloadTableData];
}


#pragma mark -
#pragma mark - Order Operation
-(void)refreshTotal
{
    if (_purchaseCellContents.count == 0 || self.controlMode != JsonControllerModeCreate) return;
    float subTotalFloat = 0;
    float storageSubTotalFloat = 0;
    for (int i = 0; i < [_purchaseCellContents count] ; i++ ) {
        NSDictionary* dic = [_purchaseCellContents objectAtIndex:i];
        
        NSString* subTotal = [dic objectForKey:@"subTotal"];
        subTotalFloat += [subTotal floatValue];
        
        NSString* storageSubTotal = [dic objectForKey:@"storageSubTotal"];
        storageSubTotalFloat += [storageSubTotal floatValue];
    }
    
    _deliveryTotalTxtField.text = [[NSNumber numberWithFloat:subTotalFloat]stringValue];
    _storageTotalTxtField.text = [[NSNumber numberWithFloat:storageSubTotalFloat]stringValue];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
