

#define REQUESTID_ORDERCreate(_ORDER)   [NSString stringWithFormat:@"%@%@",_ORDER,USER_AUTHORITY_CREATE]
#define REQUESTID_ORDERRead(_ORDER)     [NSString stringWithFormat:@"%@%@",_ORDER,USER_AUTHORITY_READ]
#define REQUESTID_ORDERModify(_ORDER)   [NSString stringWithFormat:@"%@%@",_ORDER,USER_AUTHORITY_MODIFY]
#define REQUESTID_ORDERApply(_ORDER)    [NSString stringWithFormat:@"%@%@",_ORDER,USER_AUTHORITY_APPLY]

#define REQUEST_IMGUPLOAD   @"upload"
#define REQUEST_IMGDOWNLOAD @"download"

#define REQUEST_IMGNAME(_NAME)          [NSString stringWithFormat:@"%@.png",_NAME]
#define REQUEST_UPLOADIMGNAME(_NAME)    [NSString stringWithFormat:@"%@%@",REQUEST_IMGUPLOAD,_NAME]
#define REQUEST_DOWNLOADIMGNAME(_NAME)  [NSString stringWithFormat:@"%@%@",REQUEST_IMGDOWNLOAD,_NAME]
#define isRequestIDEqual(_REQUESTID)    [request.identification isEqualToString:_REQUESTID]

#define DOWNIMAGEURL(_NAME) [NSString stringWithFormat:@"%@/%@/%@/%@%@",self.theDepartMent,self.theOrder,self.orderNumber,_NAME,@".png"]
#define DOWNIMAGEPATHURL(_PATH,_NAME) [NSString stringWithFormat:@"%@/%@/%@/%@%@",self.theDepartMent,self.theOrder,_PATH,_NAME,@".png"]

#define ButtonWithTag(_TAG)     ((UIButton*)[self.view viewWithTag:_TAG])
#define TextFieldWithTag(_TAG)  ((UITextField*)[self.view viewWithTag:_TAG])
#define TextViewWithTag(_TAG)   ((UITextView*)[self.view viewWithTag:_TAG])
#define ViewWithTag(_TAG)       ((UIView*)[self.view viewWithTag:_TAG])
#define ImageViewWithTag(_TAG)  ((UIImageView*)[self.view viewWithTag:_TAG])


#define CREATEORDER   @"createOrder"
#define APPLYORDER    @"applyOrder"
#define APPROVEORDER  @"approveOrder"

#define CREATEBILL    @"createBill"
#define APPLYBILL     @"applyBill"
#define APPROVEBILL   @"approveBill"

#define ORDERSTATUS   @"OrderStatus"
#define CREATESTATUS  @"createStatus"
#define READSTATUS    @"readStatus"

#define VALIDATOR     @"Validator"
#define Validate_TextField(_TAG)  [((ValidatorTextField*)[self.view viewWithTag:_TAG]) textFieldValidate]

#define FLITERTYPE    @"fliterType"
#define APPLYTYPE     @"applyType"

#define OrderControllerName(_ORDER) [NSString stringWithFormat:@"%@%@",_ORDER,@"ViewController"]


//#define TMD_TEST


