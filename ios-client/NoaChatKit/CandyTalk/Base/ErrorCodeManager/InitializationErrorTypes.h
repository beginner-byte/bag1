//
//  InitializationErrorTypes.h
//  NoaKit
//
//  Created by 小梦雯 on 2025/4/21.
//

// InitializationErrorTypes.h
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface InitializationErrorTypes : NSObject

+ (NSString *)OSS_FAILURE;
+ (NSString *)OSS_NONEXISTENT_FAILURE;
+ (NSString *)OSS_VOID_FAILURE;
+ (NSString *)OSS_DECODE_FAILURE;
+ (NSString *)HTTP_FAILURE;
+ (NSString *)HTTP_DECODE_FAILURE;
+ (NSString *)TCP_FAILURE;
+ (NSString *)UNKNOWN;
+ (NSString *)systemConfig_failure;
/**
 获取错误类型描述
 @param code 错误类型编码
 @return 描述字符串
 */
+ (NSString *)getErrorTypeDescription:(nullable NSString *)code;

/**
 验证错误类型编码是否合法
 @param code 错误类型编码
 @return YES 表示合法，NO 表示非法
 */
+ (BOOL)isValidErrorType:(nullable NSString *)code;

+ (BOOL)isErrorCodeGreater:(nullable NSString *)newCode than:(nullable NSString *)currentCode;

@end

NS_ASSUME_NONNULL_END
