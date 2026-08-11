//
//  NoaUserModel.h
//  NoaKit
//
//  Created by Candy on 2026/9/15.
//

#import "NoaBaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface NoaUserModel : NoaBaseModel

//用户昵称
@property (nonatomic, copy) NSString *nickname;
//用户昵称拼音
@property (nonatomic, copy) NSString *nicknamePinyin;
//用户token
@property (nonatomic, copy) NSString *token;
//用户名 账号
@property (nonatomic, copy) NSString *userName;
//性别 2:未知 1:男 0:女
@property (nonatomic, assign) NSInteger userSex;
//用户uid主键
@property (nonatomic, copy) NSString *userUID;
//用户头像
@property (nonatomic, copy) NSString *avatar;
//好友描述
@property (nonatomic, copy) NSString *descRemark;
//账号状态(注销状态：4)
@property (nonatomic, assign) NSInteger disableStatus;
//好友备注
@property (nonatomic, copy) NSString *remarks;
//好友备注拼音
@property (nonatomic, copy) NSString *remarksPinyin;
//在视图上显示的名称（有备注的话，此字段和备注一样，没有的备注的话，此字段和nickname一样）
@property (nonatomic, copy) NSString * showName;
//实时翻译account(阅译yuuee账号)
@property (nonatomic, copy) NSString * yuueeAccount;
//角色Id
@property (nonatomic, assign) NSInteger roleId;
//展示离线时间 0不展示 1展示
@property (nonatomic, assign) NSInteger showOfflineStatus;
//是否设置安全码
@property (nonatomic, assign) BOOL hasSecurityCode;

#pragma mark - 是否是自己
- (BOOL)isMySelf;

#pragma mark - 持久化用户信息
- (void)saveUserInfo;

#pragma mark - 获得持久化的用户信息
+ (id)getUserInfo;

#pragma mark - 清除持久化的用户信息
+ (void)clearUserInfo;
- (void)clearUserLoginInfo;

#pragma mark - 保存上次登录的账号，下次登录时自动填充到输入框
+ (void)savePreAccount:(NSString *)perAccount Type:(int)accountType;

#pragma mark - 获取本地保存上次登录的账号，登录时自动填充到输入框
+ (NSString *)getPreAccountWithType:(int)accountType;

@end

NS_ASSUME_NONNULL_END
