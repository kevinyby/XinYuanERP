#import "AppDataParserHelper.h"
#import "AppInterface.h"

@implementation AppDataParserHelper


+(NSMutableDictionary*) parseUserPermissions:(NSArray*)permissions {
    NSMutableDictionary* result = [NSMutableDictionary dictionary];
    for (int i = 0; i < permissions.count; i++) {
        NSArray* array = [permissions objectAtIndex: i];
        
        NSString* username = [array objectAtIndex: 0];
        NSString* permissionsJson = [array objectAtIndex: 1];
        NSString* categoriesJson = [array objectAtIndex: 2];
        
        NSDictionary* permission = [CollectionHelper convertJSONStringToJSONObject:permissionsJson];
        NSArray* categories =  [CollectionHelper convertJSONStringToJSONObject:categoriesJson];
        
        NSMutableDictionary* userResult = [NSMutableDictionary dictionary];
        //        permission
        NSMutableDictionary* dic = [NSMutableDictionary dictionary];
        [DictionaryHelper deepCopy:permission to:dic];
        [userResult setObject: dic forKey:PERMISSIONS];
        
        //        categories
        NSMutableArray* arr = [NSMutableArray array];
        [ArrayHelper deepCopy: categories to:arr];
        [userResult setObject: arr forKey:CATEGORIES];
        
        [result setObject: userResult forKey:username];
    }
    return result;
}


/** dictionary contens is array , the object in array, get the key */
+(id) getKeyByObject:(NSDictionary*)dictionary object:(id)object
{
    for (NSString* key in dictionary) {
        NSArray* array = [dictionary objectForKey:key];
        
        if ([array containsObject: object]) return key;
        
        for (id obj in array) {
            if (obj == object) return  key;
            if ([object isKindOfClass: [NSString class]] && [obj isKindOfClass:[NSString class]]) {
                if ([(NSString*)obj isEqualToString: (NSString*)object]) return key;
            }
        }
    }
    return nil;
}

@end
