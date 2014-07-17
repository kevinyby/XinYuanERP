#import "AppHeaderTableView.h"
#import "AlignTableView.h"

@implementation AppHeaderTableView

@synthesize headerOriginY;
@synthesize headerOriginX;

@synthesize inset;
@synthesize headerHeight;

-(void) reSetSubviewsConstraints
{
    UIView* headerView = self.headerView;
    UIView* tableView = self.tableView;
    [self removeConstraints: self.constraints];
    
    [self addConstraints:[NSLayoutConstraint
                          constraintsWithVisualFormat:@"|-(headerOriginX)-[headerView]-0-|"
                          options:NSLayoutFormatAlignAllBaseline
                          metrics:@{@"headerOriginX":@(headerOriginX)}
                          views:NSDictionaryOfVariableBindings(headerView)]];
    
    [self addConstraints:[NSLayoutConstraint
                          constraintsWithVisualFormat:@"|-0-[tableView]-0-|"
                          options:NSLayoutFormatDirectionLeadingToTrailing
                          metrics:nil
                          views:NSDictionaryOfVariableBindings(tableView)]];
    
    
    [self addConstraints:[NSLayoutConstraint
                          constraintsWithVisualFormat:@"V:|-(headerOriginY)-[headerView(headerHeight)]"
                          options:NSLayoutFormatDirectionLeadingToTrailing
                          metrics:@{@"headerHeight":@(headerHeight), @"headerOriginY": @(headerOriginY)}
                          views:NSDictionaryOfVariableBindings(headerView)]];
    
    
    [self addConstraints:[NSLayoutConstraint
                          constraintsWithVisualFormat:@"V:[headerView]-(inset)-[tableView]-0-|"
                          options:NSLayoutFormatDirectionLeadingToTrailing
                          metrics:@{@"inset":@(inset)}
                          views:NSDictionaryOfVariableBindings(headerView,tableView)]];
}

@end