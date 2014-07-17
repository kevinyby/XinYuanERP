#import <Foundation/Foundation.h>
#import "CSVFileWriter.h"

@interface AppCSVFileWriter : CSVFileWriter

+(void) writeModels: (NSArray*)array model:(NSString*)model department:(NSString*)department ;

+(void) writeModels: (NSArray*)array headerFields:(NSArray*)headerFields model:(NSString*)model department:(NSString*)department ;

+(void) writeModels: (NSArray*)array headerFields:(NSArray*)headerFields append:(BOOL)append model:(NSString*)model department:(NSString*)department ;

+(void) writeModel: (NSDictionary*)dictionary model:(NSString *)model department:(NSString *)department ;

/** FullPath with file name */
+(NSString*) getCSVSaveFullPath: (NSString*)model department:(NSString*)department orderNO:(NSString*)orderNO ;
/** Relative with file name */
+(NSString*) getCSVSaveRelativePath: (NSString*)model department:(NSString*)department orderNO:(NSString*)orderNO ;

@end
