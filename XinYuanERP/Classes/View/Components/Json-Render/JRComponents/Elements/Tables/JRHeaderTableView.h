#import "AppHeaderTableView.h"
#import "JRViewProtocal.h"

typedef enum EDIT_MODE{
    Insertion = 0,
    Remove = 1,
    Reorder = 2
}EditMode;

@protocol JRHeaderTableContentDelegate <NSObject>
/**
 *  called when flat content been setted/modified
 *
 *  @param value new value
 *
 *  @return custom value
 */
-(id) didSetFlatContent:(NSString*)value atIndex:(NSUInteger)index;
/**
 *  called when inner content been setted/modified
 *  @param value new value
 *
 *  @return cutsom value
 */
-(id)didSetInnerContent:(NSString*)value atIndex:(NSUInteger)index;

@end

@interface JRHeaderTableView : UIView <JRComponentProtocal>{
    NSMutableArray* _flatContent;
    NSMutableArray* _innerContent;
}


@property (strong) UIView* headerView;
@property (strong) AlignTableView* tableView;


@property (nonatomic, strong) NSArray* headers;            //here one dimension
@property (nonatomic, strong) NSArray* headersXcoordinates;//here one dimension
@property (nonatomic, strong) NSArray* valuesXcoordinates; //here one dimension

@property (strong) NSMutableArray* flatContent;
@property (strong) NSMutableArray* innerContent;

@property (strong) id<JRHeaderTableContentDelegate> contentDelegate;


-(void) setEditing:(BOOL)editing animated:(BOOL)animated;

@end
