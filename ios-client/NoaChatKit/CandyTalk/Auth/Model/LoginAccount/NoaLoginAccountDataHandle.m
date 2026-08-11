//
//  NoaLoginAccountManager.m
//  NoaChatKit
//
//  Created by phl on 2025/11/6.
//

#import "NoaLoginAccountDataHandle.h"
// 信息校验
#import "NoaAuthInputTools.h"
// 弱密码校验
#import "NoaWeakPwdCheckTool.h"
// AppDelegate
#import "AppDelegate.h"
// 用户模型
#import "NoaUserModel.h"
// 用户管理
#import "NoaUserManager.h"
// 工具类
#import "NoaToolManager.h"

// 设备登录凭据持久化
#import "NoaDeviceLoginCredential.h"

@interface NoaLoginAccountDataHandle ()

/// 支持的类型标题
@property (nonatomic, strong, readwrite) NSMutableArray *titleArr;

/// 登录方式(顺序与titleArr一致)
@property (nonatomic, strong, readwrite) NSMutableArray *loginTypeArr;

/// 图文验证码状态
@property (nonatomic, strong, readwrite) NSMutableDictionary *imageCodeStateDic;

@end

@implementation NoaLoginAccountDataHandle

// MARK: set/get
- (NSMutableArray *)titleArr {
    if (!_titleArr) {
        _titleArr = [NSMutableArray new];
    }
    return _titleArr;
}

- (NSMutableArray *)loginTypeArr {
    if (!_loginTypeArr) {
        _loginTypeArr = [NSMutableArray new];
    }
    return _loginTypeArr;
}

- (NSMutableDictionary *)imageCodeStateDic {
    if (!_imageCodeStateDic) {
        _imageCodeStateDic = [NSMutableDictionary new];
    }
    return _imageCodeStateDic;
}

- (RACSubject *)jumpRegisterSubject {
    if (!_jumpRegisterSubject) {
        _jumpRegisterSubject = [RACSubject subject];
    }
    return _jumpRegisterSubject;
}

- (RACSubject *)jumpSafeCodeAuthSubject {
    if (!_jumpSafeCodeAuthSubject) {
        _jumpSafeCodeAuthSubject = [RACSubject subject];
    }
    return _jumpSafeCodeAuthSubject;
}

- (RACSubject *)jumpVerCodeLoginSubject {
    if (!_jumpVerCodeLoginSubject) {
        _jumpVerCodeLoginSubject = [RACSubject subject];
    }
    return _jumpVerCodeLoginSubject;
}

- (RACSubject *)jumpForgetPasswordSubject {
    if (!_jumpForgetPasswordSubject) {
        _jumpForgetPasswordSubject = [RACSubject subject];
    }
    return _jumpForgetPasswordSubject;
}

- (RACSubject *)changeImageCodeShowStatusSubject {
    if (!_changeImageCodeShowStatusSubject) {
        _changeImageCodeShowStatusSubject = [RACSubject subject];
    }
    return _changeImageCodeShowStatusSubject;
}

