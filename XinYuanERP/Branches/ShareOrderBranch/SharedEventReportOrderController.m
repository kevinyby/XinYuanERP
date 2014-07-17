//
//  SharedEventReportOrderController.m
//  XinYuanERP
//
//  Created by bravo on 14-1-11.
//  Copyright (c) 2014年 Xinyuan4. All rights reserved.
//

#import "SharedEventReportOrderController.h"
#import "AppInterface.h"
#import "EditableCell.h"

@interface SharedEventReportOrderController ()<UITableViewDelegate,JRHeaderTableContentDelegate,EditCellProtocol>

@end

@implementation SharedEventReportOrderController{
    NSString* contentStr;
    NSString* contentDetail;
    JRHeaderTableView* contentTable;
    EditableCell* currentEditCell;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupTable];
}

-(void) setupTable{
    contentTable = (JRHeaderTableView*)[self.jsonView getView:@"contentTable"];
    currentEditCell = nil;
    if (self.controlMode == JsonControllerModeRead){
        
        //request database to grab content. which should be split by some kind of char
        RequestJsonModel *contentModel = [RequestJsonModel getJsonModel];
        [contentModel addModels:@"SharedEventReportOrder", nil];
        contentModel.path = PATH_LOGIC_READ(CATEGORIE_SHAREDORDER);
        [contentModel.fields addObject:@[@"eventContent",@"eventDetail"]];//grab two fileds at the same time.
        [contentModel.objects addObject:@{@"orderNO":[self.identification stringValue]}];
        [self requestTableFromModel:contentModel toTable:@"contentTable"];

    }
    else if (self.controlMode == JsonControllerModeCreate){
//        [contentTable setEditing:YES animated:NO];
        [self setDataSource:nil ToTable:@"contentTable"];
    }
}

-(NSArray*) requestTableFromModel:(RequestJsonModel*)model toTable:(NSString*)tableName{
    [DATA.requester startPostRequest:model completeHandler:^(HTTPRequester *requester, ResponseJsonModel *model, NSHTTPURLResponse *httpURLReqponse, NSError *error) {
        NSLog(@"gatcha");
        if (!error && ((NSArray*)(NSArray*)model.results[0]).count > 0){
            NSArray* contents = model.results[0][0];
            //getting two string here, first is content, another is detail
            contentStr = [NSString stringWithString:contents[0]];
            contentDetail = [NSString stringWithString:contents[1]];
            
            [self setDataSource:contentStr ToTable:tableName];
        }
        
    }];
    return nil;
}

-(void) setDataSource:(NSString*)data ToTable:(NSString*)name{
//    NSAssert(( data!= nil && (data.length > 0)), @"invalid data source for json table");
    
    JRHeaderTableView* table = (JRHeaderTableView*)[self.jsonView getView:name];
    table.contentDelegate = self;
    //set contents and realContents here
    // mind that we use '|' as sep
    NSMutableArray* newArr = [[NSMutableArray alloc] init];
    if (data){
        NSArray* rawArr = [data componentsSeparatedByString:@"|"];
        [table.innerContent addObjectsFromArray:rawArr];
        
        newArr = [[NSMutableArray alloc] initWithCapacity:rawArr.count];
        for (int i = 0; i<rawArr.count; i++){
            NSString* ele = rawArr[i];
            ele = [NSString stringWithFormat:@"%d. %@",i+1,rawArr[i]];
            [newArr addObject:ele];
        }
    }
    [newArr addObject:@""];
    [table.flatContent addObjectsFromArray:newArr];
    
    table.tableView.delegate = self;
    [table.tableView reloadData];
}

-(NSString*) encodeString:(NSString*)src atIndex:(NSUInteger)index{
    NSString *ps = [NSString stringWithFormat:@"%d. ",index+1];
    NSArray* p = [src componentsSeparatedByString:ps];
    if (p.count > 1)
        return src;
    else{
        NSLog(@"encoding...%@",src);
        return [NSString stringWithFormat:@"%d. %@", index+1,src];
    }
}

