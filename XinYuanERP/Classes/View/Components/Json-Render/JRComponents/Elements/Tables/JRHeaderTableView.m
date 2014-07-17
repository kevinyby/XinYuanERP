
#import "JRHeaderTableView.h"
#import "AppInterface.h"
#import "EditableCell.h"

// hotdamn


@interface JRHeaderTableView() <UITableViewDataSource, EditCellProtocol>

@end

@implementation JRHeaderTableView {
    NSString* _attribute ;
    NSMutableArray *allCells;
}

//@dynamic contents;

@synthesize tableView;
@synthesize headerView;

@synthesize headers;
@synthesize valuesXcoordinates;
@synthesize headersXcoordinates;

@synthesize contentDelegate;

- (id)init
{
    self = [super init];
    if (self) {
        
        allCells = [[NSMutableArray alloc] init];
        self.flatContent = [[NSMutableArray alloc] init];
        self.innerContent = [[NSMutableArray alloc] init];
        [self initializeSubviews];
        [self initializeSubviewsHConstraints];
        [self initializeSubviewsVConstraints];
    }
    return self;
}

-(void) initializeSubviews
{
    tableView = [[AlignTableView alloc]   init];
    tableView.dataSource = self;
    //http://stackoverflow.com/questions/14520185/ios-uitableview-displaying-empty-cells-at-the-end
    tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    if ([tableView respondsToSelector:@selector(setSeparatorInset:)]) [tableView setSeparatorInset:UIEdgeInsetsZero];     // ios 7
    
    [tableView registerClass:[EditableCell class] forCellReuseIdentifier:@"EditableCell"];
    
    [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"defaultCell"];
    
    headerView = [[UIView alloc] init];
    
    [self addSubview: headerView];
    [self addSubview: tableView];
    
    headerView.backgroundColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:0.2];
}

