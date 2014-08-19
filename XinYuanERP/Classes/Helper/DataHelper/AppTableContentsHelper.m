#import "AppTableContentsHelper.h"
#import "ClassesInterface.h"

@implementation AppTableContentsHelper

/**
 *
 *  Insert the value to realContentsDictionary
 *
 */
+(NSMutableArray*) insertValues: (NSMutableDictionary*)realContentsDictionary partRealContentDictionary:(NSDictionary*)partRealContentDictionary isTop:(BOOL)isTop
{
    
    NSMutableArray* insertIndexPaths = [NSMutableArray array];
    NSArray* sortedKeys = [DictionaryHelper getSortedKeys: partRealContentDictionary];
    
    
    for (int j = 0; j < sortedKeys.count; j++) {
        NSString* key = [sortedKeys objectAtIndex: j];
        int section = j ;
        
        NSArray* newSectoinContents = [partRealContentDictionary objectForKey: key];
        NSMutableArray*  sectionContents = [realContentsDictionary objectForKey: key];
        int contentsCount = sectionContents.count;
        if (!sectionContents) {                                                         // no , i don't have one , set the new contents
            [realContentsDictionary setObject: newSectoinContents forKey:key];
            
        } else {                                                                        // yes , i have one , insert the new contents
            if (isTop) {
                [sectionContents insertObjects: newSectoinContents atIndexes:[NSIndexSet indexSetWithIndexesInRange:(NSRange){0,newSectoinContents.count}]];
            } else {
                [sectionContents addObjectsFromArray: newSectoinContents];
            }
            
            if (isTop) {
                for (int i = 0; i < newSectoinContents.count; i++) {
                    [insertIndexPaths addObject:[NSIndexPath indexPathForRow:i inSection:section]];
                }
                
            } else {
                for (int i = 0; i < newSectoinContents.count; i++) {
                    [insertIndexPaths addObject:[NSIndexPath indexPathForRow:contentsCount + i inSection:section]];
                }
            }
            
        }
    }
    
    
    return insertIndexPaths;
}

@end
