#import "JsonTabController.h"
#import "AppInterface.h"

@interface JsonTabController ()


@end

@implementation JsonTabController

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
    
    JsonDivView* tabsButtonsView = (JsonDivView*)[self.jsonView getView:json_NESTED_TABS];
    
    JsonDivView* scrollDivView = (JsonDivView*)[self.jsonView getView:json_NESTED_SCROLL];
    
    if (! tabsButtonsView || ! scrollDivView) return;
    
    _scrollDivView = scrollDivView;
    _tabsButtonsView = tabsButtonsView;
    
    [JsonTabController setupTabButtons: self];
}


-(int)currentTabIndex
{
    int currentIndex = 0;
    for (int i = 0; i < self.tabsButtonsView.subviews.count; i++) {
        JRButton* jrButton = [self.tabsButtonsView.subviews objectAtIndex:i];
        if (jrButton.selected) {
            currentIndex = i;
            break;
        }
    }
    return currentIndex;
}

-(BOOL) viewWillAppearShouldRequestServer
{
    NSLog(@"viewWillAppear: isMovingToParentViewController %d, isBeingPresented %d",self.isMovingToParentViewController, self.isBeingPresented);
    
    // Refresh the tab you need
    if (! self.isMovingToParentViewController) {
        int currentTabIndex = self.currentTabIndex;
        
        NSArray* refreshAttributs = [self getTheNeedRefreshTabsAttributesWhenPopBack];
        for (NSUInteger i = 0 ; i < refreshAttributs.count; i++) {
            NSString* attribute = [refreshAttributs objectAtIndex:i];
            if ([attribute rangeOfString:json_NESTED_TABS].location == NSNotFound) {
                attribute = [json_NESTED_TABS stringByAppendingFormat:@".%@", attribute];
            }
            JRButton* jrButton = (JRButton*)[self.jsonView getView:attribute];
            if (! jrButton) continue;
            NSUInteger pendingIndex = [self.tabsButtonsView.subviews indexOfObject: jrButton];
            if (pendingIndex == NSNotFound) continue;
            
            if (currentTabIndex == pendingIndex) {
                [jrButton sendActionsForControlEvents: UIControlEventTouchUpInside];
                break;
            }
            
        }
    }
    
    return [super viewWillAppearShouldRequestServer] && self.isMovingToParentViewController;
}


-(NSArray*) getTheNeedRefreshTabsAttributesWhenPopBack
{
    return nil;
}


#pragma mark - Tab Buttons Event
+(void) setupTabButtons: (JsonTabController*)jsonTabController
{
    JsonDivView* scrollDivView = jsonTabController.scrollDivView;
    JsonDivView* tabsButtonsView = jsonTabController.tabsButtonsView;
    NSArray* tabs = [tabsButtonsView subviews];
    
    // Add swipe gesture
    UISwipeGestureRecognizer* swipGestureRight = [[UISwipeGestureRecognizer alloc] initWithTarget: self action:@selector(swipTabs:)];
    swipGestureRight.direction = UISwipeGestureRecognizerDirectionRight ;
    UISwipeGestureRecognizer* swipGestureLeft = [[UISwipeGestureRecognizer alloc] initWithTarget: self action:@selector(swipTabs:)];
    swipGestureLeft.direction = UISwipeGestureRecognizerDirectionLeft ;
    [scrollDivView addGestureRecognizer: swipGestureRight];
    [scrollDivView addGestureRecognizer: swipGestureLeft];
    
    // default , display the first tab infomation , a tint
    JRButton* selectedButtonTab = (JRButton*)[tabs firstObject];
    selectedButtonTab.selected = YES;
    
    // SET CLICK SINGLE
    __weak JsonDivView* weakTabJsonView = tabsButtonsView;
    void(^tabButtonClickBlock)(JRButton* button) = ^void(JRButton* selectedButton) {
        // Effect , get previousIndex , selectedIndex
        int previousIndex = 0;
        for (JRButton* jrButton in weakTabJsonView.subviews){
            if (jrButton.selected) previousIndex = [tabs indexOfObject: jrButton];
            jrButton.selected = NO;
        }
        selectedButton.selected = YES;
        int selectedIndex = [tabs indexOfObject: selectedButton];
        
        // Disable Next/Pervious Page Function
        if (selectedIndex == 0) {
            ((JRButton*)[jsonTabController.jsonView getView:json_BTN_PriorPage]).enabled = YES;
            ((JRButton*)[jsonTabController.jsonView getView: json_BTN_NextPage]).enabled = YES;
        } else {
            ((JRButton*)[jsonTabController.jsonView getView:json_BTN_PriorPage]).enabled = NO;
            ((JRButton*)[jsonTabController.jsonView getView: json_BTN_NextPage]).enabled = NO;
        }
        
        // Animations
        int offset = previousIndex - selectedIndex;
        [self tabAnimation: jsonTabController offset:offset index:selectedIndex];
        
    };
    
    // add buttons block action
    [ViewHelper iterateSubView:tabsButtonsView class:[JRButton class] handler:^BOOL(id subView) {
        ((JRButton*)subView).didClikcButtonAction = tabButtonClickBlock;
        return NO;
    }];
    
}
+(void) swipTabs: (UISwipeGestureRecognizer*)swipGesture
{
    UIView* view = swipGesture.view;
    JsonView* jsonView = [JsonViewHelper getJsonViewBySubview: view];
    if (! jsonView) return;
    
    
    // get the current index
    JsonDivView* tabsJsonDivView = (JsonDivView*)[jsonView getView:json_NESTED_TABS];
    NSArray* tabs = [tabsJsonDivView subviews];
    int previousIndex = 0;
    for (JRButton* jrButton in tabsJsonDivView.subviews){
        if (jrButton.selected) previousIndex = [tabs indexOfObject: jrButton];
    }
    
    // swip left or right, Then trigger the click Event
    int goToIndex = 0;
    if (swipGesture.direction == UISwipeGestureRecognizerDirectionRight) {
        goToIndex = previousIndex - 1;
        if (goToIndex >= 0) {
            JRButton* selectedButton = [tabs objectAtIndex:goToIndex];
            selectedButton.didClikcButtonAction(selectedButton);
        }
        
    } else if (swipGesture.direction == UISwipeGestureRecognizerDirectionLeft) {
        goToIndex = previousIndex + 1;
        if (goToIndex < tabs.count) {
            JRButton* selectedButton = [tabs objectAtIndex:goToIndex];
            selectedButton.didClikcButtonAction(selectedButton);
        }
    }
}
+(void) tabAnimation: (JsonTabController*)jsonTabController offset:(int)offset index:(int)index
{
    // Animations
    [UIView animateWithDuration: 0.3 animations:^{
        [jsonTabController.scrollDivView addOriginX: [[UIScreen mainScreen] bounds].size.height * offset];
    } completion:^(BOOL finished) {
        if (jsonTabController.didShowTabView) jsonTabController.didShowTabView(index, [jsonTabController.scrollDivView.subviews objectAtIndex:index]);
    }];
}

@end
