#import "JsonView.h"
#import "ClassesInterface.h"

@implementation JsonView

#pragma mark - JRTopViewProtocal Methods

-(id) getModel {
    return [JsonModelHelper getModel: self.contentView];
}

-(void) setModel: (id)model {
    [JsonModelHelper setModel:self.contentView model:model];
}

-(void) clearModel {
    [JsonModelHelper clearModel: self.contentView];
}

-(UIView*) getView: (NSString*)key
{
    return [JsonViewIterateHelper getViewWithKeyPath: key on:self.contentView];
}

// Super Class has been conform somehow
//-(UIView*) contentView
//{
//    return super.contentView;
//}

@end
