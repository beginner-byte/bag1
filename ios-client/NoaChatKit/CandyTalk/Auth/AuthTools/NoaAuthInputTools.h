//
//  NoaAuthInputTools.h
//  NoaKit
//
//  Created by Candy on 2023/4/7.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NoaAuthInputTools : NSObject

/// 登录校验手机号
/// - Parameters:
///   - text: 手机号码
///   - isShowToast: 是否Toast提示
+ (BOOL)loginCheckPhoneWithText:(NSString *)text
                    IsShowToast:(BOOL)isShowToast;

/// 注册校验手机号码
/// - Parameters:
///   - text: 手机号码
///   - isShowToast: 是否Toast提示
+ (BOOL)registerCheckPhoneWithText:(NSString *)text
                       IsShowToast:(BOOL)isShowToast;

/// 登录校验邮箱
/// - Parameters:
///   - text: 邮箱账号
///   - isShowToast: 是否Toast提示
+ (BOOL)loginCheckEmailWithText:(NSString *)text
                    IsShowToast:(BOOL)isShowToast;

/// 注册校验邮箱
/// - Parameters:
///   - text: 邮箱账号
///   - isShowToast: 是否Toast提示
+ (BOOL)registerCheckEmailWithText:(NSString *)text
                       IsShowToast:(BOOL)isShowToast;


/// 登录校验账号
/// - Parameters:
///   - text: 账号
///   - isShowToast: 是否Toast提示
+ (BOOL)loginCheckAccountWithText:(NSString *)text
                      IsShowToast:(BOOL)isShowToast;

/// 注册校验账号
/// - Parameters:
///   - text: 账号
///   - isShowToast: 是否Toast提示
+ (BOOL)registerCheckAccountWithText:(NSString *)text
                      IsShowToast:(BOOL)isShowToast;

/// 校验账号 输入完成失去焦点时校验是否为6-16位
/// - Parameters:
///   - text: 账号
+ (BOOL)registerCheckInputAccountEndWithTextLength:(NSString *)text;

/// 校验账号 输入完成失去焦点时校验：账号前两位必须为英文，只支持英文或数字
/// - Parameters:
///   - text: 账号
+ (BOOL)registerCheckInputAccountEndWithTextFormat:(NSString *)text;

/// 校验验证码
/// - Parameters:
///   - text: 验证码
///   - isShowToast: 是否Toast提示
+ (BOOL)checkVerCodeWithText:(NSString *)text
                 IsShowToast:(BOOL)isShowToast;

/// 校验密码
/// - Parameters:
///   - text: 密码
///   - isShowToast: 是否Toast提示
+ (BOOL)checkPasswordWithText:(NSString *)text
                  IsShowToast:(BOOL)isShowToast;

#pragma mark - 校验密码 输入中/粘贴

/// 校验密码
/// - Parameters:
///   - text: 密码
+ (BOOL)checkCreatPasswordInputWithText:(NSString *)text;

#pragma mark - 校验密码:校验密码是否为6-16位

/// 校验密码:校验密码是否为6-16位
/// - Parameters:
///   - text: 密码
+ (BOOL)checkCreatPasswordEndWithTextLength:(NSString *)text;

#pragma mark - 校验密码:校验是否包含字母和数字(英文字符)

/// 校验密码:校验是否包含字母和数字(英文字符)
/// - Parameters:
///   - text: 密码
+ (BOOL)checkCreatPasswordEndWithTextFormat:(NSString *)text;

/// 校验邀请码
/// - Parameters:
///   - text: 邀请码
///   - isShowToast: 是否Toast提示
+ (BOOL)checkInviteCodeWithText:(NSString *)text
                    IsShowToast:(BOOL)isShowToast;

/// 校验昵称
/// - Parameters:
///   - text: 昵称
///   - isShowToast: 是否Toast提示
+ (BOOL)checkNickNameWithText:(NSString *)text
                  IsShowToast:(BOOL)isShowToast;

@end

NS_ASSUME_NONNULL_END
