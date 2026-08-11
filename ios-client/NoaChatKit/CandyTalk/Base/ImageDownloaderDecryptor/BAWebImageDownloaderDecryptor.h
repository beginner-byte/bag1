//
//  BAWebImageDownloaderDecryptor.h
//  beacon-pro-ios
//
//  Created by xujin on 2025/2/28.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BAWebImageDownloaderDecryptor : NSObject<SDWebImageDownloaderDecryptor>

/// Create the data decryptor with block
/// @param block A block to control decrypt logic
- (nonnull instancetype)initWithBlock:(nonnull SDWebImageDownloaderDecryptorBlock)block;

/// Create the data decryptor with block
/// @param block A block to control decrypt logic
+ (nonnull instancetype)decryptorWithBlock:(nonnull SDWebImageDownloaderDecryptorBlock)block;

- (nonnull instancetype)init NS_UNAVAILABLE;
+ (nonnull instancetype)new  NS_UNAVAILABLE;

@end


/// Convenience way to create decryptor for common data encryption.
@interface BAWebImageDownloaderDecryptor (Conveniences)

/// decode image data decryptor
@property (class, readonly, nonnull) BAWebImageDownloaderDecryptor *decodeDecryptor;

@end

NS_ASSUME_NONNULL_END