-(void) initializeSubviewsHConstraints
{
    [headerView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [tableView setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [self addConstraints:[NSLayoutConstraint
                          constraintsWithVisualFormat:@"|-0-[headerView]-0-|"
                          options:NSLayoutFormatAlignAllBaseline
                          metrics:nil
                          views:NSDictionaryOfVariableBindings(headerView)]];
    
    [self addConstraints:[NSLayoutConstraint
                          constraintsWithVisualFormat:@"|-0-[tableView]-0-|"
                          options:NSLayoutFormatDirectionLeadingToTrailing
                          metrics:nil
                          views:NSDictionaryOfVariableBindings(tableView)]];
}

-(void) initializeSubviewsVConstraints
{
    float headerHeight = [FrameTranslater convertCanvasHeight: 25.0f];
    float inset = [FrameTranslater convertCanvasHeight: 0.0f];
    
    [self addConstraints:[NSLayoutConstraint
                          constraintsWithVisualFormat:@"V:|-0-[headerView(headerHeight)]-(inset)-[tableView]-0-|"
                          options:NSLayoutFormatDirectionLeadingToTrailing
                          metrics:@{@"headerHeight":@(headerHeight),@"inset":@(inset)}
                          views:NSDictionaryOfVariableBindings(headerView,tableView)]];
    
}

-(void)setHeaders:(NSArray *)headersObj
{
    headers = headersObj;
    [AlignTableView setAlignHeaders: nil headerView:headerView headers:headers headersXcoordinates:valuesXcoordinates headersYcoordinates:nil];
}

-(void) setHeadersXcoordinates:(NSArray *)headersXcoordinatesObj
{
    headersXcoordinates = headersXcoordinatesObj;
    [AlignTableView setAlignHeaders: nil headerView:headerView headers:headers headersXcoordinates:headersXcoordinates headersYcoordinates:nil];
}

-(void)setValuesXcoordinates:(NSArray *)valuesXcoordinatesObj
{
    valuesXcoordinates = valuesXcoordinatesObj;
}

#pragma mark - self data operation
-(void) insertObject:(NSString *)object inFlatContentAtIndex:(NSUInteger)index{
    if (self.contentDelegate &&
        [self.contentDelegate respondsToSelector:@selector(didSetFlatContent:atIndex:)]){
        object = [NSString stringWithString: [self.contentDelegate didSetFlatContent:object atIndex:index]];
    }
    [self.flatContent insertObject:object atIndex:index];
}

-(void) insertObject:(NSString *)object inInnerContentAtIndex:(NSUInteger)index{
    if (self.contentDelegate &&
        [self.contentDelegate respondsToSelector:@selector(didSetInnerContent:atIndex:)]){
        object = [NSString stringWithString: [self.contentDelegate didSetInnerContent:object atIndex:index]];
    }
    [self.innerContent insertObject:object atIndex:index];
}

#pragma mark - EditCellProtocol
-(void) editCell:(EditableCell *)cell didEndEditingAtIndexPath:(NSIndexPath *)indexPath{
    NSString* newValue = [cell getContent];
    if ([newValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length <= 0 ||
        [newValue isEqualToString:self.flatContent[indexPath.row]])return;
    if (indexPath.row == self.flatContent.count -1){
        [self insertObject:newValue inFlatContentAtIndex:indexPath.row];
        [self insertObject:newValue inInnerContentAtIndex:indexPath.row];
        
        [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationBottom];
        cell.input.text = @"";
        cell.indexPath = [NSIndexPath indexPathForRow:indexPath.row+1 inSection:0];
//        cell.input.enabled = YES;
        [cell.input becomeFirstResponder];
        [tableView scrollToRowAtIndexPath:cell.indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
    else{
        [self.flatContent removeObjectAtIndex:indexPath.row];
        [self insertObject:newValue inFlatContentAtIndex:indexPath.row];
        
        [self.innerContent removeObjectAtIndex:indexPath.row];
        [self insertObject:newValue inInnerContentAtIndex:indexPath.row];
    }

}

-(void) editCellDidPressReturnOnCell:(EditableCell *)cell{

    if (cell.input.text.length <= 0) [cell.input resignFirstResponder];
    NSInteger currentIndex = [tableView.visibleCells indexOfObject:cell];
    if (currentIndex !=  NSNotFound){
        EditableCell* nextCell = [tableView.visibleCells safeObjectAtIndex: currentIndex + 1];
        if (nextCell){
//            nextCell.input.enabled =YES;
            [nextCell.input becomeFirstResponder];
            [tableView scrollToRowAtIndexPath:cell.indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
            return;
        }
    }
    [self editCell:cell didEndEditingAtIndexPath:cell.indexPath];
}

-(void) adjustHeightForCell:(EditableCell *)cell{
//    [tableView reloadRowsAtIndexPaths:@[cell.indexPath] withRowAnimation:YES];
//    [tableView beginUpdates];
//    [tableView endUpdates];
}

#pragma mark - JRComponentProtocal Methods
-(void) initializeComponents: (NSDictionary*)config
{
}

-(NSString*) attribute
{
    return _attribute;
}

-(void) setAttribute: (NSString*)attribute
{
    _attribute = attribute;
}


-(void) subRender: (NSDictionary*)dictionary {
    if ([dictionary objectForKey:@"HIDE_HEADER"]){
        //no header
        headerView.alpha = 0.0f;
    }
}

-(id) getValue {
    return nil;
}

-(void) setValue: (id)value {
}


-(void) setEditing:(BOOL)editing animated:(BOOL)animated{
    [self.tableView setEditing:editing animated:animated];
    for (UITableViewCell* cell in self.tableView.visibleCells){
        [cell setVisiable:!editing type:[UIButton class]];
    }
}

#pragma mark - UITableView dataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableViewObj {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableViewObj numberOfRowsInSection:(NSInteger)section {
    NSLog(@"---%i  - %i", section, self.flatContent.count);
    return self.flatContent.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableViewObj cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;

    if (indexPath.row==self.flatContent.count-1){
        cell = [tableViewObj dequeueReusableCellWithIdentifier:@"EditableCell" forIndexPath:indexPath];
        ((EditableCell*)cell).input.text = self.flatContent[indexPath.row];
        ((EditableCell*)cell).delegate = (id<EditCellProtocol>)self.contentDelegate;
        ((EditableCell*)cell).indexPath = [indexPath copy];
    }else{
        cell = [tableViewObj dequeueReusableCellWithIdentifier:@"defaultCell" forIndexPath:indexPath];
        cell.textLabel.text = self.flatContent[indexPath.row];
    }
    
    NSArray* coordinates = valuesXcoordinates ? valuesXcoordinates : headersXcoordinates;

    [AlignTableView separateCellTextToAlignHeaders: tableView cell:cell indexPath:indexPath valuesXcoordinates:coordinates valuesYcoordinates:nil];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}


-(BOOL) tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPat{
//    if (indexPath.row == self.contents.count - 1) return NO;
    return YES;
}

-(BOOL) tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == self.flatContent.count - 1)return NO;
    return YES;
}
-(void) tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (editingStyle == UITableViewCellEditingStyleInsert){
        
        NSString* data = [((EditableCell*)self.tableView.visibleCells.lastObject) getContent];
        [self.innerContent insertObject:[self.innerContent.lastObject copy] atIndex:indexPath.row];
        [self.flatContent insertObject:data atIndex:indexPath.row];
        
        [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationBottom];
    }
    else if (editingStyle == UITableViewCellEditingStyleDelete){
        [self.flatContent removeObjectAtIndex:indexPath.row];
        [self.innerContent removeObjectAtIndex:indexPath.row];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

-(void) tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath{
    NSString *piv = [self.flatContent[sourceIndexPath.row] copy];
    self.flatContent[sourceIndexPath.row] = [self.flatContent[destinationIndexPath.row] copy];
    self.flatContent[destinationIndexPath.row] = piv;
}

@end
