//
//  NoaGetImgVerCodeViewController.h
//  NoaChatKit
//
//  Created by phl on 2025/11/14.
//

#import "NoaLoginBaseViewController.h"
// 转场动画
#import "NoaCenterAlertTransitioningDelegate.h"

NS_ASSUME_NONNULL_BEGIN

/// 配置图文验证码成功（imgVerCodeStr 已做安全处理）
typedef void(^ConfigureImgVerCodeSuccessBlock)(NSString *imgVerCodeStr);

/// 取消图文验证码
typedef void(^CancelInputImgVerCodeBlock)(void);

@interface NoaGetImgVerCodeViewController : CandyBaseViewController

/// 配置图文验证码成功，回调给上个页面
@property (nonatomic, copy) ConfigureImgVerCodeSuccessBlock configureImgVerCodeSuccessBlock;

/// 取消图文验证码输入
@property (nonatomic, copy) CancelInputImgVerCodeBlock cancelInputImgVerCodeBlock;

/// 转场代理（强引用，避免被释放）
@property (nonatomic, strong) NoaCenterAlertTransitioningDelegate *transDelegate;

/// 账号
@property (nonatomic, copy) NSString *account;

/**
 验证码类型
 0:用户名登录
 1:手机号注册
 2:手机号登录
 3:手机号找回密码
 */
@property (nonatomic, assign) NSInteger verCodeType;

/// 外部传入的图文验证码
@property (nonatomic, copy) NSString *imgVerCode;

- (void)show;

@end

NS_ASSUME_NONNULL_END
