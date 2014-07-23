#import "AppRSAHelper.h"
#import "AppRSAKeysKeeper.h"
#import "AppInterface.h"

@implementation AppRSAHelper

static RSAEncryptor* rsaEncryptor = nil;

+(void)initialize
{
    if (self == [AppRSAHelper class]) {
        rsaEncryptor = [[RSAEncryptor alloc] init];
        
        [rsaEncryptor loadPublicKeyFromData: [NSData dataFromBase64String: [AppRSAKeysKeeper derKey]]];
        [rsaEncryptor loadPrivateKeyFromData: [NSData dataFromBase64String: [AppRSAKeysKeeper p12Key]] password: [AppRSAKeysKeeper p12Password]];
        RSAEncryptor.sharedInstance = rsaEncryptor;
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
