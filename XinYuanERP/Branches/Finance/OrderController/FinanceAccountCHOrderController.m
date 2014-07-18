#import "FinanceAccountCHOrderController.h"
#import "AppInterface.h"

#define attr_financeAccountId @"financeAccountId"

@interface FinanceAccountCHOrderController ()

@end

@implementation FinanceAccountCHOrderController
{
    NSArray* needInfosFields;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.infosFields = @[@"bank", @"branch"];
        self.infosModel = MODEL_FinanceAccount;
        self.infosMap = @{PROPERTY_IDENTIFIER: attr_financeAccountId};
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    JsonView* jsonView = self.jsonView;
    
    
    //-------------------------------- Picker Old Data Begin --------------------------------
    // number event
    JRTextField* numberOldTx = ((JRLabelCommaTextFieldView*)[jsonView getView:@"number_O"]).textField;
    numberOldTx.textFieldDidClickAction = ^void(JRTextField* textField) {
        NSArray* needFields = @[@"number", @"name"];
        PickerModelTableView* pickView = [PickerModelTableView popupWithRequestModel:MODEL_FinanceAccount fields:needFields willDimissBlock:nil];
        
        // when select
        pickView.titleHeaderViewDidSelectAction = ^void(JRTitleHeaderTableView* headerTableView, NSIndexPath* indexPath){
            
            FilterTableView* filterTableView = (FilterTableView*)headerTableView.tableView.tableView;
            NSIndexPath* realIndexPath = [filterTableView getRealIndexPathInFilterMode: indexPath];
            
            NSString* identifier = [[filterTableView realContentForIndexPath: realIndexPath] firstObject];
            NSDictionary* objects = @{PROPERTY_IDENTIFIER: identifier};
            [VIEW.progress show];
            [AppServerRequester readModel: MODEL_FinanceAccount department:DEPARTMENT_FINANCE objects:objects completeHandler:^(ResponseJsonModel *data, NSError *error) {
                [VIEW.progress hide];
                if (error) {
                    [ACTION alertError: error];
                } else {
                    JsonDivView* bodyDivView = (JsonDivView*)[jsonView getView: @"NESTED_BODY"];

                    NSDictionary* tempModel = [[data.results firstObject] firstObject];
                    NSMutableDictionary* modelToRender = [DictionaryHelper deepCopy: tempModel];
                    [DictionaryHelper replaceKeys: modelToRender keys:@[PROPERTY_IDENTIFIER, @"number", @"name",@"bankAccountNumber",@"amount",@"address"] withKeys:@[attr_financeAccountId, @"number_O", @"name_O",@"bankAccountNumber_O",@"amount_O",@"address_O"]];

                    // Automatic fill the textfield .
                    [bodyDivView clearModel];
                    [bodyDivView setModel: modelToRender];
                }
            }];
            
            [PickerModelTableView dismiss];
        };
    };
    //-------------------------------- Picker Old Data End --------------------------------
}


@end
