
#import "KCSaveData.h"

@implementation KCSaveData

-(id)initWithFileName:(NSString*)aName{
	if (self=[super init]) {
		
		_fileAbsolutePath = [[NSString alloc] initWithString:[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]
															  stringByAppendingPathComponent:aName]];
		if (![[NSFileManager defaultManager] fileExistsAtPath:_fileAbsolutePath]) {
			_rootDic = [[NSMutableDictionary alloc] init];
		}else {
			_rootDic = [[NSMutableDictionary alloc] initWithContentsOfFile:_fileAbsolutePath];
		}
	}
	return self;
}


#pragma mark -
#pragma mark NSString
-(BOOL)saveString:(NSString*)aString
		   forKey:(NSString*)aKey{
	if (nil==aString) {
		return NO;
	}
    
    NSString *aStringTemp = [[NSString alloc] initWithString:aString];
	[_rootDic setObject:aStringTemp forKey:aKey];
	return [_rootDic writeToFile:_fileAbsolutePath atomically:YES];
}
-(NSString*)getString:(NSString*)aKey{
    if (nil==[_rootDic objectForKey:aKey]) {
        return @"";
    }
    NSString *aStringTemp = [[NSString alloc] initWithString:[_rootDic objectForKey:aKey]];
    return aStringTemp;
}


#pragma mark -
#pragma mark NSInteger
-(BOOL)saveInt:(NSInteger)aInt
		forKey:(NSString*)aKey{
	NSString *aIntString = [[NSString alloc] initWithFormat:@"%d",aInt];
    return [self saveString:aIntString forKey:aKey];
}
-(NSInteger)getInt:(NSString*)aKey{
    return [[self getString:aKey] intValue];
}

#pragma mark -
#pragma mark BOOL
-(BOOL)saveBOOL:(BOOL)aBOOL
		 forKey:(NSString*)aKey{
	int bInt = 0;
	if (aBOOL) {
		bInt=1;
	}
	NSString *aIntString = [[NSString alloc] initWithFormat:@"%d",bInt];
    return [self saveString:aIntString forKey:aKey];
}
-(BOOL)getBOOL:(NSString*)aKey{
	NSString *aIntString = [self getString:aKey];
	if (nil==aIntString) {
		return NO;
	}
	if ([aIntString intValue]==0) {
		return NO;
	}else {
		return YES;
	}
}


#pragma mark -
#pragma mark NSDictionary
-(BOOL)saveDictionary:(NSDictionary*)aDic
			   forKey:(NSString*)aKey{
	if (nil==aDic) {
		return NO;
	}
    NSDictionary *aTempDic = [[NSDictionary alloc] initWithDictionary:aDic];
	[_rootDic setObject:aTempDic forKey:aKey];
	return [_rootDic writeToFile:_fileAbsolutePath atomically:YES];
}
-(NSDictionary*)getDictionary:(NSString*)aKey{
    
    if (nil==[_rootDic objectForKey:aKey]) {
        return nil;
    }
    NSDictionary *aTempDic = [[NSDictionary alloc] initWithDictionary:[_rootDic objectForKey:aKey]];
	return aTempDic;
}

@end