- (RACCommand *)loginAccountCommand {
    if (!_loginAccountCommand) {
        @weakify(self)
        _loginAccountCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
            return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
                @strongify(self)
                NSDictionary *loginParamDic = input;
                
                // 将参数添加
                NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:loginParamDic];
                
                // 账号信息
                // 账号信息-账号+图文验证码(可能为@"")，都已做安全校验
                NSString *account = [self getAccountText];
                NSString *imageCode = [self getImgVerCodeText];
                
                // 登录方式转换为接口指定参数
                int loginType = [self covertInterfaceParamWithLoginTypeMenu:self.currentLoginTypeMenu];
                // 获取当前登录方式-图文验证码是否展示
                BOOL isShowImageCodeStatus = [self getImageCodeStateWithLoginState:self.currentLoginTypeMenu];
                
                // 区号 - 仅手机号码有值
                NSString *areaCode = (self.currentLoginTypeMenu == ZLoginTypeMenuPhoneNumber ? [self getAreaCode] : @"");
                
                // 账号
                [params setObjectSafe:account forKey:@"loginInfo"];
                // 登录方式
                [params setObjectSafe:@(loginType) forKey:@"loginType"];
                // 手机区号
                [params setObjectSafe:areaCode forKey:@"areaCode"];
                // type固定2
                [params setObjectSafe:@2 forKey:@"type"];
                // 根据当前登录方式决定是否展示图文验证码
                [params setObjectSafe:isShowImageCodeStatus ? imageCode : @"" forKey:@"loginFailVerifyCode"];
                
                if (isShowImageCodeStatus) {
                    // 因为图文验证码登录与腾讯、阿里验证登录接口不一致，故有图文验证码的，设置sdk为图文验证码
                    [IMSDKManager configSDKCaptchaChannel:2];
                }else {
                    // 非图文验证码，使用系统设置
                    [IMSDKManager configSDKCaptchaChannel:ZHostTool.appSysSetModel.captchaChannel];
                }

                // 未登录时按当前账号装载设备凭证；未命中时清空旧账号残留凭证，避免跨账号误用。
                NoaDeviceLoginCredential *credential =
                    [NoaDeviceLoginCredential credentialForLoginInfo:account];
                [IMSDKManager configSDKDeviceSecret:credential.deviceSecret];
                
                [IMSDKManager authUserLoginWith:params onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
                    @strongify(self)
                    [self handleLoginSuccess:data];
                    [subscriber sendNext:@YES];
                    [subscriber sendCompleted];
                } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
                    @strongify(self)
                    [self handleLoginError:code
                                       msg:msg];
                    [subscriber sendNext:@NO];
                    [subscriber sendCompleted];
                }];
                
                return [RACDisposable disposableWithBlock:^{
                    
                }];
            }];
        }];
    }
    return _loginAccountCommand;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self resetLoginConfigureInfo];
    }
    return self;
}

