//
//  NoaEncryptManager.m
//  NoaKit
//
//  Created by Apple on 2023/9/1.
//

#import "NoaEncryptManager.h"
#import <CommonCrypto/CommonCryptor.h>
#import <Security/SecRandom.h>
#define Z_XOR @"XOR"
#define Z_AES @"AES"
@implementation NoaEncryptManager
static dispatch_once_t onceToken;

#pragma mark - 单例的实现
+ (instancetype)shareEncryManager{
    static NoaEncryptManager *_manager = nil;
    dispatch_once(&onceToken, ^{
        //不能再使用alloc方法
        //因为已经重写了allocWithZone方法，所以这里要调用父类的分配空间的方法
        _manager = [[super allocWithZone:NULL] init];
    });
    return _manager;
}
// 防止外部调用alloc 或者 new
+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    return [NoaEncryptManager shareEncryManager];
}
// 防止外部调用copy
- (id)copyWithZone:(nullable NSZone *)zone {
    return [NoaEncryptManager shareEncryManager];
}
// 防止外部调用mutableCopy
- (id)mutableCopyWithZone:(nullable NSZone *)zone {
    return [NoaEncryptManager shareEncryManager];
}

// 异或加密
- (NSData *)xorEncrypt:(NSData*)data{
    BOOL isExist = [self xorIsExist:data];
    if(isExist){
        return data;
    }
    //数据源长度
    int dataLength = (int)data.length;
    if (dataLength < 256) {
        return data;
    }
    //需要加密的数据 长度128
    if (dataLength < 256) {
        return data.copy;
    }
    NSData * noneData = [data subdataWithRange:NSMakeRange(0, 128)];
    //未做加密的数据
    NSData * originData = [data subdataWithRange:NSMakeRange(128, dataLength - 128)];
    //取出数据最后256的长度作为加密串
    NSData *privateKeyData = [data subdataWithRange:NSMakeRange(dataLength - 256, 256)];
    NSMutableData * encryptData = [self xorHandle:noneData keyData:privateKeyData];
    [encryptData appendData:originData];
    //加上xor标识的三个字节
    NSData * sorData = [self xorData];
    NSMutableData * mdata = [[NSMutableData alloc] initWithData:sorData];
    [mdata appendData:encryptData];
    return mdata.copy;
}
// 异或解密
-(NSData*)xorDecrypt:(NSData*)data{
    
    BOOL isExist = [self xorIsExist:data];
    if(!isExist){
        return data;
    }
    int dataLength = (int)data.length;
    if (dataLength < 256) {
        return data;
    }
    //前三个字节是xor标识，要把这三个字节去掉。需要加密的数据 长度128
    if (dataLength < 256) {
        return data.copy;
    }
    NSData * noneData = [data subdataWithRange:NSMakeRange(3, 128)];
    //未做加密的数据
    NSData * originData = [data subdataWithRange:NSMakeRange(128 + 3, dataLength - 128 - 3)];
    //取出数据最后256的长度作为加密串
    NSData *privateKeyData = [data subdataWithRange:NSMakeRange(dataLength - 256, 256)];
    NSMutableData * encryptData = [self xorHandle:noneData keyData:privateKeyData];
    [encryptData appendData:originData];
   return encryptData.copy;
}
//判断是否有异或加密标识
-(BOOL)xorIsExist:(NSData*)data{
    Byte *bytes = (Byte *)[data bytes];
    if (bytes != nil && sizeof(bytes) >= 3) {
        NSData *adata = [[NSData alloc] initWithBytes:bytes length:3];
        NSString *aString = [[NSString alloc] initWithData:adata encoding:NSUTF8StringEncoding];
        if ([aString isEqualToString:Z_XOR]) {
            return  YES;
        } else {
            return NO;
        }
    } else {
        return  NO;
    }
}

-(EncryptType)encryptTypeIsExist:(NSData*)data {
    Byte *bytes = (Byte *)[data bytes];
    if (bytes != nil && sizeof(bytes) >= 3) {
        NSData *adata = [[NSData alloc] initWithBytes:bytes length:3];
        NSString *aString = [[NSString alloc] initWithData:adata encoding:NSUTF8StringEncoding];
        if ([aString isEqualToString:Z_XOR]) {
            return EncryptTypeXOR;
        } else if ([aString isEqualToString:Z_AES]){
            return EncryptTypeAES;
        } else {
            return EncryptTypeNOT;
        }
    } else {
        return  EncryptTypeNOT;
    }
}