-(NSString*) decodeString:(NSString*)src atIndex:(NSUInteger)index{
    NSString *ps = [NSString stringWithFormat:@"%d. ",index+1];
    NSArray* p = [src componentsSeparatedByString:ps];
    if (p.count > 1){
        NSLog(@"decoding...%@",src);
        return [src substringFromIndex:3];
    }
    else
        return src;
}

#pragma mark - JRHeaderTable content delegate
-(id) didSetFlatContent:(NSString *)value atIndex:(NSUInteger)index{
    return [self encodeString:value atIndex:index];
}

-(id) didSetInnerContent:(NSString *)value atIndex:(NSUInteger)index{
    return [self decodeString:value atIndex:index];
}

#pragma mark - UITableView

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (currentEditCell != nil && indexPath.row == currentEditCell.indexPath.row){
        return currentEditCell.input.contentSize.height + 10;
    }
    else return 50.0f;
}

//-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
//    EditableCell* selectedCell = (EditableCell*)[tableView cellForRowAtIndexPath:indexPath];
//    [tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
//    [selectedCell.input sizeToFit];
//    [selectedCell.input becomeFirstResponder];
//}

#pragma mark - self data operation
-(void) insertObject:(NSString *)object inFlatContentAtIndex:(NSUInteger)index{
        object = [self didSetFlatContent:object atIndex:index];
    [contentTable.flatContent insertObject:object atIndex:index];
}

-(void) insertObject:(NSString *)object inInnerContentAtIndex:(NSUInteger)index{
    object = [self didSetInnerContent:object atIndex:index];
    [contentTable.innerContent insertObject:object atIndex:index];
}


#pragma mark - EditCellProtocol

-(void) editCell:(EditableCell *)cell didBeginEditingAtIndexPath:(NSIndexPath *)indexPath{
    currentEditCell = cell;
//    [cell.input sizeToFit];
    [contentTable.tableView beginUpdates];
    [contentTable.tableView endUpdates];
}

-(void) editCell:(EditableCell *)cell didEndEditingAtIndexPath:(NSIndexPath *)indexPath{
    NSString* newValue = [cell getContent];
    if ([newValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length <= 0 ||
        [newValue isEqualToString:contentTable.flatContent[indexPath.row]])return;
    if (indexPath.row == contentTable.flatContent.count -1){
        [self insertObject:newValue inFlatContentAtIndex:indexPath.row];
        [self insertObject:newValue inInnerContentAtIndex:indexPath.row];
        
        [contentTable.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationBottom];
        cell.input.text = @"";
        cell.indexPath = [NSIndexPath indexPathForRow:indexPath.row+1 inSection:0];
        //        cell.input.enabled = YES;
        [cell.input becomeFirstResponder];
        [contentTable.tableView scrollToRowAtIndexPath:cell.indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
    else{
        [contentTable.flatContent removeObjectAtIndex:indexPath.row];
        [self insertObject:newValue inFlatContentAtIndex:indexPath.row];
        
        [contentTable.innerContent removeObjectAtIndex:indexPath.row];
        [self insertObject:newValue inInnerContentAtIndex:indexPath.row];
    }
    
    currentEditCell = nil;
    [contentTable.tableView beginUpdates];
    [contentTable.tableView endUpdates];
    
}

-(void) editCellDidPressReturnOnCell:(EditableCell *)cell{
    
    if (cell.input.text.length <= 0) [cell.input resignFirstResponder];
    NSInteger currentIndex = [contentTable.tableView.visibleCells indexOfObject:cell];
    if (currentIndex !=  NSNotFound){
        EditableCell* nextCell = [contentTable.tableView.visibleCells safeObjectAtIndex: currentIndex + 1];
        if (nextCell){
            //            nextCell.input.enabled =YES;
            [nextCell.input becomeFirstResponder];
            [contentTable.tableView scrollToRowAtIndexPath:cell.indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
            return;
        }
    }
    [self editCell:cell didEndEditingAtIndexPath:cell.indexPath];
}

-(void) adjustHeightForCell:(EditableCell *)cell{
    [contentTable.tableView beginUpdates];
    [contentTable.tableView endUpdates];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


@end
