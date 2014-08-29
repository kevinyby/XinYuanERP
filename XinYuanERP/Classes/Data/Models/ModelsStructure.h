#import <Foundation/Foundation.h>

@interface ModelsStructure : NSObject

-(void) renderModels: (NSDictionary*)dictionary ;

-(NSArray*) getAllCategories ;
-(NSString*) getCategory: (NSString*)orderType;

-(NSMutableDictionary*) getAllOders:(BOOL)withBill ;
-(NSArray*) getOrders: (NSString*)deparment withBill:(BOOL)withBill;


-(NSArray*) getModelProperties: (NSString*)orderType;
-(NSMutableDictionary*) getModelStructure: (NSString*)orderType ;


#pragma mark -

-(NSDictionary*) getInsertModelsDefine;
-(void) removeInsertModelsIn: (NSMutableArray*)models;

#pragma mark -

-(NSArray*) getModelApprovals: (NSString*)orderType;


@end
