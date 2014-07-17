#import "PickerModelTableView.h"
#import "AppInterface.h"


@implementation PickerModelTableView


- (id)initWithModel: (NSString*) model
{
    self = [super init];
    if (self) {
        // set frame
        [FrameHelper setFrame: CGRectMake(0, 0, 650, 500) view:self];
        
        // title
        self.titleLabel.text = LOCALIZE_KEY(model);
        
        // set data to table
        NSArray* headers = nil;
        NSMutableDictionary* contents = nil;
        NSMutableDictionary* realContents = nil;
        
        if ([model isEqualToString: MODEL_EMPLOYEE]) {
            
            self.titleLabel.text = LOCALIZE_KEY(KEY_EMPLOYEE);
            headers = @[ LOCALIZE_KEY(@"employeeNO") , LOCALIZE_KEY(@"name")  ];
            
            // filter the resigned
            NSMutableArray* numbers = [ArrayHelper deepCopy: [DATA.usersNONames allKeys]];
            for (int i = 0; i < numbers.count; i++) {
                NSString* username = numbers[i];
                if ([DATA.usersNOResign[username] boolValue]) {
                    [numbers removeObject: username];
                    i--;
                }
            }
            
            [PickerModelTableView setEmployeesNumbersNames:self.tableView.tableView numbers:numbers];
            
        } else if ([model isEqualToString: MODEL_VENDOR]) {
            
        } else if ([model isEqualToString: MODEL_CLIENT]) {
            
        }
        
        self.tableView.searchBarHeight = [FrameTranslater convertCanvasHeight: 45];
        if (headers) {
            self.tableView.headers = headers;
            self.tableView.headersXcoordinates = @[@(50) , @(305)];
        }
        if (contents) self.tableView.tableView.contentsDictionary = contents;
        if (realContents) self.tableView.tableView.realContentsDictionary = realContents;
    }
    return self;
}



+(void) setEmployeesNumbersNames:(TableViewBase*)tableViewBase numbers:(NSMutableArray*)numbers
{
    // numbers
    [numbers sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 compare: obj2];
    }];
    // numbers and username
    NSMutableArray* contentsTemp = [NSMutableArray array];
    [IterateHelper iterate: numbers handler:^BOOL(int index, id obj, int count) {
        NSString* name = DATA.usersNONames[obj];
        if (! name){
            name = @"<no name???>";
        }
        [contentsTemp addObject: @[obj, name]];
        return NO;
    }];
    tableViewBase.contentsDictionary = [NSMutableDictionary dictionaryWithObject:contentsTemp forKey:@""];
    tableViewBase.realContentsDictionary = [NSMutableDictionary dictionaryWithObject:numbers forKey:@""];
}



#pragma mark - Class Pair Methods
+(PickerModelTableView*) getPickerModelView:(NSString*)model fields:(NSArray*)fields criterias:(NSDictionary*)criterias
{
    PickerModelTableView* pickerView = [[PickerModelTableView alloc] initWithModel:model];
    [ViewHelper setShadowWithCorner:pickerView config:@{@"CornerRadius":@(5.0)}];
    
    // headers
    NSMutableArray* localizeHeaders = [NSMutableArray array];
    for (int i = 0; i < fields.count; i++) {
        [localizeHeaders addObject: LOCALIZE_CONNECT_KEYS(model, fields[i])];
    }
    pickerView.tableView.headers = [LocalizeHelper localize: localizeHeaders];
    
    NSString* department = [DATA.modelsStructure getCategory: model];
    
    // assemble request
    RequestJsonModel* requestModel = [RequestJsonModel getJsonModel];
    requestModel.path = PATH_LOGIC_READ(department);
    [requestModel addModel: model];
    NSMutableArray* withIdFields = [ArrayHelper deepCopy: fields];
    [withIdFields insertObject: PROPERTY_IDENTIFIER atIndex:0];
    [requestModel.fields addObject: withIdFields];
    if (criterias)[requestModel.criterias addObject:criterias];
    
    // get data from server

    [AppViewHelper showIndicatorInView: pickerView];
    [DATA.requester startPostRequest:requestModel completeHandler:^(HTTPRequester *requester, ResponseJsonModel *model, NSHTTPURLResponse *httpURLReqponse, NSError *error) {
        [AppViewHelper stopIndicatorInView: pickerView];
        if (model.status) {
            ContentFilterBlock contentFilterBlock = ^void(int elementIndex , int innerCount, int outterCount, NSString* section, id cellElement, NSMutableArray* cellRepository) {
                if (elementIndex != 0) {
                    if (cellElement) {
                        [cellRepository addObject: cellElement];
                    }
                }
            };
            
            [ListViewControllerHelper assembleTableContents: pickerView.tableView.tableView objects:model.results keys:model.models filter:contentFilterBlock];
            [pickerView.tableView reloadTableData];
        } else {
            [ACTION alertError: error];
        }
    }];
    
    return pickerView;
}
+(PickerModelTableView*) popupWithModel:(NSString*)model willDimissBlock:(void(^)(UIView* view))dimissBlock
{
    PickerModelTableView* pickView = [[PickerModelTableView alloc] initWithModel:model];
    [ViewHelper setShadowWithCorner:pickView config:@{@"CornerRadius":@(5.0)}];
    [AnimationView presentAnimationView:pickView completion:nil];
    return pickView;
}

+(PickerModelTableView*) popupWithRequestModel:(NSString*)model fields:(NSArray*)fields willDimissBlock:(void(^)(UIView* view))dimissBlock
{
    PickerModelTableView* pickerView = [self getPickerModelView: model fields:fields criterias:nil];
    [AnimationView presentAnimationView:pickerView completion:nil];
    return pickerView;
}

+(void) dismiss
{
    [AnimationView dismissAnimationView];
}


@end
