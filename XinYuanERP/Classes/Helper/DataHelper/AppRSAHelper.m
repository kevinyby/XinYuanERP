#import "AppRSAHelper.h"
#import "RSAKeysKeeper.h"
#import "AppInterface.h"

@implementation AppRSAHelper

static RSAEncryptor* rsaEncryptor = nil;

+(void)initialize
{
    if (self == [AppRSAHelper class]) {
        rsaEncryptor = [[RSAEncryptor alloc] init];
        
        [rsaEncryptor loadPublicKeyFromData: [NSData dataFromBase64String: [RSAKeysKeeper derKey]]];
        [rsaEncryptor loadPrivateKeyFromData: [NSData dataFromBase64String: [RSAKeysKeeper p12Key]] password: [RSAKeysKeeper p12Password]];
        RSAEncryptor.sharedInstance = rsaEncryptor;
    }
}


+(NSString*) encrypt:(NSString*)string
{
    if (OBJECT_EMPYT(string)) return string;
    
    NSString* result = string;
    @try {
        result = [rsaEncryptor rsaEncryptString: string];
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
        result = [rsaEncryptor rsaDecryptString: string];
    }
    @catch (NSException *exception) {
        
    }
    return result;
}


@end
