//
//  AesEncryptUtils.h
//  Converted from Java version com.zlc.nav.util.AesEncryptUtils
//
//  AES/ECB/PKCS5Padding (equivalent to PKCS7 in CommonCrypto)
//  Key derivation: SHA-1(secret) then take first 16 bytes (AES-128)
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AesEncryptUtils : NSObject

/// AES key length (bits)
extern const int AES_KEY_LEN;

/// Encrypt a UTF-8 string and return Base64 string (AES/ECB/PKCS5Padding)
+ (nullable NSString *)encrypt:(NSString *)plainText secret:(NSString *)secret;

/// Encrypt raw bytes and return cipher bytes (AES/ECB/PKCS5Padding)
+ (nullable NSData *)encryptBytes:(NSData *)plainData secret:(NSString *)secret;

/// Decrypt raw cipher bytes and return plain bytes (AES/ECB/PKCS5Padding)
+ (nullable NSData *)decryptBytes:(NSData *)cipherData secret:(NSString *)secret;

/// Decrypt a Base64 cipher string and return UTF-8 string (AES/ECB/PKCS5Padding)
+ (nullable NSString *)decrypt:(NSString *)base64Cipher secret:(NSString *)secret;

@end

NS_ASSUME_NONNULL_END