/// 获取登录方式
- (void)resetLoginConfigureInfo {
    // 标题
    NSMutableArray *titleArr = [NSMutableArray new];
    // 标题对应的枚举
    NSMutableArray *loginTypeArr = [NSMutableArray new];
    // 对应验证码状态
    NSMutableDictionary *imageCodeStateDic = [NSMutableDictionary new];
    
    if ([ZHostTool.appSysSetModel.loginMethod isEqualToString:@"1"]) {
        // 账号
        [titleArr addObject:LanguageToolMatch(@"账号")];
        [loginTypeArr addObject:@(ZLoginTypeMenuAccountPassword)];
        
        // 当前登录方式对应的图文验证码状态
        [imageCodeStateDic setValue:@NO forKey:[NSString stringWithFormat:@"%lu", ZLoginTypeMenuAccountPassword]];
    } else if ([ZHostTool.appSysSetModel.loginMethod isEqualToString:@"2"]) {
        // 邮箱
        [titleArr addObject:LanguageToolMatch(@"邮箱")];
        [loginTypeArr addObject:@(ZLoginTypeMenuEmail)];
        
        // 当前登录方式对应的图文验证码状态
        [imageCodeStateDic setValue:@NO forKey:[NSString stringWithFormat:@"%lu", ZLoginTypeMenuEmail]];
    } else if ([ZHostTool.appSysSetModel.loginMethod isEqualToString:@"3"]) {
        // 手机号
        [titleArr addObject:LanguageToolMatch(@"手机号")];
        [loginTypeArr addObject:@(ZLoginTypeMenuPhoneNumber)];
        
        // 当前登录方式对应的图文验证码状态
        [imageCodeStateDic setValue:@NO forKey:[NSString stringWithFormat:@"%lu", ZLoginTypeMenuPhoneNumber]];
    }  else if ([ZHostTool.appSysSetModel.loginMethod isEqualToString:@"4"]) {
        // 手机号+邮箱
        [titleArr addObject:LanguageToolMatch(@"手机号")];
        [loginTypeArr addObject:@(ZLoginTypeMenuPhoneNumber)];
        
        [titleArr addObject:LanguageToolMatch(@"邮箱")];
        [loginTypeArr addObject:@(ZLoginTypeMenuEmail)];
        
        // 当前登录方式对应的图文验证码状态
        [imageCodeStateDic setValue:@NO forKey:[NSString stringWithFormat:@"%lu", ZLoginTypeMenuPhoneNumber]];
        [imageCodeStateDic setValue:@NO forKey:[NSString stringWithFormat:@"%lu", ZLoginTypeMenuEmail]];
        
    } else if ([ZHostTool.appSysSetModel.loginMethod isEqualToString:@"5"]) {
        // 账号+手机号
        [titleArr addObject:LanguageToolMatch(@"账号")];
        [loginTypeArr addObject:@(ZLoginTypeMenuAccountPassword)];
        
        [titleArr addObject:LanguageToolMatch(@"手机号")];
        [loginTypeArr addObject:@(ZLoginTypeMenuPhoneNumber)];
        
        // 当前登录方式对应的图文验证码状态
        [imageCodeStateDic setValue:@NO forKey:[NSString stringWithFormat:@"%lu", ZLoginTypeMenuAccountPassword]];
        [imageCodeStateDic setValue:@NO forKey:[NSString stringWithFormat:@"%lu", ZLoginTypeMenuPhoneNumber]];
    } else if ([ZHostTool.appSysSetModel.loginMethod isEqualToString:@"6"]) {
        // 账号+邮箱
        [titleArr addObject:LanguageToolMatch(@"账号")];
        [loginTypeArr addObject:@(ZLoginTypeMenuAccountPassword)];
        
        [titleArr addObject:LanguageToolMatch(@"邮箱")];
        [loginTypeArr addObject:@(ZLoginTypeMenuEmail)];
        
        // 当前登录方式对应的图文验证码状态
        [imageCodeStateDic setValue:@NO forKey:[NSString stringWithFormat:@"%lu", ZLoginTypeMenuAccountPassword]];
        [imageCodeStateDic setValue:@NO forKey:[NSString stringWithFormat:@"%lu", ZLoginTypeMenuEmail]];
    } else if ([ZHostTool.appSysSetModel.loginMethod isEqualToString:@"7"]) {
        // 账号+手机号+邮箱
        [titleArr addObject:LanguageToolMatch(@"账号")];
        [loginTypeArr addObject:@(ZLoginTypeMenuAccountPassword)];
        
        [titleArr addObject:LanguageToolMatch(@"手机号")];
        [loginTypeArr addObject:@(ZLoginTypeMenuPhoneNumber)];
        
        [titleArr addObject:LanguageToolMatch(@"邮箱")];
        [loginTypeArr addObject:@(ZLoginTypeMenuEmail)];
        
        // 当前登录方式对应的图文验证码状态
        [imageCodeStateDic setValue:@NO forKey:[NSString stringWithFormat:@"%lu", ZLoginTypeMenuAccountPassword]];
        [imageCodeStateDic setValue:@NO forKey:[NSString stringWithFormat:@"%lu", ZLoginTypeMenuPhoneNumber]];
        [imageCodeStateDic setValue:@NO forKey:[NSString stringWithFormat:@"%lu", ZLoginTypeMenuEmail]];
    } else  {
        // 默认：账号
        [titleArr addObject:LanguageToolMatch(@"账号")];
        [loginTypeArr addObject:@(ZLoginTypeMenuAccountPassword)];
        
        // 当前登录方式对应的图文验证码状态
        [imageCodeStateDic setValue:@NO forKey:[NSString stringWithFormat:@"%lu", ZLoginTypeMenuAccountPassword]];
    }
    
    self.titleArr = titleArr;
    self.loginTypeArr = loginTypeArr;
    self.imageCodeStateDic = imageCodeStateDic;
    self.currentLoginTypeMenu = [self.loginTypeArr.firstObject intValue];
}

