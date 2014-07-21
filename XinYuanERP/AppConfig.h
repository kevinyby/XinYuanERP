

#define LANGUAGE_Viet_Nam @"Viet_Nam"     // on ios



//**** 调试输出 ****
#ifdef DEBUG

#define LOG(_format,args...)  printf("Line:%d  %s  %s\n",__LINE__, sel_getName(_cmd),[[NSString stringWithFormat:(_format),##args] UTF8String])
#define DBLOG(_format,args...)  printf("Line:%d  %s  %s\n",__LINE__, sel_getName(_cmd),[[NSString stringWithFormat:(_format),##args] UTF8String])
#else
#define LOG(_format,args...)
#define DBLOG(_format,args...)
#endif


#define LONG_IPAD 1024
#define SHORT_IPAD 768

#define LONG_IPHONE 480
#define SHORT_IPHONE 320

#define LONG_IPHONE5 568

#define IS_IPHONE_5 ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )
#define IS_IPHONE  UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone


#define IOS_VERSION  [[[UIDevice currentDevice] systemVersion] floatValue]


#define IS_SUPERUSER(_identification)       _identification < 0 && _identification%2 == 0
#define IS_ADMINISTATOR(_identification)    _identification < 0 && _identification%2 == -1

#define OBJECT_EMPYT(obj)     (obj == nil || (id)obj == [NSNull null] || ([obj isKindOfClass:[NSString class]] && [obj isEqualToString: @""]))


//USER_DEFAULTS
#pragma mark -
#pragma mark USER_DEFAULTS

#define USER_DEFAULTS_SET(_OBJECT,_KEY) {\
[[NSUserDefaults standardUserDefaults] setObject:_OBJECT forKey:_KEY];\
[[NSUserDefaults standardUserDefaults] synchronize];}

#define USER_DEFAULTS_GET(_KEY) ([[NSUserDefaults standardUserDefaults] objectForKey:_KEY])


#pragma mark -
#pragma mark - Common

#define  XYWH(__X,__Y,__W,__H) CGRectMake(__X, __Y, __W, __H)

#define RGB(__R,__G,__B)	 [UIColor colorWithRed:(__R)/255.0f green:(__G)/255.0f blue:(__B)/255.0f alpha:1.0]
#define FONT(_SIZE)			 [UIFont systemFontOfSize:_SIZE]
#define TRANSLATEFONT(_SIZE) [UIFont fontWithName:@"Arial" size:[FrameTranslater convertFontSize:_SIZE]]

#define IMAGEINIT(_imgName) [UIImage imageNamed:(_imgName)]

#define PARENTSUBVIEW(_PARENT,_TAG) [_PARENT viewWithTag:_TAG]
#define PARENTTYPEVIEW(_TYPE,_PARENT,_TAG) ((_TYPE*)[_PARENT viewWithTag:_TAG])


#define isEmptyString(_String) [Utility isBlankString:_String]
#define isEmptyArray(_ARRAY)   (_ARRAY == nil || [_ARRAY count] == 0)

#define NULLOBJECT  [NSNull null]

#pragma mark -
#pragma mark - Color
#define WHITE_COLOR		[UIColor whiteColor]
#define BLACK_COLOR		[UIColor blackColor]
#define GRAY_COLOR		[UIColor grayColor]
#define BLUE_COLOR		[UIColor blueColor]
#define RED_COLOR		[UIColor redColor]
#define GREEN_COLOR		[UIColor greenColor]
#define YELLOW_COLOR	[UIColor yellowColor]



#define PREFERENCE_LANGUAGE @"PREFERENCE_LANGUAGE"

#define LANGUAGES @[LANGUAGE_zh_TW, LANGUAGE_zh_CN, LANGUAGE_en, LANGUAGE_Viet_Nam]


#define DROPBOX_APPKEY @"r6uxf2nfp1hf7ch"
#define DROPBOX_APPSECRET @"wdthzm9878s3d3o"




