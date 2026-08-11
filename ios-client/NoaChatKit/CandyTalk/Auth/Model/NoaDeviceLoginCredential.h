//
//  NoaDeviceLoginCredential.h
//  CandyTalk
//
//  Created by Gemini on 2026/8/8.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NoaDeviceLoginCredential : NSObject

/// 保存或更新指定登录账号的设备登录凭据。
+ (void)saveCredentialWithLoginInfo:(NSString *)loginInfo
                            userUid:(NSString *)userUid
                       deviceSecret:(NSString *)deviceSecret;

/// 获取指定登录账号上一次成功登录保存的设备凭据。
+ (nullable instancetype)credentialForLoginInfo:(NSString *)loginInfo;

/// 根据已登录用户 UID 获取当前设备凭据。
/// @param userUid 当前已登录用户 UID。
/// @return 匹配且字段完整的设备登录凭据；未找到时返回 nil。
+ (nullable instancetype)credentialForUserUid:(NSString *)userUid;

/// 用户登录时输入的账号，用于匹配下一次登录。
@property (nonatomic, copy) NSString *loginInfo;

/// 登录成功后服务端返回的用户 UID。
@property (nonatomic, copy) NSString *userUid;

/// 登录成功后服务端返回的当前设备凭证。
@property (nonatomic, copy) NSString *deviceSecret;

@end

NS_ASSUME_NONNULL_END