- (NSMutableArray *)getRegisterConfigureInfo {
    // 支持的注册方式对应的枚举
    NSMutableArray *registerTypeArr = [NSMutableArray new];
    
    if ([ZHostTool.appSysSetModel.registerMethod isEqualToString:@"1"]) {
        // 账号
        [registerTypeArr addObject:@(ZLoginTypeMenuAccountPassword)];
    } else if ([ZHostTool.appSysSetModel.registerMethod isEqualToString:@"2"]) {
        // 邮箱
        [registerTypeArr addObject:@(ZLoginTypeMenuEmail)];
    } else if ([ZHostTool.appSysSetModel.registerMethod isEqualToString:@"3"]) {
        // 手机号
        [registerTypeArr addObject:@(ZLoginTypeMenuPhoneNumber)];
    }  else if ([ZHostTool.appSysSetModel.registerMethod isEqualToString:@"4"]) {
        // 手机号+邮箱
        [registerTypeArr addObject:@(ZLoginTypeMenuPhoneNumber)];
        [registerTypeArr addObject:@(ZLoginTypeMenuEmail)];
    } else if ([ZHostTool.appSysSetModel.registerMethod isEqualToString:@"5"]) {
        // 账号+手机号
        [registerTypeArr addObject:@(ZLoginTypeMenuAccountPassword)];
        [registerTypeArr addObject:@(ZLoginTypeMenuPhoneNumber)];
    } else if ([ZHostTool.appSysSetModel.registerMethod isEqualToString:@"6"]) {
        // 账号+邮箱
        [registerTypeArr addObject:@(ZLoginTypeMenuAccountPassword)];
        [registerTypeArr addObject:@(ZLoginTypeMenuEmail)];
    } else if ([ZHostTool.appSysSetModel.registerMethod isEqualToString:@"7"]) {
        // 账号+手机号+邮箱
        [registerTypeArr addObject:@(ZLoginTypeMenuAccountPassword)];
        [registerTypeArr addObject:@(ZLoginTypeMenuPhoneNumber)];
        [registerTypeArr addObject:@(ZLoginTypeMenuEmail)];
    } else  {
        // 默认：账号
        [registerTypeArr addObject:@(ZLoginTypeMenuAccountPassword)];
    }
    return registerTypeArr;
}

- (ZLoginAndRegisterTypeMenu)getLoginTypeWithIndex:(NSInteger)index {
    if (self.loginTypeArr.count > index) {
        return [self.loginTypeArr[index] intValue];
    }
    // 默认
    return ZLoginTypeMenuAccountPassword;
}

- (BOOL)checkAccountAvailable:(NSString *)account {
    switch (self.currentLoginTypeMenu) {
        case ZLoginTypeMenuAccountPassword:
            return [NoaAuthInputTools loginCheckAccountWithText:account IsShowToast:YES];
            break;
        case ZLoginTypeMenuPhoneNumber:
            return [NoaAuthInputTools loginCheckPhoneWithText:account IsShowToast:YES];
        case ZLoginTypeMenuEmail:
            return [NoaAuthInputTools loginCheckEmailWithText:account IsShowToast:YES];
        default:
            break;
    }
    return NO;
}

- (BOOL)checkPasswordAvailable:(NSString *)password {
    return [NoaAuthInputTools checkPasswordWithText:password IsShowToast:YES];
}

/// 点击登录按钮时，校验登录参数
- (BOOL)checkLoginAccountInfoAvaliableWhenClickLoginBtn {
    // 校验账号、手机号码、邮箱合法性
    NSString *account = [self getAccountText];
    if (![self checkAccountAvailable:account]) {
        return NO;
    }
    
    // 校验密码合法性
    NSString *password = [self getPasswordText];
    if (![self checkPasswordAvailable:password]) {
        return NO;
    }
    return YES;
}

- (BOOL)getImageCodeStateWithLoginState:(ZLoginAndRegisterTypeMenu)loginType {
    NSNumber *stateNum = [self.imageCodeStateDic objectForKey:[NSString stringWithFormat:@"%lu", loginType]];
    if (!stateNum) {
        return NO;
    }
    return [stateNum boolValue];
}

#pragma mark - 登录处理封装方法

