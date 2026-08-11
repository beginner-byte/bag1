//
//  InitializationSubModules.h
//  NoaKit
//
//  Created by 小梦雯 on 2025/4/21.
//

// InitializationSubModules.h
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface InitializationSubModules : NSObject

+ (NSString *)DNS_ALL_FAILED;
+ (NSString *)DNS_MAIN;
+ (NSString *)DNS_BACKUP;
+ (NSString *)DNS_ALL_SUCCESS;

+ (NSString *)BUCKET_ALL_FAIL;
+ (NSString *)BUCKET_MAIN_MAIN;
+ (NSString *)BUCKET_MAIN_BACKUP;
+ (NSString *)BUCKET_BACKUP_MAIN;
+ (NSString *)BUCKET_BACKUP_BACKUP;
+ (NSString *)BUCKET_INNER_MAIN;
+ (NSString *)BUCKET_INNER_BACKUP;
+ (NSString *)BUCKET_AWS;

+ (NSString *)UNKNOWN;

/**
 获取子模块描述
 @param code 子模块编码
 @return 描述字符串
 */
+ (NSString *)getSubModuleDescription:(nullable NSString *)code;

/**
 验证子模块编码是否合法
 @param code 子模块编码
 @return YES 表示合法，NO 表示非法
 */
+ (BOOL)isValidSubModule:(nullable NSString *)code;

@end

NS_ASSUME_NONNULL_END
