#import <Foundation/Foundation.h>


#define list_FILTER_NIL                     @"FILTER_NIL"
#define list_FILTER_NumberName              @"FILTER_NumberName"
#define list_FILTER_Date                    @"FILTER_Date"
#define list_FILTER_Localize                @"FILTER_Localize"
#define list_FILTER_LocalizeUpperCase        @"FILTER_LocalizeUpperCase"



typedef void(^ContentFilterBlock) (int elementIndex , int innerCount, int outterCount, NSString* section, id cellElement, NSMutableArray* cellRepository);

typedef id(^ContentFilterElementBlock) (id cellElement, NSMutableArray* cellRepository);



@interface ContentFilterHelper : NSObject


+(NSDictionary*) contentFiltersMap;


@end