/// 处理登录成功
/// - Parameter data: 登录成功接口返回数据
- (void)handleLoginSuccess:(id)data {
    [HUD showSuccessMessage:@"handleLoginSuccess"];
    NSString *account = [self getAccountText];
    NSString *password = [self getPasswordText];
    // 登录方式转换为接口指定参数
    int loginType = [self covertInterfaceParamWithLoginTypeMenu:self.currentLoginTypeMenu];
    
    [ZTOOL doInMain:^{
        [HUD hideHUD];
    }];
    
    // 解析数据
    NoaUserModel *loginUserModel = [NoaUserModel mj_objectWithKeyValues:data];
    
    // V5 登录成功后保存账号、用户 UID 和设备凭证，供该账号下次登录使用。
    NSString *deviceSecret = @"";
    if ([data isKindOfClass:[NSDictionary class]]) {
        id deviceSecretValue = [(NSDictionary *)data objectForKey:@"deviceSecret"];
        if ([deviceSecretValue isKindOfClass:[NSString class]]) {
            deviceSecret = (NSString *)deviceSecretValue;
        }
    }

    [NoaDeviceLoginCredential saveCredentialWithLoginInfo:account
                                                  userUid:loginUserModel.userUID
                                             deviceSecret:deviceSecret];

    // 登录成功后按用户 UID 重新装载服务端最新设备凭证，供后续请求统一使用。
    NoaDeviceLoginCredential *credential =
        [NoaDeviceLoginCredential credentialForUserUid:loginUserModel.userUID];
    [IMSDKManager configSDKDeviceSecret:credential.deviceSecret];
    
    
    [NoaUserModel savePreAccount:account Type:loginType];
    [UserManager setUserInfo:loginUserModel];
    
    // socket用户信息保存
    NoaIMSDKUserOptions *userOption = [NoaIMSDKUserOptions new];
    userOption.userToken = loginUserModel.token;
    userOption.userID = loginUserModel.userUID;
    userOption.userNickname = loginUserModel.nickname;
    userOption.userAvatar = loginUserModel.avatar;
    [IMSDKManager configSDKUserWith:userOption];
    
    // 弱密码库保存弱密码
    [NoaWeakPwdCheckTool sharedInstance].userPwd = password;
    
    // 重置sdk验证方式（注册、验证码登录、重置密码在页面消失时重置）
    [self resetSDKCaptchaChannel];
    
    // 登录成功
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [delegate loginSuccess];
}


/// 处理错误信息
/// - Parameters:
///   - errorCode: 接口返回的错误码
///   - msg: 接口返回的消息
- (void)handleLoginError:(NSInteger)errorCode
                     msg:(NSString *)errorMsg {
    NSString *account = [self getAccountText];
    NSString *password = [self getPasswordText];
    ZLoginAndRegisterTypeMenu loginTypeMenu = self.currentLoginTypeMenu;
    
    [ZTOOL doInMain:^{
        [HUD hideHUD];
    }];
    
    // 弱密码保存(错误码为安全验证的时候用)
    [NoaWeakPwdCheckTool sharedInstance].userPwd = password;
    
    // 判断错误码
    if (errorCode == Auth_User_Account_Banned ||
        errorCode == Auth_User_Device_Banned ||
        errorCode == Auth_User_IPAddress_Banned) {
        // 账号封禁/设备封禁/IP封禁
        if (errorCode == Auth_User_Account_Banned &&
            loginTypeMenu == ZLoginTypeMenuAccountPassword) {
            // 账号登录且账号被封禁
            [ZTOOL setupAlertUserBannedUIWithErrorCode:errorCode
                                           withContent:account
                                             loginType:UserAuthTypeAccount];
            return;
        }
        [ZTOOL setupAlertUserBannedUIWithErrorCode:errorCode
                                       withContent:errorMsg
                                         loginType:0];
    } else if (errorCode == LingIMHttpResponseCodeUsedIpDisabled) {
        //登录不在白名单内，需展示IP地址
        [self.showToastSubject sendNext:[NSString stringWithFormat:LanguageToolMatch(@"登录IP：%@ 不在白名单内"), errorMsg]];
    } else if (errorCode == Auth_User_Password_Error_Code) {
        // 密码错误
        [self.showToastSubject sendNext:[NSString stringWithFormat:LanguageToolMatch(@"账号或密码错误，请重新输入，错误码：%@"), @(errorCode)]];
    } else if (errorCode == Auth_User_Get_Img_Code || errorCode == Auth_User_reGet_Img_Code) {
        // 需要图形验证码
        [self handleCaptchaChannelWithAccount:account
                                     password:password
                                loginTypeMenu:loginTypeMenu];
    } else if (errorCode == Auth_User_Capcha_Error_Code) {
        // 阿里云验证异常，进行二次验证
        [self setImageCodeViewShow:NO
                         loginType:loginTypeMenu];
        // 开启阿里认证
        [self.getAliCaptchaCommand execute:@NO];
    } else if (errorCode == Auth_User_Capcha_TimeOut_Code) {
        // 阿里云验证超时，展示图文验证码
        [self setImageCodeViewShow:YES
                         loginType:loginTypeMenu];
    } else if (errorCode == Auth_User_Capcha_ChangeImgVer_Code) {
        // 图形验证码不正确，请重新输入
        [self setImageCodeViewShow:YES
                         loginType:loginTypeMenu];
        [self.showToastSubject sendNext:LanguageToolMatch(@"验证码不正确，请重新输入")];
    } else if (errorCode == Auth_Login_Security_Code_Error_Code) {
        // 登录需要安全码，跳转到安全码输入界面
        [self.jumpSafeCodeAuthSubject sendNext:[NSString isNil:errorMsg] ? @"" : errorMsg];
    } else if (errorCode == Auth_User_Password_Account_Nonexistent_Code) {
        [self.showToastSubject sendNext:[NSString stringWithFormat:LanguageToolMatch(@"账号或密码错误，请重新输入，错误码：%@"), @(errorCode)]];
    } else {
        // 兜底提示
        [self.showToastSubject sendNext:LanguageToolCodeMatch(errorCode, errorMsg)];
    }
}

