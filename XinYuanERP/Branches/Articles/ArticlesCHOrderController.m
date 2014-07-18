//
//  ArticlesCHOrderController.m
//  XinYuanERP
//
//  Created by Xinyuan4 on 14-4-21.
//  Copyright (c) 2014年 Xinyuan4. All rights reserved.
//

#import "ArticlesCHOrderController.h"
#import "AppInterface.h"

#define updateTimerSec 120

@interface ArticlesCHOrderController ()
{
    JRTextField* _titleNew;
    JRTextField* _titleOld;
    
    JRTextScrollView* _textScrollViewNew;
    JRTextScrollView* _textScrollViewOld;
    
    NSTimer *_updateTimer;
}

@end

@implementation ArticlesCHOrderController

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
    
    JsonView* jsonView = self.jsonView;
    
    __block ArticlesCHOrderController* blockSelf = self;
    
    _textScrollViewOld = (JRTextScrollView*)[jsonView getView:@"articles_O"];
    _textScrollViewOld.textView.editable = NO;
    _textScrollViewOld.textView.placeholder = LOCALIZE_DESCRIPTION(@"ArticlesCHOrder.oldArticleTip");
    
    _textScrollViewNew = (JRTextScrollView*)[jsonView getView:@"articles_N"];
    _textScrollViewNew.textView.placeholder = LOCALIZE_DESCRIPTION(@"ArticlesCHOrder.newArticleTip");
    
    _titleNew = (JRTextField*)[jsonView getView:@"title_N"];
    _titleNew.placeholder = LOCALIZE_DESCRIPTION(@"ArticlesCHOrder.newTitleTip");
    _titleNew.textAlignment = NSTextAlignmentCenter;
    
    JsonDivView* bodyDivView = (JsonDivView*)[jsonView getView:@"NESTED"];
    _titleOld = (JRTextField*)[jsonView getView:@"title_O"];
    _titleOld.placeholder = LOCALIZE_DESCRIPTION(@"ArticlesCHOrder.oldTitleTip");
    _titleOld.textAlignment = NSTextAlignmentCenter;
    _titleOld.textFieldDidClickAction = ^void(JRTextField* sender) {
          NSArray* needFields = @[@"title"];
          PickerModelTableView* pickView = [PickerModelTableView popupWithRequestModel:@"ArticlesOrder" fields:needFields willDimissBlock:nil];
          pickView.titleHeaderViewDidSelectAction = ^void(JRTitleHeaderTableView* headerTableView, NSIndexPath* indexPath){
              FilterTableView* filterTableView = (FilterTableView*)headerTableView.tableView.tableView;
              NSIndexPath* realIndexPath = [filterTableView getRealIndexPathInFilterMode: indexPath];
              
               blockSelf-> _textScrollViewNew.textStorage.editTextStatus = YES;
              [blockSelf->_textScrollViewOld.textView.placeHolderLabel setHidden:YES];
              [blockSelf->_textScrollViewNew.textView.placeHolderLabel setHidden:YES];
              
              id idetification = [[filterTableView realContentForIndexPath: realIndexPath] firstObject];
              NSDictionary* objects = @{PROPERTY_IDENTIFIER: idetification};
              
              [VIEW.progress show];
              [AppServerRequester readModel:@"ArticlesOrder" department: @"Articles" objects:objects completeHandler:^(ResponseJsonModel *data, NSError *error) {
                  NSArray* objects = data.results;
                  NSDictionary* orderObject = [[objects firstObject] firstObject];
                  NSMutableDictionary* model = [Utility changeKeys:orderObject exceptkeys:@[@"id"] tails:@[@"_N",@"_O"]];
             
                  [bodyDivView setModel: model];
                  [VIEW.progress hide];
                  
              }];
              
              [PickerModelTableView dismiss];
        };
    };
    
    [self controlModeSetting];
    
}

-(void)controlModeSetting
{
    if (self.controlMode == JsonControllerModeCreate)
    {
        
        NSArray* fetchedObjects = [ArticlesObjectHelper fetchManagedObject:DATA.signedUserName];
        if (fetchedObjects != nil && [fetchedObjects count] != 0) {
            Articles* articlesObject = (Articles*)[fetchedObjects firstObject];
            _textScrollViewNew.textView.text = articlesObject.articles;
            _titleNew.text = articlesObject.title;
            _textScrollViewNew.textView.placeholder = @"";
            [_textScrollViewNew.textView.placeHolderLabel setHidden:YES];
            
        }
        
        if (!_updateTimer) {
            _updateTimer = [NSTimer timerWithTimeInterval:updateTimerSec target:self selector:@selector(updateObjectToCache) userInfo:nil repeats:YES];
            [[NSRunLoop currentRunLoop]addTimer:_updateTimer forMode:NSRunLoopCommonModes];
            
        }
        
    }
    
    if (self.controlMode == JsonControllerModeRead)
    {
        _textScrollViewNew.textStorage.regExp = YES;
        _textScrollViewNew.textStorage.editTextStatus = YES;
    }
    
}

-(void)updateObjectToCache
{
    NSLog(@"---updateObjectToCache---");
    if (isEmptyString(_titleNew.text) && isEmptyString(_textScrollViewNew.textView.text)) {
        return;
    }
    NSDictionary* dic = @{@"title":_titleNew.text,
                          @"articles":_textScrollViewNew.textView.text,
                          @"editor":DATA.signedUserName};
    [ArticlesObjectHelper updateManagedObject:dic];
}


#pragma mark -
#pragma mark - Request
-(NSMutableDictionary*) assembleSendObjects: (NSString*)divViewKey
{
    NSMutableDictionary* objects = [super assembleSendObjects: divViewKey];
    if (self.controlMode == JsonControllerModeCreate) {
         [objects setObject: [_textScrollViewNew.textStorage string] forKey:@"articles_N"];
    }else{
        
        [objects setObject: [_textScrollViewNew setRegExpTag] forKey:@"articles_N"];
    }
    return objects;
}

-(void) didSuccessSendObjects: (NSMutableDictionary*)objects response:(ResponseJsonModel*)response
{
    [super didSuccessSendObjects: objects response:response];
    // delete cache
    [ArticlesObjectHelper deleteManagedObject:DATA.signedUserName];
    
}

#pragma mark -
#pragma mark - Response
- (void) translateReceiveObjects: (NSMutableDictionary*)objects
{
    [super translateReceiveObjects:objects];
    
    NSString* articlesString = [objects objectForKey:@"articles_N"];
    [objects setObject:[_textScrollViewNew filterRegExpTag:articlesString] forKey:@"articles_N"];
    
    
}

-(void) renderWithReceiveObjects: (NSMutableDictionary*)objects
{
    [super renderWithReceiveObjects:objects];
    if (!isEmptyString([objects objectForKey:@"articles_N"]))
        [_textScrollViewNew.textView.placeHolderLabel setHidden:YES];
    if (!isEmptyString([objects objectForKey:@"articles_O"]))
        [_textScrollViewOld.textView.placeHolderLabel setHidden:YES];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[IQKeyboardManager sharedManager] setEnable:NO];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[IQKeyboardManager sharedManager] setEnable:YES];
    [_updateTimer invalidate];
    _updateTimer = nil;
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
