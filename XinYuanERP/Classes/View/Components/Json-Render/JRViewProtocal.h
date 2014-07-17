#import <Foundation/Foundation.h>



// all views/components
@protocol JRViewProtocal <NSObject>

@required
-(NSString*) attribute;
-(void) setAttribute: (NSString*)attribute;

@end




// top views : JsonView/JsonDivView
@protocol JRTopViewProtocal <JRViewProtocal>

@required
-(NSDictionary*) specifications;
-(void) setSpecifications: (NSDictionary*)specifications;

-(id) getModel;
-(void) setModel: (id)model ;
-(void) clearModel;

-(UIView*) contentView;
-(UIView*) getView: (NSString*)key ;

@end




// components
@protocol JRComponentProtocal <JRViewProtocal>

@required
-(void) initializeComponents: (NSDictionary*)config;
-(void) subRender: (NSDictionary*)dictionary ;

-(id) getValue;
-(void) setValue: (id)value ;

@end




