#import "AppRSAHelper.h"
#import "AppRSAKeysKeeper.h"
#import "AppInterface.h"

@implementation AppRSAHelper

static RSABase64Cryptor* rsaEncryptor = nil;

+(void)initialize
{
    if (self == [AppRSAHelper class]) {
        rsaEncryptor = [[RSABase64Cryptor alloc] init];
        
        [rsaEncryptor loadPublicKeyFromString: [AppRSAKeysKeeper derKey]];
        [rsaEncryptor loadPrivateKeyFromString: [AppRSAKeysKeeper p12Key] password: [AppRSAKeysKeeper p12Password]];
        RSABase64Cryptor.sharedInstance = rsaEncryptor;
    }
}


+(NSString*) encrypt:(NSString*)string
{
    if (OBJECT_EMPYT(string)) return string;
    
    NSString* result = string;
    @try {
        result = [rsaEncryptor rsaBase64EncryptString: string];
    }
    @catch (NSException *exception) {
        
    }
    return result;
}


+(NSString*) decrypt:(NSString*)string
{
    if (OBJECT_EMPYT(string)) return string;
    NSString* result = string;
    @try {
        result = [rsaEncryptor rsaBase64DecryptString: string];
    }
    @catch (NSException *exception) {
        
    }
    return result;
}


@end
