//
//  NoaDeviceLoginCredential.m
//  CandyTalk
//
//  Created by Gemini on 2026/8/8.
//

#import "NoaDeviceLoginCredential.h"
#import <MMKV/MMKV.h>

/// 所有账号设备登录凭据的 MMKV 存储键。
static NSString * const NoaDeviceLoginCredentialStorageKey = @"NoaDeviceLoginCredentialStorageKey";
/// 单条凭据中保存登录账号的字段名。
static NSString * const NoaDeviceLoginCredentialLoginInfoKey = @"loginInfo";
/// 单条凭据中保存用户 UID 的字段名。
static NSString * const NoaDeviceLoginCredentialUserUidKey = @"userUid";
/// 单条凭据中保存设备凭证的字段名。
static NSString * const NoaDeviceLoginCredentialDeviceSecretKey = @"deviceSecret";

@interface NoaDeviceLoginCredential ()

/// 读取全部账号的设备登录凭据。
/// @return 以登录账号为键、凭据字段字典为值的数据；本地无数据或数据损坏时返回空字典。
+ (NSDictionary<NSString *, NSDictionary<NSString *, NSString *> *> *)loadAllCredentials;

@end

@implementation NoaDeviceLoginCredential

/// 保存或更新指定登录账号的设备登录凭据。
/// @param loginInfo 用户登录时输入的账号，用作不同账号之间的隔离键。
/// @param userUid 登录成功后服务端返回的用户 UID。
/// @param deviceSecret 登录成功后服务端返回的当前设备凭证。
+ (void)saveCredentialWithLoginInfo:(NSString *)loginInfo
                            userUid:(NSString *)userUid
                       deviceSecret:(NSString *)deviceSecret {
    if (loginInfo.length == 0 ||
        userUid.length == 0 ||
        deviceSecret.length == 0) {
        return;
    }

    @synchronized (self) {
        NSMutableDictionary *allCredentials = [[self loadAllCredentials] mutableCopy];
        allCredentials[loginInfo] = @{
            NoaDeviceLoginCredentialLoginInfoKey: loginInfo,
            NoaDeviceLoginCredentialUserUidKey: userUid,
            NoaDeviceLoginCredentialDeviceSecretKey: deviceSecret
        };

        NSError *serializationError = nil;
        NSData *data = [NSJSONSerialization dataWithJSONObject:allCredentials
                                                       options:0
                                                         error:&serializationError];
        if (data && !serializationError) {
            [[MMKV defaultMMKV] setData:data forKey:NoaDeviceLoginCredentialStorageKey];
        }
    }
}

/// 获取指定登录账号上一次成功登录保存的设备凭据。
/// @param loginInfo 用户登录时输入的账号。
/// @return 字段完整的设备登录凭据；账号为空、未保存或本地数据无效时返回 nil。
+ (nullable instancetype)credentialForLoginInfo:(NSString *)loginInfo {
    if (loginInfo.length == 0) {
        return nil;
    }

    NSDictionary *credentialDictionary =
        [self loadAllCredentials][loginInfo];

    if (![credentialDictionary isKindOfClass:[NSDictionary class]]) {
        return nil;
    }

    NSString *storedLoginInfo = credentialDictionary[NoaDeviceLoginCredentialLoginInfoKey];
    NSString *userUid = credentialDictionary[NoaDeviceLoginCredentialUserUidKey];
    NSString *deviceSecret = credentialDictionary[NoaDeviceLoginCredentialDeviceSecretKey];

    if (storedLoginInfo.length == 0 ||
        userUid.length == 0 ||
        deviceSecret.length == 0) {
        return nil;
    }

    NoaDeviceLoginCredential *credential =
        [[NoaDeviceLoginCredential alloc] init];
    credential.loginInfo = storedLoginInfo;
    credential.userUid = userUid;
    credential.deviceSecret = deviceSecret;
    return credential;
}

/// 根据已登录用户 UID 获取当前设备凭据。
/// @param userUid 当前已登录用户 UID。
/// @return 匹配且字段完整的设备登录凭据；未找到时返回 nil。
+ (nullable instancetype)credentialForUserUid:(NSString *)userUid {
    if (userUid.length == 0) {
        return nil;
    }

    NSDictionary *allCredentials = [self loadAllCredentials];
    for (id credentialValue in allCredentials.allValues) {
        if (![credentialValue isKindOfClass:[NSDictionary class]]) {
            continue;
        }

        NSDictionary *credentialDictionary = (NSDictionary *)credentialValue;
        NSString *storedUserUid = credentialDictionary[NoaDeviceLoginCredentialUserUidKey];
        if (![storedUserUid isKindOfClass:[NSString class]] ||
            ![storedUserUid isEqualToString:userUid]) {
            continue;
        }

        NSString *loginInfo = credentialDictionary[NoaDeviceLoginCredentialLoginInfoKey];
        NSString *deviceSecret = credentialDictionary[NoaDeviceLoginCredentialDeviceSecretKey];
        if (![loginInfo isKindOfClass:[NSString class]] ||
            ![deviceSecret isKindOfClass:[NSString class]] ||
            loginInfo.length == 0 ||
            deviceSecret.length == 0) {
            return nil;
        }

        NoaDeviceLoginCredential *credential = [[NoaDeviceLoginCredential alloc] init];
        credential.loginInfo = loginInfo;
        credential.userUid = storedUserUid;
        credential.deviceSecret = deviceSecret;
        return credential;
    }

    return nil;
}

/// 读取并解析 MMKV 中保存的全部设备登录凭据。
/// @return 可安全读取的账号凭据字典；解析失败时丢弃本次无效结果并返回空字典。
+ (NSDictionary<NSString *, NSDictionary<NSString *, NSString *> *> *)loadAllCredentials {
    NSData *data = [[MMKV defaultMMKV] getDataForKey:NoaDeviceLoginCredentialStorageKey];
    if (data.length == 0) {
        return @{};
    }

    NSError *deserializationError = nil;
    id object = [NSJSONSerialization JSONObjectWithData:data
                                                options:0
                                                  error:&deserializationError];
    if (deserializationError || ![object isKindOfClass:[NSDictionary class]]) {
        // 本地缓存可能因旧版本格式或异常写入而无法解析；返回空集合保证登录流程不被阻断。
        return @{};
    }

    return (NSDictionary<NSString *, NSDictionary<NSString *, NSString *> *> *)object;
}

@end
