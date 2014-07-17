#import "FinancePaymentBillCell.h"
#import "AppInterface.h"

@implementation FinancePaymentBillCell


@synthesize itemOrderNOTf;
@synthesize productNameTf;
@synthesize shouldPayTf;
@synthesize alreadPayTf ;
@synthesize unpaidTextField;

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame: frame];
    if (self) {
        // Against to FinancePaymentBill
        itemOrderNOTf = [[JRTextField alloc] init];     // order number
        itemOrderNOTf.attribute = attr_referenceOrderNO;
        
        productNameTf = [[JRTextField alloc] init];     // product name
        productNameTf.attribute = attr_productName;
        
        alreadPayTf  = [[JRTextField alloc] init];      // already pay
        alreadPayTf.attribute = attr_realPaid;
        alreadPayTf.isNumberValue = YES;
        
        shouldPayTf  = [[JRTextField alloc] init];      // should pay
        shouldPayTf.attribute = attr_SHOULD_PAY;
        shouldPayTf.isNumberValue = YES;
        
        unpaidTextField = [[JRTextField alloc] init];
        unpaidTextField.isNumberValue = YES;
        
        // left to right
        [self addSubview:itemOrderNOTf];
        [self addSubview:productNameTf];
        [self addSubview:shouldPayTf];
        [self addSubview:alreadPayTf];
        [self addSubview:unpaidTextField];
        
        self.backgroundColor = [UIColor greenColor];
    }
    return self;
}

-(void)setTextFieldDelegate:(id)textFieldDelegate
{
    productNameTf.delegate = textFieldDelegate;
    alreadPayTf.delegate = textFieldDelegate;
}


-(void) setBillValues: (NSMutableDictionary*)values
{
    [ViewHelper iterateSubView: self class:[JRTextField class] handler:^BOOL(id subView) {
        JRTextField* tx = (JRTextField*)subView;
        id value = [values objectForKey: tx.attribute];
        [tx setValue: value];
        return NO;
    }];
    
    // caculate the unpaid
    float unpaidValue = [[shouldPayTf getValue] floatValue] - [[alreadPayTf getValue] floatValue];
    if (unpaidValue == 0) {
        [unpaidTextField setValue: nil];
    } else {
        [unpaidTextField setValue: [NSNumber numberWithFloat: unpaidValue]];
    }
    // order Type
    if ([values objectForKey: attr_referenceOrderType]) self.order = [values objectForKey: attr_referenceOrderType];
}


-(NSMutableDictionary*) getBillValues
{
    NSMutableDictionary* values = [NSMutableDictionary dictionary];
    
    [ViewHelper iterateSubView: self class:[JRTextField class] handler:^BOOL(id subView) {
        JRTextField* tx = (JRTextField*)subView;
        id value = [tx getValue];
        NSString* key = tx.attribute;
        if (value && key) {
            [values setObject: value forKey:key];
        }
        return NO;
    }];
    return values;
}




@end
