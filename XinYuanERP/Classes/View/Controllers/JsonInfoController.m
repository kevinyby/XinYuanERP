#import "JsonInfoController.h"
#import "AppInterface.h"

@interface JsonInfoController ()

@end

@implementation JsonInfoController


@synthesize infosFields;
@synthesize infosModel;
@synthesize infosMap;


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
    // Do any additional setup after loading the view.
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


#pragma mark - Override Super Class Methods
-(RequestJsonModel*) assembleReadRequest:(NSDictionary*)objects
{
    RequestJsonModel* requestModel = [RequestJsonModel getJsonModel];
    
    // check if the same department
    if ([[DATA.modelsStructure getCategory: self.order] isEqualToString: [DATA.modelsStructure getCategory: infosModel]]) {
        requestModel.path = PATH_LOGIC_READ(self.department);
    } else {
        requestModel.path = PATH_LOGIC_READ(SUPERBRANCH);
    }
    
    [requestModel addModels: self.order, infosModel, nil];
    [requestModel addObjects: objects, @{}, nil];
    [requestModel.fields addObjectsFromArray:@[@[], infosFields]];
    
    NSMutableDictionary* map = [NSMutableDictionary dictionary];
    for (NSString* key in infosMap) {
        NSString* value = [NSString stringWithFormat:@"0-0-%@", infosMap[key]];
        [map setObject: value forKey:key];
    }
    [requestModel.preconditions addObjectsFromArray: @[@{}, map]];
    return requestModel;
}

-(NSMutableDictionary*) assembleReadResponse: (ResponseJsonModel*)response
{
    NSMutableDictionary* modelToRender = [super assembleReadResponse:response];
    
    // set the infos
    NSArray* infoFieldValues = [[response.results lastObject] firstObject];
    NSDictionary* infos = [DictionaryHelper convert: infoFieldValues keys:infosFields];
    [DictionaryHelper combine: modelToRender with:infos];
    
    return modelToRender;
}

@end
