#import "DepartmentsEditController.h"
#import "ClassesInterface.h"
#import "AppInterface.h"


@interface DepartmentsEditController()

@property (strong) NSMutableArray* categories;
@property (strong) NSMutableDictionary* permissions;

@end

@implementation DepartmentsEditController


@synthesize userNumber;
@synthesize categories;
@synthesize permissions;


#pragma mark - override methods

- (void)viewDidLoad
{
    categories = [[DATA.usersNOPermissions objectForKey: userNumber] objectForKey:CATEGORIES];
    permissions = [[DATA.usersNOPermissions objectForKey: userNumber] objectForKey:PERMISSIONS];
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    __weak DepartmentsEditController* weakInstance = self;
    
    self.wheelDidTapSwipLeftBlock = ^(AppWheelViewController* wheel, NSInteger index){
        NSString* department = [weakInstance.wheels objectAtIndex: index];
        
        NSArray* departmentOrders = [DATA.modelsStructure getOrders: department withBill:NO];
        
        // empty , like "Approval"
        if (! departmentOrders.count) return;
        if (! [weakInstance.permissions objectForKey: department]) [weakInstance.permissions setObject: [NSMutableDictionary dictionary] forKey:department];    // DEPARTMENT
        
        SetPermissionListController* controller = [[SetPermissionListController alloc] initWithDepartment: department];
        
        controller.orderPermissions = [weakInstance.permissions objectForKey: department];
        controller.contentsDictionary = [NSMutableDictionary dictionaryWithObject: departmentOrders forKey:department];
        
        [VIEW.navigator pushViewController: controller animated:YES];
    };
    
    
    self.wheelDidSwipRightBlock = ^(AppWheelViewController* wheel, UISwipeGestureRecognizer* sender){
        [DepartmentsEditController saveUserPermissions: weakInstance.userNumber categories:weakInstance.categories permissions:weakInstance.permissions completion:nil];
        [VIEW.navigator popViewControllerAnimated: YES];
    };
}


#pragma mark - carousel methods

- (UIView *)carousel:(Carousel *)carouselObj viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view{
    
    UIView* parentView = [super carousel:carouselObj viewForItemAtIndex:index reusingView:view];

    // set the show or not  UISwitch
    UISwitch* showSwitch = [[UISwitch alloc] init];
    showSwitch.tag = index;
    [parentView addSubview: showSwitch ];
    [showSwitch addTarget: self action:@selector(checkedAction:) forControlEvents:UIControlEventTouchUpInside];
    
    NSString* department = [self.wheels objectAtIndex: index];
    if ([categories containsObject: department]) showSwitch.on = YES;
    
    return parentView;
}

-(void) checkedAction:(id)sender {
    UISwitch* showBtn = (UISwitch*)sender;
    int index = showBtn.tag;
    
    NSString* department = [self.wheels objectAtIndex: index];
    if (showBtn.on) {
        if (! [categories containsObject: department]) [categories addObject: department];
        if (! [permissions objectForKey: department]) [permissions setObject: [NSMutableDictionary dictionary] forKey:department];    // DEPARTMENT
    } else {
        [categories removeObject: department];
        [permissions removeObjectForKey: department];
    }
}


#pragma mark - Class Methods

+(void) saveUserPermissions: (NSString*)userNumber categories:(NSMutableArray*)categories permissions:(NSMutableDictionary*)permissions completion:(void(^)(NSError* error))completion;
{
    // Save the user's permission
    [ViewControllerHelper filterDictionaryEmptyElement: permissions];
    NSString* compressPermissionJson = [CollectionHelper convertJSONObjectToJSONString:permissions];
    NSString* compressCategoryJson = [CollectionHelper convertJSONObjectToJSONString:categories];
    
    [ACTION.adminAction savePermissions: userNumber permissions:compressPermissionJson categories:compressCategoryJson completeHandler:^(NSError *errorObj) {
        if (errorObj) {
            NSString* message = [NSString stringWithFormat: @"Save %@ permissions failed , please check your network and try again", userNumber];
            UIAlertView* alert = [[UIAlertView alloc]
                                  initWithTitle:@""
                                  message:message
                                  delegate:nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles: nil];
            [alert show];
        }
        if (completion) completion(errorObj);
    }];
}


@end
