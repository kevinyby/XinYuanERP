#import <UIKit/UIKit.h>
#import "JRViewProtocal.h"
#import "NormalTextField.h"

@class InputValidator;
@class JRTextField;
typedef void(^JRTextFieldDidClickAction)(JRTextField* jrTextField);

@interface JRTextField : NormalTextField <JRComponentProtocal>

@property (nonatomic, copy) JRTextFieldDidClickAction textFieldDidClickAction;

@property (nonatomic,strong)InputValidator* inputValidator;

// Extension

// Number Value
@property (assign) BOOL isNumberValue;


// Boolean Value
@property (assign) BOOL isBooleanValue;
@property (strong) NSArray* booleanValuesLocalizeKeys;      // [a,b] ->then a:0, b:1


// Enumerate Value
@property (assign) BOOL isEnumerateValue;
@property (strong) NSArray* enumerateValues;
@property (strong) NSArray* enumerateValuesLocalizeKeys;



// Name Number Value
@property (assign) BOOL isNameNumberValue;
@property (strong) NSString* memberType;    // Employee , Client , Vendor , Other

-(BOOL)textFieldValidate;

#pragma mark - Class Methods

+(void) setTextFieldBoolValueAction: (JRTextField*)textField keys:(NSArray*)keys titleKey:(NSString*)titleKey;

@end