// 重写父类方法
- (NSInteger)getImageCodeType {
    if (self.currentLoginTypeMenu == ZLoginTypeMenuPhoneNumber) {
        return 2; // 手机号码特殊处理
    }
    return 0;
}

/// 设置图文验证码显示状态
/// @param loginTypeMenu 登录类型
/// @param show YES-显示，NO-隐藏
- (void)setImageCodeViewShow:(BOOL)show
                   loginType:(ZLoginAndRegisterTypeMenu)loginTypeMenu {
    // 获取当前登录方式对应的图文验证码展示状态
    BOOL currentStatus = [self getImageCodeStateWithLoginState:loginTypeMenu];
    
    // 只有当状态不一致的时候更新缓存
    if (currentStatus != show) {
        NSString *key = [NSString stringWithFormat:@"%lu", loginTypeMenu];
        [self.imageCodeStateDic setValue:@(show) forKey:key];
    }
    
    // 通知UI页面刷新
    [self.changeImageCodeShowStatusSubject sendNext:@(loginTypeMenu)];
}

/// 处理验证码渠道（密码错误或需要验证码时）
/// @param account 账号
/// @param password 密码
/// @param loginTypeMenu 登录类型
- (void)handleCaptchaChannelWithAccount:(NSString *)account
                               password:(NSString *)password
                          loginTypeMenu:(ZLoginAndRegisterTypeMenu)loginTypeMenu {
    NSInteger captchaChannel = ZHostTool.appSysSetModel.captchaChannel;
    if (captchaChannel == 1) {
        // 关闭验证码，不进行处理
        return;
    } else if (captchaChannel == 2) {
        // 显示图文验证码
        [self setImageCodeViewShow:YES
                         loginType:loginTypeMenu];
    } else if (captchaChannel == 3) {
        // 先隐藏图文验证码
        [self setImageCodeViewShow:NO
                         loginType:loginTypeMenu];
        // 进行腾讯无痕验证
        [self.getTencentCaptchaCommand execute:nil];
    } else if (captchaChannel == 4) {
        // 先隐藏图文验证码
        [self setImageCodeViewShow:NO
                         loginType:loginTypeMenu];
        // 阿里无感验证
        [self.getAliCaptchaCommand execute:@YES];
    }
}

@end
