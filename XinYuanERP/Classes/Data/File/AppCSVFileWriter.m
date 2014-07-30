#import "AppCSVFileWriter.h"
#import "AppInterface.h"

#define CSVModelsDirctory @"CSV/"

#define CSV @"csv"

@implementation AppCSVFileWriter


+(void) writeModels: (NSArray*)array model:(NSString*)model department:(NSString*)department {
    NSArray* headerFields = nil;
    for (NSDictionary* order in array) {
        NSArray* allKeys = [order allKeys];
        headerFields = allKeys.count >= headerFields.count ? allKeys : headerFields;
    }
    [self writeModels: array headerFields:headerFields model:model department:department];
}

/** array contains dictionary , headerFields in the first line , and are the keys of dictionary
 the dictionay's content already localize and transform, i.e. gender 1 for man , 0 for feman  */
+(void) writeModels: (NSArray*)array headerFields:(NSArray*)headerFields model:(NSString*)model department:(NSString*)department {
    [self writeModels:array headerFields:headerFields append:NO model:model department:department];
}
+(void) writeModels: (NSArray*)array headerFields:(NSArray*)headerFields append:(BOOL)append model:(NSString*)model department:(NSString*)department {
    NSString* fullPath = [self getCSVSaveFullPath: model department:department orderNO:nil];
    
    // localize
    NSArray* localizeHeaderFields = [self localizeHeaderFields: headerFields model:model];
    NSArray* localizeContents = [self localizeContents: headerFields array:array];
    // write headers & contents
    [self write: localizeContents to:fullPath headerFields:localizeHeaderFields];
}


+(void) writeModel: (NSDictionary*)dictionary model:(NSString *)model department:(NSString *)department {
    NSString* orderNO = [dictionary objectForKey: PROPERTY_ORDERNO];
    NSString* fullPath = [self getCSVSaveFullPath: model department:department orderNO:orderNO];

    NSArray* headerFields = [dictionary allKeys];

    // localize
    NSArray* localizeHeaderFields = [self localizeHeaderFields: headerFields model:model];
    NSArray* localizeContents = [self localizeContents: headerFields dictionary:dictionary];
    // write headers & contents
    [self write: localizeContents to:fullPath headerFields:localizeHeaderFields];
}


#pragma mark - Util Methods

+(NSString*) getCSVSaveFullPath: (NSString*)model department:(NSString*)department orderNO:(NSString*)orderNO {
    NSString* relativePath = [self getCSVSaveRelativePath:model department:department orderNO:orderNO];
    NSString* fullPath = [[FileManager documentsPath] stringByAppendingPathComponent: relativePath];
    [FileManager createFolderWhileNotExist: fullPath];
    return fullPath;
}

+(NSString*) getCSVSaveRelativePath: (NSString*)model department:(NSString*)department orderNO:(NSString*)orderNO {
    NSString* relativePath = [[CSVModelsDirctory stringByAppendingPathComponent:LOCALIZE_KEY(department)] stringByAppendingPathComponent:LOCALIZE_KEY(model)] ;
    relativePath = orderNO ? [relativePath stringByAppendingPathComponent: orderNO] : relativePath;
    NSString* relativeFileName = [relativePath stringByAppendingPathExtension: CSV];
    return  relativeFileName;
}


#pragma mark - Private Methods

+(NSArray*) localizeHeaderFields: (NSArray*)headerFields model:(NSString*)model {
    int count = headerFields.count;
    NSMutableArray* array = [NSMutableArray arrayWithCapacity: count];
    for (int i = 0; i < count; i++) {
        NSString* field = [headerFields objectAtIndex: i];
        NSString* localizeValue = LOCALIZE_KEY(LOCALIZE_CONNECT_KEYS(model,field));
        [array addObject: localizeValue];
    }
    return array;
}

+(NSArray*) localizeContents: (NSArray*)headerFields array:(NSArray*)array {   // array contains dictionaries
    NSMutableArray* outter = [NSMutableArray array];
    for (int j = 0; j < array.count; j++) {
        NSDictionary* dictionary = [array objectAtIndex: j];
        NSArray* inner = [self localizeContents: headerFields dictionary:dictionary];
        [outter addObject: inner];
    }
    return outter;
}

+(NSArray*) localizeContents: (NSArray*)headerFields dictionary:(NSDictionary*)dictionary {
    NSMutableArray* inner = [NSMutableArray array];
    for (int i = 0; i < headerFields.count; i++) {
        NSString* field = [headerFields objectAtIndex: i];
        id value = [dictionary objectForKey: field];
        
        // translate to localize by field ... like gender 1 for man , 0 for female
        
        value = value ? value : @"";
        [inner addObject: value];
    }
    return inner;
}


@end