//加密标识符
-(NSData*)xorData{
    NSData * sdata = [Z_XOR dataUsingEncoding:NSUTF8StringEncoding];
    return  sdata;
}
//异或加密实现
-(NSMutableData*)xorHandle:(NSData*)cryptData keyData:(NSData*)privateKeyData{
    const  char * cKey=[privateKeyData bytes];
    NSInteger length  = 256;
    // 数据初始化，空间未分配 配合使用 appendBytes
    NSMutableData *encryptData = [[NSMutableData alloc] initWithCapacity:length];
    // 获取字节指针
    const Byte *point = cryptData.bytes;
    for (int i = 0; i < cryptData.length; i++) {
          // 算出当前位置字节，要和密钥的异或运算的密钥字节
          int l = i % length;
          char c = cKey[l];
          // 异或运算
          Byte b = (Byte) ((point[i]) ^ c);
          // 追加字节
          [encryptData appendBytes:&b length:1];
    }
    return encryptData;
}

#pragma mark - 当对大文件进行加密时，会导致内存快速飙升，除非iOS系统内存告警并可能出现闪退，所以加密采用下面的方法
- (NSData *)encryptFileToData:(NSData *)plainData
                                error:(NSError **)error{
    if (!plainData) {
           if (error) *error = [NSError errorWithDomain:@"CryptoUtilErrorDomain"
                                                   code:-1
                                               userInfo:@{NSLocalizedDescriptionKey: @"plainData 为空"}];
           return plainData;
       }

       // 生成随机 key(32) 和 iv(16)
       uint8_t keyBytes[32];
       uint8_t ivBytes[16];
       if (SecRandomCopyBytes(kSecRandomDefault, sizeof(keyBytes), keyBytes) != errSecSuccess ||
           SecRandomCopyBytes(kSecRandomDefault, sizeof(ivBytes), ivBytes) != errSecSuccess) {
           if (error) *error = [NSError errorWithDomain:@"CryptoUtilErrorDomain"
                                                   code:-2
                                               userInfo:@{NSLocalizedDescriptionKey: @"随机数生成失败"}];
           return plainData;
       }

       // 输出缓冲（明文长度 + 一个 block 大小以备填充）
       size_t cipherBufferSize = plainData.length + kCCBlockSizeAES128;
       void *cipherBuffer = malloc(cipherBufferSize);
       if (!cipherBuffer) {
           if (error) *error = [NSError errorWithDomain:@"CryptoUtilErrorDomain"
                                                   code:-3
                                               userInfo:@{NSLocalizedDescriptionKey: @"内存分配失败"}];
           // 清理敏感数据
           memset_s(keyBytes, sizeof(keyBytes), 0, sizeof(keyBytes));
           memset_s(ivBytes, sizeof(ivBytes), 0, sizeof(ivBytes));
           return plainData;
       }

       size_t outLength = 0;
       CCCryptorStatus status = CCCrypt(kCCEncrypt,
                                        kCCAlgorithmAES,
                                        kCCOptionPKCS7Padding,
                                        keyBytes, sizeof(keyBytes),
                                        ivBytes,
                                        plainData.bytes, plainData.length,
                                        cipherBuffer, cipherBufferSize,
                                        &outLength);
       if (status != kCCSuccess) {
           if (error) *error = [NSError errorWithDomain:@"CryptoUtilErrorDomain"
                                                   code:-4
                                               userInfo:@{NSLocalizedDescriptionKey: @"CCCrypt 加密失败"}];
           free(cipherBuffer);
           memset_s(keyBytes, sizeof(keyBytes), 0, sizeof(keyBytes));
           memset_s(ivBytes, sizeof(ivBytes), 0, sizeof(ivBytes));
           return plainData;
       }

       // 构造最终结果："AES" + version + key(32) + iv(16) + ciphertext
       NSMutableData *result = [NSMutableData data];
       const char header[] = {'A','E','S'};
       [result appendBytes:header length:3];

       uint8_t version = 2;
       [result appendBytes:&version length:1];

       [result appendBytes:keyBytes length:sizeof(keyBytes)];
       [result appendBytes:ivBytes  length:sizeof(ivBytes)];

       if (outLength > 0) {
           [result appendBytes:cipherBuffer length:outLength];
       }

       // 清理
       // 尽量清零敏感内存
       memset_s(keyBytes, sizeof(keyBytes), 0, sizeof(keyBytes));
       memset_s(ivBytes, sizeof(ivBytes), 0, sizeof(ivBytes));
       // 复制到 NSData 后释放临时 buffer
       free(cipherBuffer);

       return [result copy];
}

- (NSData*)decrypt:(NSData*)data {
    EncryptType encryptType = [self encryptTypeIsExist:data];
    switch (encryptType) {
        case EncryptTypeAES:
            return [self AESDecrypt:data];
            break;
        case EncryptTypeXOR:
            return [self xorDecrypt:data];
            
        default:
            return data;
            break;
    }
}

