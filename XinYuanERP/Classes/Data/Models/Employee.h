#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Employee : NSManagedObject

@property (nonatomic, retain) NSString * employeeNO;
@property (nonatomic, retain) NSString * name;
@property (nonatomic) int16_t jobLevel;

@end
