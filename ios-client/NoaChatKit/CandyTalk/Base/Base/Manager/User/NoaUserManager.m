//
//  NoaUserManager.m
//  NoaKit
//
//  Created by Candy on 2026/9/15.
//

#import "NoaUserManager.h"

NSNotificationName const UserRoleAuthorityTranslateFlagDidChange = @"UserRoleAuthorityTranslateFlagDidChange";
NSNotificationName const NoaCurrentUserDidChangeNotification = @"NoaCurrentUserDidChangeNotification";

// Forward declaration for private class method used before category implementation
@interface NoaUserManager (UserRoleAuthPersist)
+ (NSString *)userRoleAuthStorageKeyForUID:(NSString *)uid;
@end

@implementation NoaUserManager

#pragma mark - 单例实现
DEF_SINGLETON(NoaUserManager)

- (instancetype)init{
    self = [super init];
    if (self) {
        _userInfo = [NoaUserModel getUserInfo];
        _roleConfigDict = [NoaRoleConfigModel getRoleConfigInfo];
        // 尝试加载当前用户持久化的权限模型
        if (_userInfo && ![NSString isNil:_userInfo.userUID]) {
            NSString *storageKey = [NoaUserManager userRoleAuthStorageKeyForUID:_userInfo.userUID];
            NSData *data = [[MMKV defaultMMKV] getDataForKey:storageKey];
            if (data) {
                NSError *unarchiveError = nil;
                NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingFromData:data error:&unarchiveError];
                if (unarchiver) {
                    unarchiver.requiresSecureCoding = NO;
                    id obj = [unarchiver decodeObjectForKey:NSKeyedArchiveRootObjectKey];
                    [unarchiver finishDecoding];
                    if ([obj isKindOfClass:[NoaUserRoleAuthorityModel class]]) {
                        _userRoleAuthInfo = (NoaUserRoleAuthorityModel *)obj;
                    }
                }
            }
        }

    }
    return self;
}

#pragma mark - 用户相关
- (void)setUserInfo:(NoaUserModel *)userInfo {
    if (userInfo) {
        _userInfo = userInfo;
        [_userInfo saveUserInfo];
    }else {
        _userInfo = nil;
        [NoaUserModel clearUserInfo];
    }
    // Work 只接收当前用户快照，通知中不携带 ios-client token 或 Worker token。
    [[NSNotificationCenter defaultCenter] postNotificationName:NoaCurrentUserDidChangeNotification object:nil];
}

- (BOOL)isLogined{
    return ![NSString isNil:UserManager.userInfo.token];
}

//清除保存的信息
- (void)clearUserInfo {
    // 先清理角色权限，再清理用户信息
    if (_userInfo && ![NSString isNil:_userInfo.userUID]) {
        NSString *storageKey = [NoaUserManager userRoleAuthStorageKeyForUID:_userInfo.userUID];
        [[MMKV defaultMMKV] removeValueForKey:storageKey];
    }
    _userRoleAuthInfo = nil;
    _userInfo = nil;
    // 退出登录时立即要求 Work 清空内存会话，防止下一用户复用旧身份。
    [[NSNotificationCenter defaultCenter] postNotificationName:NoaCurrentUserDidChangeNotification object:nil];
}

- (BOOL)isTranslateEnabled {
    // 默认开启
    if (!self.userRoleAuthInfo || !self.userRoleAuthInfo.translationSwitch || [NSString isNil:self.userRoleAuthInfo.translationSwitch.configValue]) {
        return YES;
    }
    return [self.userRoleAuthInfo.translationSwitch.configValue isEqualToString:@"true"];
}

#pragma mark - 角色配置相关
- (void)setRoleConfigInfo:(NSDictionary *)roleConfigDict {
    if (roleConfigDict) {
        _roleConfigDict = roleConfigDict;
        [NoaRoleConfigModel saveRoleConfigInfoWithDict:_roleConfigDict];
    }
}

- (NSString *)matchUserRoleConfigInfo:(NSInteger)roleId disableStatus:(NSInteger)disableStatus {
    NSString *realRoleName = @"";
    if (disableStatus == 4) {
        //已注销的账号
        return realRoleName;
    }
    if (_roleConfigDict == nil || _roleConfigDict.count < 0) {
        return realRoleName;
    } else {
        NoaRoleConfigModel *currentRoleModel = (NoaRoleConfigModel *)[_roleConfigDict objectForKeySafe:[NSNumber numberWithInteger:roleId]];
        if (currentRoleModel.showRoleName) {
            if ([ZLanguageTOOL.currentLanguage.languageAbbr isEqualToString:@"zh-Hans"] || [ZLanguageTOOL.currentLanguage.languageAbbr isEqualToString:@"zh-Hant"]) {
                realRoleName = currentRoleModel.roleName;
            } else {
                realRoleName = currentRoleModel.enName;
            }
        } else {
            realRoleName = @"";
        }
        return realRoleName;
    }
}

@end
@implementation NoaUserManager (UserRoleAuthPersist)

+ (NSString *)userRoleAuthStorageKeyForUID:(NSString *)uid {
    NSString *user = (![NSString isNil:uid] ? uid : @"");
    return [NSString stringWithFormat:@"%@_%@", NSStringFromClass([NoaUserRoleAuthorityModel class]), user];
}

- (void)setUserRoleAuthInfo:(NoaUserRoleAuthorityModel *)userRoleAuthInfo {
    _userRoleAuthInfo = userRoleAuthInfo;
    NSString *uid = self.userInfo.userUID;
    if ([NSString isNil:uid]) {
        return;
    }
    NSString *storageKey = [NoaUserManager userRoleAuthStorageKeyForUID:uid];
    if (userRoleAuthInfo) {
        NSError *archiveError = nil;
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:userRoleAuthInfo requiringSecureCoding:NO error:&archiveError];
        if (data) {
            [[MMKV defaultMMKV] setData:data forKey:storageKey];
        }
    } else {
        [[MMKV defaultMMKV] removeValueForKey:storageKey];
    }
}

@end
