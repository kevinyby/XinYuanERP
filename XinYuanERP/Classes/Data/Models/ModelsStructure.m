#import "ModelsStructure.h"
#import "AppInterface.h"

@implementation ModelsStructure

-(void) renderModels: (NSDictionary*)dictionary {
    NSError* error = nil ;
    _categoryModels = [[NSMutableDictionary alloc] initWithCapacity: 5];
    
    if (! dictionary || [dictionary count] == 0) {
        
        NSData* data = [NSData dataWithContentsOfFile: [FileManager.documentsPath stringByAppendingPathComponent: ModelsStructurePath ]];
        NSDictionary* dictionary = data ? [NSJSONSerialization JSONObjectWithData: data options:NSJSONReadingAllowFragments error:&error] : nil;
        if (dictionary) [_categoryModels setDictionary: dictionary];
        
        
    } else {
        
        for (NSString* category in dictionary) {                // categories
            
            NSDictionary* categoryDictionary = [dictionary objectForKey: category];
            
            NSMutableDictionary* categotyValues = [NSMutableDictionary dictionary];
            [_categoryModels setObject: categotyValues forKey:category];
            
            for (NSString* order in categoryDictionary) {       // orders
                
                NSArray* properties = [categoryDictionary objectForKey: order];
                
                NSMutableDictionary* orderValues = [NSMutableDictionary dictionary];
                [categotyValues setObject: orderValues forKey:order];
                
                for (NSString* property in properties) {        // properties
                    [orderValues setObject: [NSNull null] forKey:property];
                }
            }
        }
        
        NSData* data = [NSJSONSerialization dataWithJSONObject: _categoryModels options:NSJSONWritingPrettyPrinted error:&error];
        if (data) {
            [FileManager writeDataToFile: [FileManager.documentsPath stringByAppendingPathComponent: ModelsStructurePath ] data:data];
        }
    }
}


// get all categories
-(NSArray*) getAllCategories {
    return [_categoryModels allKeys];
}

/** Get category by order type*/
-(NSString*) getCategory: (NSString*)orderType
{
    NSDictionary* allOrders = [self getAllOders:YES];
    NSString* category = nil;
    for (NSString* departement in allOrders) {
        NSArray* orders = [allOrders objectForKey: departement];
        for (NSString* order in orders)  if ([order isEqualToString: orderType]) {
            if (category) {
                [ACTION alertError: [NSString stringWithFormat:@"Duplicated Order %@ in %@ and %@", orderType, category, departement]];
            }
            category = departement;
        }
    }
    return category;
}

// get the orders names
-(NSMutableDictionary*) getAllOders:(BOOL)withBill {
    NSArray* allDeparments = [self getAllCategories];
    NSMutableDictionary* dictionary = [NSMutableDictionary dictionaryWithCapacity: allDeparments.count];
    for (NSString* key in allDeparments) {
        NSArray* orders = [self getOrders: key withBill:withBill];
        [dictionary setObject: orders forKey:key];
    }
    return dictionary;
}


#define BILL_SUFFIX @"Bill"
// get the order names by specified department
-(NSArray*) getOrders: (NSString*)deparment withBill:(BOOL)withBill
{
    NSArray* allModels = [[_categoryModels objectForKey: deparment] allKeys];
    if (! withBill) {
        NSPredicate* predicate = [NSPredicate predicateWithFormat:@"not (SELF contains[cd] %@)" , BILL_SUFFIX];       // filter the bill
        allModels = [allModels filteredArrayUsingPredicate: predicate];
    }
    return allModels;
}


// get specified department's all orders, return a copy
-(NSMutableDictionary*) getModelsStructures: (NSString*)deparment {
    NSMutableDictionary* result = [_categoryModels objectForKey: deparment];
    NSMutableDictionary* copy = [NSMutableDictionary dictionary];
    [DictionaryHelper deepCopy: result to:copy];
    return copy;
}


// get specified order, return a copy
-(NSMutableDictionary*) getModelStructure: (NSString*)order {
    NSMutableDictionary* result = nil;
    for (NSString* categoryKey in _categoryModels) {
        NSDictionary* outterDictionary = [_categoryModels objectForKey: categoryKey];
        result = [outterDictionary objectForKey: order];
        if (result) break;
    }
    
    NSMutableDictionary* copy = [NSMutableDictionary dictionary];
    [DictionaryHelper deepCopy: result to:copy];
    return copy;
}



#pragma mark -

-(NSDictionary*) getInsertModelsDefine;
{
    NSDictionary* visual = [[JsonFileManager getJsonFromFile: @"ModelsStructureConfig.json"] objectForKey:@"ModelsStructure_Visual"];
    return visual;
}

// ie. EmployeeQuitOrder with EmployeeQuitPassOrder
-(void) removeInsertModelsIn: (NSMutableArray*)models
{
    NSDictionary* visuals = [DATA.modelsStructure getInsertModelsDefine];
    for (NSString* key in visuals) {
        NSArray* array = [visuals objectForKey: key];
        for (int i = 0; i < array.count; i++) {
            NSString* removeInVisualOrder = [array objectAtIndex: i];
            if ([models containsObject:removeInVisualOrder]) [models removeObject: removeInVisualOrder];
        }
    }
}

#pragma mark -

-(NSArray*) getModelApprovals: (NSString*)orderType
{
    NSMutableArray* approvals = [NSMutableArray array];
    NSArray* properties = [[DATA.modelsStructure getModelStructure: orderType] allKeys];
    if ([properties containsObject: levelApp1])  [approvals addObject: levelApp1];
    if ([properties containsObject: levelApp2])  [approvals addObject: levelApp2];
    if ([properties containsObject: levelApp3])  [approvals addObject: levelApp3];
    if ([properties containsObject: levelApp4])  [approvals addObject: levelApp4];
    return approvals;
}



@end
