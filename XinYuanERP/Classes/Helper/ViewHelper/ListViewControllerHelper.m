#import "ListViewControllerHelper.h"
#import "AppInterface.h"

@implementation ListViewControllerHelper


#pragma mark - Temp
// array with dic
+(NSMutableArray*) assemble:(NSArray*)array keys:(NSArray*)keys
{
    NSMutableArray* result = [NSMutableArray array];
    for(NSInteger i = 0 ; i < array.count ; i++) {
        NSDictionary* contents = array[i];
        [result addObject:[self assembleDictionary: contents keys:keys]];
    }
    return result;
}

+(NSMutableArray*) assembleDictionary:(NSDictionary*)contents keys:(NSArray*)keys
{
    NSMutableArray* array = [NSMutableArray arrayWithCapacity: keys.count];
    for (NSInteger i = 0; i < keys.count; i++) {
        NSString* key = keys[i];
        id value = contents[key];
        value = value ? value : @"";
        [array addObject: value];
    }
    return array;
}

/**
* Convention:
*          index 0 is the identifier . So , when you send the fieds to get , make sure id at the 0 index of the field ,
*          
*          then the rest should be the show out in the table list contents .
*              
*          if you want to some fields not show on the list , extend it to another method .
*
*/

/**
*      realContentsDictionary is the real data , the data not show on the view
*
*      handle the situation that the need of data show on view not synchronize to the data
*
*      @return The contentDictionary show to on the cell labels without delimiter ","
*/

+(void) assembleTableContents: (TableViewBase*)tableViewObj objects:(NSArray*)objects keys:(NSArray*)keys filter:(ContentFilterBlock)filter
{
    NSMutableDictionary* realContentsDictionary = [TableContentHelper assembleToRealContentDictionary: objects keys:keys];
    tableViewObj.realContentsDictionary = realContentsDictionary;
    NSMutableDictionary* contentsDictionary = [ListViewControllerHelper convertRealToVisualContents: realContentsDictionary filter:filter];
    tableViewObj.contentsDictionary = contentsDictionary;
}



+(NSMutableDictionary*) convertRealToVisualContents: (NSDictionary*)realContentsDictionary filter:(ContentFilterBlock)filter
{
    return [TableContentHelper iterateContentsToCell: realContentsDictionary handler:^(int index, int innerCount, int outterCount, NSString* section, id obj, NSMutableArray *cellRep) {
        
        if (obj == [NSNull null]) {
            obj = EMPTY_STRING;
        }
        if (filter) {
            filter(index, innerCount, outterCount, section, obj, cellRep);
        }
    }];
}











#pragma mark - Exception Icon

+(void) setupExceptionAttributes: (OrderSearchListViewController*)listController order:(NSString*)order
{
    BOOL isHaveExceptionCloumn = [[DATA.modelsStructure getModelStructure: order] objectForKey: PROPERTY_EXCEPTION] != nil;
    if (isHaveExceptionCloumn) {
        
        RequestJsonModel* requestModel = listController.requestModel;
        NSUInteger exceptionIndex = [ListViewControllerHelper modifyRequestFields: requestModel order:order];
        if (exceptionIndex != NSNotFound) {
            ContentFilterBlock previousFilter = listController.contentsFilter;
            listController.contentsFilter = [ListViewControllerHelper getExceptionContentFilter:previousFilter order:order exceptionIndex:exceptionIndex];
            
            WillShowCellBlock previousWillShow = listController.willShowCellBlock;
            listController.willShowCellBlock = [ListViewControllerHelper getExceptionWillShowCellBlock:previousWillShow exceptionIndex:exceptionIndex];
        }
    }
}

// 1 . request fields
+(NSUInteger) modifyRequestFields: (RequestJsonModel*)requestModel order:(NSString*)order
{
    NSString* _dotOrder = DOT_MODEL(order);
    NSUInteger index = [requestModel.models indexOfObject: _dotOrder];
    if (index != NSNotFound) {
        NSArray* modelFields = [requestModel.fields objectAtIndex:index];
        NSMutableArray* newModelFields = [NSMutableArray arrayWithArray: modelFields];
        
        [newModelFields addObject: PROPERTY_EXCEPTION];        // the last one
        NSUInteger exceptionIndex = [newModelFields indexOfObject:PROPERTY_EXCEPTION];
        
        [requestModel.fields replaceObjectAtIndex:index withObject:newModelFields];
        
        return exceptionIndex;
    }
    return NSNotFound;
}


// 2 . content filter block
+(ContentFilterBlock) getExceptionContentFilter: (ContentFilterBlock)previousFilter order:(NSString*)order exceptionIndex:(NSUInteger)exceptionIndex
{
    return ^void(int elementIndex , int innerCount, int outterCount, NSString* section, id cellElement, NSMutableArray* cellRepository){
        
        // if have previous
        if (previousFilter) {
            previousFilter(elementIndex, innerCount, outterCount, section, cellElement, cellRepository); // call super  ...
        } else {
            if (cellElement) {
                [cellRepository addObject: cellElement];
            }
        }
        
        // filter the exception column
        if ([section isEqualToString: DOT_MODEL(order)]) {
            if (elementIndex == exceptionIndex) {
                if([cellRepository containsObject: cellElement]) {
                    if ([cellRepository lastObject] == cellElement) {
                        [cellRepository removeLastObject];
                    }
                }
            }
        }
        
        
    };
}

// 3 . will show cell block
+(WillShowCellBlock) getExceptionWillShowCellBlock: (WillShowCellBlock)previousWillShow exceptionIndex:(NSUInteger)exceptionIndex
{
    return ^void(AppSearchTableViewController* controller ,NSIndexPath* indexPath, UITableViewCell* cell) {
        
        if (previousWillShow){
           previousWillShow(controller, indexPath, cell);    // call pervious  ...
        }
        
        NSArray* values = [controller valueForIndexPath: indexPath];
        NSNumber* exception = [values safeObjectAtIndex: exceptionIndex];
        BOOL isException = [exception boolValue];
        
        // show image
        UIImageView* imageView = [ListViewControllerHelper getImageViewInCellTail: @"Stafftransactiontable_04H" cell:cell];
        imageView.hidden = !isException;
    };
    
}

// 4 . the image icon
+(UIImageView*) getImageViewInCellTail: (NSString*)imageName cell:(UITableViewCell*)cell
{
    return [self getImageViewInCell: cell imageName:imageName centerX:-1 tag:68055];
}


+(UIImageView*) getImageViewInCell: (UITableViewCell*)cell imageName:(NSString*)imageName centerX:(CGFloat)centerX tag:(NSInteger)tag
{
    UIImageView* imageView = (UIImageView*)[cell.contentView viewWithTag: tag];
    if (!imageView) {
        UIImage* image = [UIImage imageNamed:imageName];
        imageView = [[UIImageView alloc] initWithImage: image];
        imageView.tag = tag;
        [cell.contentView addSubview: imageView];
        
        // size
        [imageView setSize: [FrameTranslater convertCanvasSize: image.size]];
        
        
        // caculate position
        // -1 for tail , 1 for head
        if (centerX == -1) {
            centerX = cell.sizeWidth - imageView.sizeWidth;
        } else if (centerX == 1) {
            centerX = 0 + imageView.sizeWidth;
        }
        
        // set positioin
        [imageView setCenterY: cell.sizeHeight/2];
        [imageView setCenterX: centerX];
        
    }
    return imageView;
}


@end
