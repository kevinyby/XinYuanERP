#import "JsonDivView.h"
#import "JRComponents.h"

@implementation JsonDivView

#pragma mark - JRTopViewProtocal Methods

-(id) getModel {
    return [JsonModelHelper getModel: self.contentView];
}

-(void) setModel: (id)model {
    [JsonModelHelper setModel:self.contentView model:model];
}

-(void) clearModel
{
    [JsonModelHelper clearModel: self.contentView];
}

-(UIView*) getView: (NSString*)key
{
    return [JsonViewIterateHelper getViewWithKeyPath: key on:self];
}

-(UIView*) contentView
{
    return self;
}

@end