// 异或处理方法
- (NSMutableData *)otherXorHandle:(NSData *)data keyData:(NSData *)keyData {
    NSMutableData *result = [NSMutableData dataWithLength:data.length];
    const char *dataBytes = data.bytes;
    const char *keyBytes = keyData.bytes;
    char *resultBytes = result.mutableBytes;
    
    for (NSUInteger i = 0; i < data.length; i++) {
        resultBytes[i] = dataBytes[i] ^ keyBytes[i % keyData.length];
    }
    return result;
}

// AES加密
- (NSData *)AESEncrypt:(NSData*)plainData {
    if (!plainData || plainData.length == 0) {
        return plainData;
    }
    
    // 生成 32 字节 key（AES-256）和 16 字节 iv
    uint8_t keyBytes[32];
    uint8_t ivBytes[16];
    if (SecRandomCopyBytes(kSecRandomDefault, sizeof(keyBytes), keyBytes) != errSecSuccess) {
        return plainData;
    }
    if (SecRandomCopyBytes(kSecRandomDefault, sizeof(ivBytes), ivBytes) != errSecSuccess) {
        return plainData;
    }
    
    NSData *key = [NSData dataWithBytes:keyBytes length:sizeof(keyBytes)];
    NSData *iv = [NSData dataWithBytes:ivBytes length:sizeof(ivBytes)];
    
    // 输出缓冲（明文长度 + 一个 block 的空间以备填充）
    size_t outAvailable = plainData.length + kCCBlockSizeAES128;
    void *outBuffer = malloc(outAvailable);
    if (!outBuffer) return plainData;
    
    size_t outMoved = 0;
    CCCryptorStatus status = CCCrypt(kCCEncrypt,
                                     kCCAlgorithmAES,
                                     kCCOptionPKCS7Padding,
                                     key.bytes, key.length,
                                     iv.bytes,
                                     plainData.bytes, plainData.length,
                                     outBuffer, outAvailable,
                                     &outMoved);
    
    if (status != kCCSuccess) {
        free(outBuffer);
        return plainData; // 加密失败，返回原数据（与解密方法行为一致）
    }
    
    NSData *ciphertext = [NSData dataWithBytes:outBuffer length:outMoved];
    free(outBuffer);
    
    // 按解密方法所期望的格式拼接： "AES" + version(2) + key(32) + iv(16) + ciphertext
    NSMutableData *result = [NSMutableData data];
    const char header[] = {'A','E','S'};
    [result appendBytes:header length:3];
    
    uint8_t version = 2;
    [result appendBytes:&version length:1];
    
    [result appendData:key];
    [result appendData:iv];
    [result appendData:ciphertext];
    
    return [result copy];
}

// AES解密
-(NSData*)AESDecrypt:(NSData*)data {
    // 最小长度检查：3 ("AES") + 1 (version) + 32 (key) + 16 (iv)
    if (!data || data.length < (3 + 1 + 32 + 16)) {
        return data; // 数据太小，无法解密
    }
    
    NSUInteger offset = 3; // 跳过 "AES"
    uint8_t version = 0;
    [data getBytes:&version range:NSMakeRange(offset, 1)];
    offset += 1;
    
    if (version != 2) {
        return data; // 不支持的版本
    }
    
    NSData *key = [data subdataWithRange:NSMakeRange(offset, 32)];
    offset += 32;
    NSData *iv = [data subdataWithRange:NSMakeRange(offset, 16)];
    offset += 16;
    NSData *ciphertext = [data subdataWithRange:NSMakeRange(offset, data.length - offset)];
    
    // 准备输出缓冲区（多加一个 block 大小以防填充）
    size_t dataOutAvailable = ciphertext.length + kCCBlockSizeAES128;
    void *dataOut = malloc(dataOutAvailable);
    if (!dataOut) return data;
    
    size_t dataOutMoved = 0;
    CCCryptorStatus status = CCCrypt(kCCDecrypt,
                                     kCCAlgorithmAES,
                                     kCCOptionPKCS7Padding,
                                     key.bytes, key.length,
                                     iv.bytes,
                                     ciphertext.bytes, ciphertext.length,
                                     dataOut, dataOutAvailable,
                                     &dataOutMoved);
    
    if (status != kCCSuccess) {
        free(dataOut);
        return data; // 解密失败，返回原数据
    }
    
    NSData *decrypted = [NSData dataWithBytes:dataOut length:dataOutMoved];
    free(dataOut);
    return decrypted;
}


@end
