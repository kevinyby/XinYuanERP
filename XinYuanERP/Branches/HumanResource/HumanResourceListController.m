#import "HumanResourceListController.h"
#import "AppInterface.h"

@implementation HumanResourceListController

#pragma mark - Overide Super Class Method

-(void) setInstanceVariablesValues
{
    NSString* order = self.order;
    [super setInstanceVariablesValues];
    
    if ([order isEqualToString: MODEL_EMPLOYEE]) {
        self.headerTableView.refreshCompareColumnSortIndex = 1;
        self.contentsFilter = ^void(int elementIndex , int innerCount, int outterCount, NSString* section, id cellElement, NSMutableArray* cellRepository) {
            
            // id , resign
            if (elementIndex == 0 || elementIndex == 5){
                return ;
                
                // pendingApprovals
                // the last one , note that , in setExceptionAttributes add "exception" column/field
            } else if(elementIndex == innerCount - 1) {
                if ([cellElement intValue] == 0) {
                    cellElement = EMPTY_STRING;
                }
            }
            
            if (cellElement) {
                [cellRepository addObject: cellElement];
            }
            
        };
        
    }
}


-(void) setExceptionAttributes
{
    NSString* order = self.order;
    if ([order isEqualToString: MODEL_EMPLOYEE]) {
        
        BOOL isHaveExceptionCloumn = [[DATA.modelsStructure getModelProperties: order] containsObject: PROPERTY_EXCEPTION];
        
        if (isHaveExceptionCloumn) {
            RequestJsonModel* requestModel = self.requestModel;
            NSString* model = @"HumanResource.Employee";
            NSUInteger exceptionIndex = [ListViewControllerHelper modifyRequestFields: requestModel order:model];
            if (exceptionIndex != NSNotFound) {
                ContentFilterBlock previousFilter = self.contentsFilter;
                self.contentsFilter = [ListViewControllerHelper getExceptionContentFilter:previousFilter order:model exceptionIndex:exceptionIndex];
                
                WillShowCellBlock previousWillShow = self.willShowCellBlock;
                WillShowCellBlock withExceptionWillShow = [ListViewControllerHelper getExceptionWillShowCellBlock:previousWillShow exceptionIndex:exceptionIndex];
                WillShowCellBlock wihtResignedWillShow = ^void(AppSearchTableViewController* controller ,NSIndexPath* indexPath, UITableViewCell* cell) {
                    if (withExceptionWillShow) {
                        withExceptionWillShow(controller, indexPath, cell);
                    }
                    
                    // handle the resign
                    NSArray* values = [controller valueForIndexPath: indexPath];
                    int resignIndex = [[self.requestModel.fields firstObject] indexOfObject:@"resign"];
                    BOOL isResign = [[values safeObjectAtIndex: resignIndex] boolValue];
                    CGFloat centerX = [FrameTranslater convertCanvasWidth: [[controller.valuesXcoordinates safeObjectAtIndex: resignIndex] floatValue] + 10 ];
                    UIImageView* iamgeView = [ListViewControllerHelper getImageViewInCell:cell imageName:@"cb_green_on.png" centerX: centerX tag:20003];
                    iamgeView.hidden = !isResign;
                };
                
                self.willShowCellBlock = wihtResignedWillShow;
                
            }
        }
    } else {
        
        [super setExceptionAttributes];
    }
}


