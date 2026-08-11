//
//  NoaSsoAccountManagerView.h
//  NoaChatKit
//
//  Created by phl on 2025/11/5.
//

#import "NoaLoginBaseBlurView.h"

NS_ASSUME_NONNULL_BEGIN

/// 点击登录事件回调
/// @param ssoType - 邀请码类型
/// @Param ssoText - 邀请码/ip拼接域名
typedef void(^ClickLoginBtnAction)(ZSsoTypeMenu ssoType, NSString *ssoText);

/// 点击扫码事件回调
typedef void(^ClickScanBtnAction)(void);

/// 点击帮助事件回调
typedef void(^ClickHelpBtnAction)(void);

/// 点击网络检测事件回调
typedef void(^ClickNetworkDetectionBtnAction)(NSString *ssoText);

@interface NoaSsoAccountManagerView : NoaLoginBaseBlurView

/// 点击登录事件回调
@property (nonatomic, copy) ClickLoginBtnAction clickLoginBtnAction;

/// 点击扫码事件回调
@property (nonatomic, copy) ClickScanBtnAction clickScanBtnAction;

/// 点击帮助事件回调
@property (nonatomic, copy) ClickHelpBtnAction clickHelpBtnAction;

/// 点击网络检测事件回调
@property (nonatomic, copy) ClickNetworkDetectionBtnAction clickNetworkDetectionBtnAction;

/// 设置是否启用网络检测入口。
/// @param enabled YES 显示并允许点击，NO 隐藏并禁止点击。
- (void)setNetworkDetectionEnabled:(BOOL)enabled;

/// 扫码后，修改邀请码
- (void)scanQrcodeChangeSsoType:(ZSsoTypeMenu)ssoType SsoInfo:(NSString *)ssoInfo;

@end

NS_ASSUME_NONNULL_END
