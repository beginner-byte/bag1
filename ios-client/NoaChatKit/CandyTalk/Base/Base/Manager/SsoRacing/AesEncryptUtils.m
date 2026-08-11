//
//  AesEncryptUtils.m
//

#import "AesEncryptUtils.h"
#import <CommonCrypto/CommonCrypto.h>

const int AES_KEY_LEN = 128; // bits

@implementation AesEncryptUtils

#pragma mark - Public

+ (NSString *)encrypt:(NSString *)plainText secret:(NSString *)secret {
    if (plainText.length == 0) return nil;
    NSData *plain = [plainText dataUsingEncoding:NSUTF8StringEncoding];
    NSData *keyData = [self.class deriveKeyFromSecret:secret];
    if (!keyData) return nil;
    NSData *cipher = [self.class AESOperation:kCCEncrypt data:plain key:keyData];
    if (!cipher) return nil;
    return [cipher base64EncodedStringWithOptions:0];
}

+ (NSData *)encryptBytes:(NSData *)plainData secret:(NSString *)secret {
    if (plainData.length == 0) return nil;
    NSData *keyData = [self.class deriveKeyFromSecret:secret];
    if (!keyData) return nil;
    return [self.class AESOperation:kCCEncrypt data:plainData key:keyData];
}

+ (NSData *)decryptBytes:(NSData *)cipherData secret:(NSString *)secret {
    if (cipherData.length == 0) return nil;
    NSData *keyData = [self.class deriveKeyFromSecret:secret];
    if (!keyData) return nil;
    return [self.class AESOperation:kCCDecrypt data:cipherData key:keyData];
}

+ (NSString *)decrypt:(NSString *)base64Cipher secret:(NSString *)secret {
    if (base64Cipher.length == 0) return nil;
    NSData *cipher = [[NSData alloc] initWithBase64EncodedString:base64Cipher options:0];
    if (!cipher) return nil;
    NSData *keyData = [self.class deriveKeyFromSecret:secret];
    if (!keyData) return nil;
    NSData *plain = [self.class AESOperation:kCCDecrypt data:cipher key:keyData];
    if (!plain) return nil;
    return [[NSString alloc] initWithData:plain encoding:NSUTF8StringEncoding];
}

#pragma mark - Internal

+ (NSData *)deriveKeyFromSecret:(NSString *)secret {
    if (!secret) return nil;
    NSData *secretData = [secret dataUsingEncoding:NSUTF8StringEncoding];
    uint8_t sha1[CC_SHA1_DIGEST_LENGTH] = {0};
    CC_SHA1(secretData.bytes, (CC_LONG)secretData.length, sha1);
    // Take first 16 bytes (AES-128)
    return [NSData dataWithBytes:sha1 length:16];
}

+ (NSData *)AESOperation:(CCOperation)op data:(NSData *)input key:(NSData *)keyData {
    if (!input || !keyData) return nil;
    // AES/ECB/PKCS5Padding -> CommonCrypto: kCCAlgorithmAES, kCCOptionPKCS7Padding | kCCOptionECBMode
    size_t outLength = 0;
    size_t bufferSize = input.length + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    if (!buffer) return nil;

    CCCryptorStatus status = CCCrypt(op,
                                     kCCAlgorithmAES,
                                     kCCOptionPKCS7Padding | kCCOptionECBMode,
                                     keyData.bytes,
                                     kCCKeySizeAES128,
                                     NULL,
                                     input.bytes,
                                     input.length,
                                     buffer,
                                     bufferSize,
                                     &outLength);
    if (status != kCCSuccess) {
        free(buffer);
        return nil;
    }
    return [NSData dataWithBytesNoCopy:buffer length:outLength];
}

@end


