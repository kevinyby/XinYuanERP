#import <Foundation/Foundation.h>

@interface ModelsStructure : NSObject

@property (strong, readonly) NSMutableDictionary* categoryModels;

-(void) renderModels: (NSDictionary*)dictionary ;

-(NSArray*) getAllCategories ;
-(NSString*) getCategory: (NSString*)orderType;

-(NSMutableDictionary*) getAllOders:(BOOL)withBill ;
-(NSArray*) getOrders: (NSString*)deparment withBill:(BOOL)withBill;

-(NSMutableDictionary*) getModelStructure: (NSString*)order ;
-(NSMutableDictionary*) getModelsStructures: (NSString*)deparment ;


#pragma mark -

-(NSDictionary*) getInsertModelsDefine;
-(void) removeInsertModelsIn: (NSMutableArray*)models;

#pragma mark -

-(NSArray*) getModelApprovals: (NSString*)orderType;


@end
