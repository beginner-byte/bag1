//
//  ErrorModules.h
//  NoaKit
//
//  Created by 小梦雯 on 2025/4/21.
//

// ErrorModules.h
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ErrorModules : NSObject

/// 初始化模块 ("01")
+ (NSString *)INITIALIZATION;
/// 网络通讯模块 ("02")
+ (NSString *)NETWORK;
/// 单聊业务模块 ("03")
+ (NSString *)SINGLE_CHAT;
/// 群聊业务模块 ("04")
+ (NSString *)GROUP_CHAT;
/// 用户认证模块 ("05")
+ (NSString *)AUTHENTICATION;
/// 数据存储模块 ("06")
+ (NSString *)STORAGE;
/// 消息处理模块 ("07")
+ (NSString *)MESSAGE;
/// 多媒体模块 ("08")
+ (NSString *)MEDIA;
/// 其他模块 ("99")
+ (NSString *)OTHER;
/// 未知模块 ("00")
+ (NSString *)UNKNOWN;

/**
 获取模块描述
 @param code 模块编码
 @return 描述字符串
 */
+ (NSString *)getModuleDescription:(nullable NSString *)code;

/**
 验证模块编码是否合法
 @param code 模块编码
 @return YES 表示合法，NO 表示非法
 */
+ (BOOL)isValidModule:(nullable NSString *)code;

@end

NS_ASSUME_NONNULL_END
