
/* 
 * 保存数据缓存
 */

#import <Foundation/Foundation.h>

@interface KCSaveData : NSObject{
    
    NSString			*_fileAbsolutePath;
	NSMutableDictionary *_rootDic;
}



-(id)initWithFileName:(NSString*)aName;

-(BOOL)saveString:(NSString*)aString forKey:(NSString*)aKey;
-(NSString*)getString:(NSString*)aKey;

-(BOOL)saveInt:(NSInteger)aInt forKey:(NSString*)aKey;
-(NSInteger)getInt:(NSString*)aKey;

-(BOOL)saveBOOL:(BOOL)aBOOL forKey:(NSString*)aKey;
-(BOOL)getBOOL:(NSString*)aKey;

-(BOOL)saveDictionary:(NSDictionary*)aDic forKey:(NSString*)aKey;
-(NSDictionary*)getDictionary:(NSString*)aKey;


@end


