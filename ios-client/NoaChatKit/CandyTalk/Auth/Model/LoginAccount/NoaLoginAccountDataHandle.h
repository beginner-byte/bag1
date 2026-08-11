//
//  NoaLoginAccountManager.h
//  NoaChatKit
//
//  Created by phl on 2025/11/6.
//

#import "NoaAuthBaseDataHandle.h"

NS_ASSUME_NONNULL_BEGIN

@class NoaEncryptKeyGuard;

@interface NoaLoginAccountDataHandle : NoaAuthBaseDataHandle

/// 跳转至注册账号页面
@property (nonatomic, strong) RACSubject *jumpRegisterSubject;

/// 跳转至安全码页面
@property (nonatomic, strong) RACSubject *jumpSafeCodeAuthSubject;

/// 跳转至验证码登录页面
@property (nonatomic, strong) RACSubject *jumpVerCodeLoginSubject;

/// 跳转至忘记密码页面
@property (nonatomic, strong) RACSubject *jumpForgetPasswordSubject;

/// 修改图文验证码展示状态
@property (nonatomic, strong) RACSubject *changeImageCodeShowStatusSubject;

/// 密钥获取成功后，登录触发事件
@property (nonatomic, strong) RACCommand *loginAccountCommand;

/// 支持的类型标题
@property (nonatomic, strong, readonly) NSMutableArray *titleArr;

/// 登录方式(顺序与titleArr一致)
@property (nonatomic, strong, readonly) NSMutableArray *loginTypeArr;

/// 图文验证码状态
@property (nonatomic, strong, readonly) NSMutableDictionary *imageCodeStateDic;

/// 初始化数据信息
- (void)resetLoginConfigureInfo;

/// 获取支持的注册方式
- (NSMutableArray *)getRegisterConfigureInfo;

/// 根据切换页签的角标获取用户选择的登录类型
/// - Parameter index: index
- (ZLoginAndRegisterTypeMenu)getLoginTypeWithIndex:(NSInteger)index;

/// 检查手机号码、邮箱号码、账号合法性
- (BOOL)checkAccountAvailable:(NSString *)account;

/// 检查密码合法性
- (BOOL)checkPasswordAvailable:(NSString *)password;

/// 获取某个登录方式对应的图文验证码状态
/// - Parameter loginType: 登录方式
- (BOOL)getImageCodeStateWithLoginState:(ZLoginAndRegisterTypeMenu)loginType;

/// 点击登录按钮时，校验登录参数
- (BOOL)checkLoginAccountInfoAvaliableWhenClickLoginBtn;

/// 设置图文验证码显示状态
/// @param loginTypeMenu 登录类型
/// @param show YES-显示，NO-隐藏
- (void)setImageCodeViewShow:(BOOL)show
                   loginType:(ZLoginAndRegisterTypeMenu)loginTypeMenu;

@end

NS_ASSUME_NONNULL_END
