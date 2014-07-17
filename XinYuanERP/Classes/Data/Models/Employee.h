#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Employee : NSManagedObject

@property (nonatomic, retain) NSString * employeeNO;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * department;
@property (nonatomic, retain) NSString * subDepartment;
@property (nonatomic, retain) NSString * jobTitle;
@property (nonatomic) int16_t jobLevel;
@property (nonatomic, retain) NSString * phoneNO;

@end
