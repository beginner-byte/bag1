//
//  NoaUserManager.h
//  NoaKit
//
//  Created by Candy on 2026/9/15.
//

#define UserManager ([NoaUserManager sharedInstance])

#import <Foundation/Foundation.h>
#import "NoaUserModel.h"
#import "NoaUserRoleAuthorityModel.h"
#import "NoaRoleConfigModel.h"
#import "NoaGroupActivityInfoModel.h"

// 翻译开关变化通知
FOUNDATION_EXPORT NSNotificationName const UserRoleAuthorityTranslateFlagDidChange;

// 当前 ios-client 用户写入或清除后发送，供 Work 模块撤销旧内存会话并重新换票。
FOUNDATION_EXPORT NSNotificationName const NoaCurrentUserDidChangeNotification;

NS_ASSUME_NONNULL_BEGIN

@interface NoaUserManager : NSObject

#pragma mark - 单例实现
AS_SINGLETON(NoaUserManager)

#pragma mark - 用户相关
//持久化的当前用户信息
@property (nonatomic, strong) NoaUserModel   * _Nullable userInfo;
//持久化的当前用户权限
@property (nonatomic, strong) NoaUserRoleAuthorityModel   * _Nullable userRoleAuthInfo;
//持久化群活跃配置信息
@property (nonatomic, strong) NoaGroupActivityInfoModel   * _Nullable activityConfigInfo;

//是否已登录
- (BOOL)isLogined;
//清除保存的信息
- (void)clearUserInfo;

// 翻译开关便捷读取（默认开启）
- (BOOL)isTranslateEnabled;

#pragma mark - 角色配置相关
//持久化的角色配置信息
@property (nonatomic, strong) NSDictionary * _Nullable roleConfigDict;

- (NSString *)matchUserRoleConfigInfo:(NSInteger)roleId disableStatus:(NSInteger)disableStatus;

@end

NS_ASSUME_NONNULL_END
