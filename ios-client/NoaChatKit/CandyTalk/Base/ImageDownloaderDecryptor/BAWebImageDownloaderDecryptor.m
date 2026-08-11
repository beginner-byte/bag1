//
//  BAWebImageDownloaderDecryptor.m
//  beacon-pro-ios
//
//  Created by xujin on 2025/2/28.
//

#import "BAWebImageDownloaderDecryptor.h"

@interface BAWebImageDownloaderDecryptor ()

@property (nonatomic, copy, nonnull) SDWebImageDownloaderDecryptorBlock block;

@end

@implementation BAWebImageDownloaderDecryptor

- (instancetype)initWithBlock:(SDWebImageDownloaderDecryptorBlock)block {
    self = [super init];
    if (self) {
        self.block = block;
    }
    return self;
}

+ (instancetype)decryptorWithBlock:(SDWebImageDownloaderDecryptorBlock)block {
    BAWebImageDownloaderDecryptor *decryptor = [[BAWebImageDownloaderDecryptor alloc] initWithBlock:block];
    return decryptor;
}

- (nullable NSData *)decryptedDataWithData:(nonnull NSData *)data response:(nullable NSURLResponse *)response {
    if (!self.block) {
        return nil;
    }
    return self.block(data, response);
}

@end

@implementation BAWebImageDownloaderDecryptor (Conveniences)

+ (BAWebImageDownloaderDecryptor *)decodeDecryptor {
    static BAWebImageDownloaderDecryptor *decryptor;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        decryptor = [BAWebImageDownloaderDecryptor decryptorWithBlock:^NSData * _Nullable(NSData * _Nonnull data, NSURLResponse * _Nullable response) {
            // 解密数据
//            return [[ZEncryptManager shareEncryManager] decrypt:data];
            return [[EncryptManager shareEncryManager] decrypt:data];
        }];
    });
    return decryptor;
}

@end