// temp code . to be ..... in server, add pending count column
-(void) setHeadersSortActions
{
    NSString* order = self.order;
    if ([order isEqualToString: MODEL_EMPLOYEE]) {
        [JsonBranchHelper iterateHeaderJRLabel:self handler:^BOOL(JRLocalizeLabel *label, int index, NSString *attribute) {
            label.jrLocalizeLabelDidClickAction = ^void(JRLocalizeLabel* label) {
                
                NSString* attribute = label.attribute;
                NSMutableArray* outterSorts = self.requestModel.sorts;
                
                
                
                // if click 'pendingApprovalsCount'
                if ([attribute rangeOfString: @"pendingApprovalsCount"].location != NSNotFound) {
                    
                    NSString* secondString = [[outterSorts firstObject] safeObjectAtIndex: 1];
        
                    if ([secondString rangeOfString: @"pendingApprovalsCount"].location == NSNotFound) {
                        secondString = [@"Approvals.pendingApprovalsCount" stringByAppendingFormat:@".%@", SORT_ASC];
                    }
                    NSString* newSortString = [JsonBranchHelper reverseSortString: secondString];
                    
                    [self insertOrReplaceInSortsInEmployee: outterSorts newSortString:newSortString];
                }
                
                else {
                    
                    NSMutableArray* firstInnerSorts = [outterSorts firstObject];
                    
                    // if click 'resign'
                    if ([attribute rangeOfString: @"resign"].location != NSNotFound) {
                        NSString* resignSorting =  [firstInnerSorts firstObject];
                        NSString* newSortString = [JsonBranchHelper reverseSortString: resignSorting];
                        [firstInnerSorts replaceObjectAtIndex: 0 withObject: newSortString];
                    }
                    
                    else
                        
                    {
                        
                        
                        
                        // if clikc 'employeeNO'
                        if ([attribute rangeOfString: @"employeeNO"].location != NSNotFound) {
                            NSString* employeeSortString = @"employeeNO.ASC";   // default
                            int employeeStortIndex = 1;                         // default
                            
                            // get if already in sort fields
                            for (int i = 0; i < firstInnerSorts.count; i++) {
                                NSString* string = firstInnerSorts[i];
                                if ([string rangeOfString: @"employeeNO"].location != NSNotFound) {
                                    employeeSortString = string;
                                    employeeStortIndex = i;
                                    break;
                                }
                            }
                            employeeSortString = [JsonBranchHelper reverseSortString: employeeSortString];
                            [firstInnerSorts replaceObjectAtIndex: employeeStortIndex withObject:employeeSortString];
                            [firstInnerSorts exchangeObjectAtIndex: 1 withObjectAtIndex:employeeStortIndex];
                            
                        }
                        
                        else {
                            NSString* secondString = [[outterSorts firstObject] safeObjectAtIndex: 1];
                            
                            NSString* newSortString = nil;
                            if ([secondString rangeOfString: attribute].location != NSNotFound) {
                                newSortString = [JsonBranchHelper reverseSortString: secondString];
                            } else {
                                newSortString = [attribute stringByAppendingFormat:@".%@", SORT_ASC];
                            }
                            
                            
                            if (
                                [newSortString rangeOfString: @"name"].location != NSNotFound ||
                                [newSortString rangeOfString: @"department"].location != NSNotFound ||
                                [newSortString rangeOfString: @"jobTitle"].location != NSNotFound
                                )
                            {
                                if ([newSortString rangeOfString: @"GBK"].location == NSNotFound) {
                                    newSortString = [newSortString stringByAppendingString: @":GBK"];
                                }
                            }
                            
                            
                            [self insertOrReplaceInSortsInEmployee: outterSorts newSortString:newSortString];
                        }
                    }
                }
                
                
                
                [self requestForDataFromServer];
                
            };
            return NO;
        }];
        
    } else {
        
        [super setHeadersSortActions];
    }
}


-(void) insertOrReplaceInSortsInEmployee: (NSMutableArray*)outterSorts newSortString:(NSString*)newSortString
{
    // set in firstInnerSorts
    NSString* secondString = [[outterSorts firstObject] safeObjectAtIndex: 1];
    NSMutableArray* firstInnerSorts = [outterSorts firstObject];
    
    if ([secondString rangeOfString: @"employeeNO"].location != NSNotFound) {
        [firstInnerSorts insertObject: newSortString atIndex:1];
    } else {
        [firstInnerSorts replaceObjectAtIndex: 1 withObject:newSortString];
    }
}

@end
