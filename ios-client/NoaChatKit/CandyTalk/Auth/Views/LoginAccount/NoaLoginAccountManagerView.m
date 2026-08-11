//
//  NoaLoginAccountManagerView.m
//  NoaChatKit
//
//  Created by phl on 2025/11/6.
//

#import "NoaLoginAccountManagerView.h"
#import "NoaChatKit-Swift.h"

// 数据处理
#import "NoaLoginAccountDataHandle.h"
// 保证加密 key 唯一性
#import "NoaEncryptKeyGuard.h"
// 加密
#import "LXChatEncrypt.h"
// 协议提示弹窗
#import "NoaAlertTipView.h"

@interface NoaLoginAccountManagerView ()

/// Figma 登录页的 Swift 可视层，所有可见组件与输入状态均由该视图管理。
@property (nonatomic, strong) CoHereLoginPageView *loginPageView;

/// 登录数据处理对象，继续复用既有请求、加密、验证码和登录成功流程。
@property (nonatomic, strong) NoaLoginAccountDataHandle *dataHandle;

@end

@implementation NoaLoginAccountManagerView

/// 初始化登录业务协调视图。
/// @param frame 初始区域，最终由控制器约束为全屏。
/// @param manager 既有登录数据处理对象。
/// @return 完成 Swift 页面与业务绑定的协调视图。
- (instancetype)initWithFrame:(CGRect)frame
                   DataHandle:(NoaLoginAccountDataHandle *)manager {
    self = [super initWithFrame:frame IsPopWindows:NO];
    if (self) {
        _dataHandle = manager;
        [self setupLoginPage];
        [self bindPageActions];
        [self bindInputProvider];
        [self bindRequestResults];
    }
    return self;
}

/// 创建全屏 Swift 登录页并写入后端动态登录方式、区号与版本信息。
- (void)setupLoginPage {
    self.loginPageView = [[CoHereLoginPageView alloc] initWithFrame:CGRectZero];
    self.loginPageView.translatesAutoresizingMaskIntoConstraints = NO;
    // 父类保留的毛玻璃层 zPosition 较高，Swift 页面必须处于其上方才能完整替换旧界面。
    self.loginPageView.layer.zPosition = 2001;
    [self addSubview:self.loginPageView];
    [NSLayoutConstraint activateConstraints:@[
        [self.loginPageView.topAnchor constraintEqualToAnchor:self.topAnchor],
        [self.loginPageView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
        [self.loginPageView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
        [self.loginPageView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor],
    ]];

    [self.loginPageView configureWithTitles:self.dataHandle.titleArr
                                 loginTypes:self.dataHandle.loginTypeArr
                              selectedIndex:0];
    [self.loginPageView setAreaCodeText:[self.dataHandle getAreaCode]];
    NSString *versionText = [NSString stringWithFormat:@"V%@ %@",
                             [ZTOOL getCurretnVersion],
                             [ZTOOL getBuildVersion]];
    [self.loginPageView setVersionText:versionText];
}

/// 将 Swift 页面交互转发给现有 RACSubject、协议路由和控制器回调。
- (void)bindPageActions {
    @weakify(self)

    self.loginPageView.onLoginTap = ^{
        @strongify(self)
        [self clickLoginBtnAction];
    };

    self.loginPageView.onRegisterTap = ^{
        @strongify(self)
        [self.dataHandle.jumpRegisterSubject sendNext:nil];
    };

    self.loginPageView.onVerificationLoginTap = ^{
        @strongify(self)
        [self.dataHandle.jumpVerCodeLoginSubject sendNext:nil];
    };

    self.loginPageView.onForgotPasswordTap = ^{
        @strongify(self)
        [self.dataHandle.jumpForgetPasswordSubject sendNext:nil];
    };

    self.loginPageView.onAreaCodeTap = ^{
        @strongify(self)
        [self.dataHandle.jumpChangeAreaCodeSubject sendNext:@0];
    };

    self.loginPageView.onCaptchaRefreshTap = ^{
        @strongify(self)
        [self.dataHandle setImageCodeViewShow:YES
                                    loginType:self.dataHandle.currentLoginTypeMenu];
    };

    self.loginPageView.onInviteTap = ^{
        @strongify(self)
        if (self.clickInviteCodeBlock) {
            self.clickInviteCodeBlock();
        }
    };

    self.loginPageView.onUserAgreementTap = ^{
        [ZTOOL setupServeAgreement];
    };

    self.loginPageView.onPrivacyAgreementTap = ^{
        [ZTOOL setupPrivePolicy];
    };

    self.loginPageView.onLoginTypeChanged = ^(NSInteger loginType, NSInteger index) {
        @strongify(self)
        self.dataHandle.currentLoginTypeMenu = [self.dataHandle getLoginTypeWithIndex:index];
        if (self.dataHandle.currentLoginTypeMenu == ZLoginTypeMenuPhoneNumber) {
            [self.loginPageView setAreaCodeText:[self.dataHandle getAreaCode]];
        }
        BOOL shouldShowCaptcha = [self.dataHandle getImageCodeStateWithLoginState:self.dataHandle.currentLoginTypeMenu];
        [self.loginPageView setCaptchaVisible:shouldShowCaptcha
                                         text:nil
                                    loginType:self.dataHandle.currentLoginTypeMenu];
    };
}

/// 为数据层提供 Swift 页面内当前登录方式的输入值。
- (void)bindInputProvider {
    @weakify(self)
    self.dataHandle.getInputTextBlock = ^NSDictionary<NSString *,NSString *> *(ZLoginAndRegisterTypeMenu loginType) {
        @strongify(self)
        if (!self) {
            return @{};
        }

        NSDictionary<NSString *, NSString *> *values = [self.loginPageView textValuesForLoginType:loginType];
        NSString *identity = values[@"identity"] ?: @"";
        NSString *password = values[@"password"] ?: @"";
        NSString *captcha = values[@"captcha"] ?: @"";
        NSMutableDictionary<NSString *, NSString *> *textDictionary = [NSMutableDictionary new];

        switch (loginType) {
            case ZLoginTypeMenuAccountPassword:
                textDictionary[kLoginModuleParamAccountKey] = identity;
                break;
            case ZLoginTypeMenuPhoneNumber:
                textDictionary[kLoginModuleParamPhoneNumberKey] = identity;
                break;
            case ZLoginTypeMenuEmail:
                textDictionary[kLoginModuleParamEmailKey] = identity;
                break;
            default:
                break;
        }

        textDictionary[kLoginModuleParamPasswordKey] = password;
        textDictionary[kLoginModuleParamImgCodeKey] = captcha;
        return textDictionary;
    };
}

/// 统一订阅登录所需的密钥、用户检查、验证码和最终登录结果。
- (void)bindRequestResults {
    [self bindEncryptKeyResult];
    [self bindUserExistResult];
    [self bindInvisibleCaptchaResults];
    [self bindImageCaptchaResults];
    [self bindLoginResult];
}

/// 处理加密密钥请求结果并继续执行原登录命令。
- (void)bindEncryptKeyResult {
    @weakify(self)
    [self.dataHandle.getEncryptKeyCommand.executionSignals.switchToLatest subscribeNext:^(id _Nullable value) {
        @strongify(self)
        if (![value isKindOfClass:[NSDictionary class]]) {
            [HUD hideHUD];
            return;
        }

        NSDictionary *response = value;
        BOOL success = [response[@"res"] boolValue];
        if (!success) {
            [HUD hideHUD];
            NSDictionary *error = response[@"error"];
            if (error) {
                NSInteger code = [error[@"code"] integerValue];
                [self.dataHandle.showToastSubject sendNext:LanguageToolCodeMatch(code, error[@"msg"])];
            }
            return;
        }

        NSString *keyData = response[@"data"];
        if (keyData.length == 0) {
            [HUD hideHUD];
            return;
        }

        NoaEncryptKeyGuard *guard = [NoaEncryptKeyGuard guardWithKey:keyData];
        NSString *encryptKey = [guard consume];
        if ([NSString isNil:encryptKey]) {
            [HUD hideHUD];
            return;
        }

        NSString *password = [self.dataHandle getPasswordText];
        NSString *passwordSource = [NSString stringWithFormat:@"%@%@", encryptKey, password];
        NSString *encryptedPassword = [LXChatEncrypt method4:passwordSource];
        if ([NSString isNil:encryptedPassword]) {
            [HUD hideHUD];
            [HUD showMessage:[NSString stringWithFormat:@"%@～", LanguageToolMatch(@"操作失败")]
                      inView:self];
            return;
        }

        NSMutableDictionary *loginParameters = nil;
        if (!self.dataHandle.tempParamWhenGetEncrypt) {
            loginParameters = [@{
                @"encryptKey": encryptKey,
                @"userPw": encryptedPassword,
                @"ticket": @"",
                @"randstr": @"",
                @"captchaVerifyParam": @"",
                @"code": @""
            } mutableCopy];
        } else {
            loginParameters = [self.dataHandle.tempParamWhenGetEncrypt mutableCopy];
            loginParameters[@"encryptKey"] = encryptKey;
            loginParameters[@"userPw"] = encryptedPassword;
        }

        self.dataHandle.tempParamWhenGetEncrypt = nil;
        [self.dataHandle.loginAccountCommand execute:loginParameters];
    }];
}

/// 处理用户存在性检查，保留既有模糊错误提示和登录参数准备逻辑。
- (void)bindUserExistResult {
    @weakify(self)
    [self.dataHandle.checkUserIsExistAndHadPasswordCommand.executionSignals.switchToLatest subscribeNext:^(id _Nullable value) {
        @strongify(self)
        if (![value isKindOfClass:[NSDictionary class]]) {
            [HUD hideHUD];
            return;
        }

        NSDictionary *response = value;
        BOOL success = [response[@"res"] boolValue];
        if (!success) {
            [HUD hideHUD];
            NSDictionary *error = response[@"error"];
            if (!error) {
                return;
            }

            NSInteger code = [error[@"code"] integerValue];
            NSString *message = error[@"msg"];
            if (code == 2036 || code == 40019 || code == 50000 || code == 50001) {
                NSString *text = [NSString stringWithFormat:LanguageToolMatch(@"账号或密码错误，请重新输入，错误码：%@"), @(code)];
                [self.dataHandle.showToastSubject sendNext:text];
            } else {
                [self.dataHandle.showToastSubject sendNext:LanguageToolCodeMatch(code, message)];
            }
            [ZTOOL sentryUploadWithString:LanguageToolCodeMatch(code, message)
                         sentryUploadType:ZSentryUploadTypeHttp
                                errorCode:[NSString stringWithFormat:@"%ld", (long)code]];
            return;
        }

        BOOL userExists = [response[@"data"][@"userExist"] boolValue];
        if (!userExists) {
            [HUD hideHUD];
            NSInteger code = 2036;
            switch (self.dataHandle.currentLoginTypeMenu) {
                case ZLoginTypeMenuPhoneNumber:
                    code = 50001;
                    break;
                case ZLoginTypeMenuEmail:
                    code = 50000;
                    break;
                case ZLoginTypeMenuAccountPassword:
                default:
                    code = 2036;
                    break;
            }
            NSString *text = [NSString stringWithFormat:LanguageToolMatch(@"账号或密码错误，请重新输入，错误码：%@"), @(code)];
            [self.dataHandle.showToastSubject sendNext:text];
            return;
        }

        self.dataHandle.tempParamWhenGetEncrypt = [@{
            @"ticket": @"",
            @"randstr": @"",
            @"captchaVerifyParam": @"",
            @"code": @""
        } mutableCopy];
        [self.dataHandle.getEncryptKeyCommand execute:nil];
    }];
}

/// 订阅阿里与腾讯无痕验证码结果，失败时回退到图文验证码。
- (void)bindInvisibleCaptchaResults {
    @weakify(self)
    [self.dataHandle.getAliCaptchaCommand.executionSignals.switchToLatest subscribeNext:^(id _Nullable value) {
        @strongify(self)
        if (![value isKindOfClass:[NSDictionary class]]) {
            return;
        }
        NSDictionary *response = value;
        if (![response[@"res"] boolValue]) {
            [self.dataHandle setImageCodeViewShow:YES
                                        loginType:self.dataHandle.currentLoginTypeMenu];
            return;
        }

        NSDictionary *captchaData = response[@"captchaData"];
        if (captchaData.count == 0) {
            return;
        }
        NSString *verifyParameter = captchaData[@"captchaVerifyParam"];
        if ([NSString isNil:verifyParameter]) {
            verifyParameter = @"";
        }
        self.dataHandle.tempParamWhenGetEncrypt = [@{
            @"ticket": @"",
            @"randstr": @"",
            @"captchaVerifyParam": verifyParameter,
            @"code": @""
        } mutableCopy];
        [HUD showActivityMessage:@"" inView:self];
        [self.dataHandle.getEncryptKeyCommand execute:nil];
    }];

    [self.dataHandle.getTencentCaptchaCommand.executionSignals.switchToLatest subscribeNext:^(id _Nullable value) {
        @strongify(self)
        if (![value isKindOfClass:[NSDictionary class]]) {
            return;
        }
        NSDictionary *response = value;
        if (![response[@"res"] boolValue]) {
            [self.dataHandle setImageCodeViewShow:YES
                                        loginType:self.dataHandle.currentLoginTypeMenu];
            return;
        }

        NSDictionary *captchaData = response[@"captchaData"];
        if (captchaData.count == 0) {
            return;
        }
        NSString *ticket = captchaData[@"ticket"];
        NSString *randomString = captchaData[@"randstr"];
        if ([NSString isNil:ticket]) {
            ticket = @"";
        }
        if ([NSString isNil:randomString]) {
            randomString = @"";
        }
        self.dataHandle.tempParamWhenGetEncrypt = [@{
            @"ticket": ticket,
            @"randstr": randomString,
            @"captchaVerifyParam": @"",
            @"code": @""
        } mutableCopy];
        [HUD showActivityMessage:@"" inView:self];
        [self.dataHandle.getEncryptKeyCommand execute:nil];
    }];
}

/// 订阅图文验证码显示状态和字符请求结果，并刷新 Swift 输入区域。
- (void)bindImageCaptchaResults {
    @weakify(self)
    [self.dataHandle.changeImageCodeShowStatusSubject subscribeNext:^(id _Nullable value) {
        @strongify(self)
        if (![value isKindOfClass:[NSNumber class]]) {
            return;
        }
        ZLoginAndRegisterTypeMenu loginType = [value intValue];
        BOOL visible = [self.dataHandle getImageCodeStateWithLoginState:loginType];
        [self.loginPageView setCaptchaVisible:visible text:nil loginType:loginType];
        if (visible) {
            [HUD showActivityMessage:@"" inView:self];
            [self.dataHandle.getImgVerCommand execute:nil];
        }
    }];

    [self.dataHandle.getImgVerCommand.executionSignals.switchToLatest subscribeNext:^(id _Nullable value) {
        @strongify(self)
        [ZTOOL doInMain:^{
            [HUD hideHUD];
        }];

        if (![value isKindOfClass:[NSDictionary class]]) {
            return;
        }
        NSDictionary *response = value;
        if (![response[@"res"] boolValue]) {
            NSDictionary *error = response[@"error"];
            if (error) {
                NSInteger code = [error[@"code"] integerValue];
                [self.dataHandle.showToastSubject sendNext:LanguageToolCodeMatch(code, error[@"msg"])];
            }
            return;
        }

        NSString *codeText = response[@"code"];
        if (codeText.length == 0) {
            return;
        }
        ZLoginAndRegisterTypeMenu loginType = self.dataHandle.currentLoginTypeMenu;
        [self.loginPageView setCaptchaVisible:YES text:codeText loginType:loginType];
    }];
}

/// 订阅最终登录结果用于保留原日志行为。
- (void)bindLoginResult {
    [self.dataHandle.loginAccountCommand.executionSignals.switchToLatest subscribeNext:^(id _Nullable value) {
        if ([value boolValue]) {
            CIMLog(@"登陆成功");
        } else {
            CIMLog(@"登陆失败");
        }
    }];
}

/// 执行登录前的协议检查与既有账号密码校验。
- (void)clickLoginBtnAction {
    [self.loginPageView endInputEditing];
    if (!self.loginPageView.policyAccepted) {
        [self showPolicyConfirmation];
        return;
    }

    BOOL available = [self.dataHandle checkLoginAccountInfoAvaliableWhenClickLoginBtn];
    if (!available) {
        return;
    }

    [HUD showActivityMessage:@"" inView:self];
    [self.dataHandle.checkUserIsExistAndHadPasswordCommand execute:nil];
}

/// 展示未勾选协议时的原生确认弹窗，同意后继续当前登录流程。
- (void)showPolicyConfirmation {
    NSString *userAgreement = LanguageToolMatch(@"《用户协议》");
    NSString *privacyAgreement = LanguageToolMatch(@"《隐私协议》");
    NSString *content = [NSString stringWithFormat:LanguageToolMatch(@"请阅读并同意%@和%@"),
                         userAgreement,
                         privacyAgreement];
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:content];
    [attributedText addAttribute:NSForegroundColorAttributeName
                           value:COLOR_5966F2
                           range:[content rangeOfString:userAgreement]];
    [attributedText addAttribute:NSForegroundColorAttributeName
                           value:COLOR_5966F2
                           range:[content rangeOfString:privacyAgreement]];

    NoaAlertTipView *alertView = [NoaAlertTipView new];
    alertView.lblTitle.text = LanguageToolMatch(@"提示");
    alertView.lblContent.text = @"";
    alertView.lblContent.attributedText = attributedText;
    [alertView.btnSure setTitle:LanguageToolMatch(@"同意并继续")
                      forState:UIControlStateNormal];
    [alertView alertTipViewSHow];

    @weakify(self)
    alertView.sureBtnBlock = ^{
        @strongify(self)
        [self.loginPageView updatePolicyAccepted:YES];
        [self clickLoginBtnAction];
    };
}

/// 刷新 Swift 页面中的手机区号。
- (void)refreshShowAreaCode {
    [self.loginPageView setAreaCodeText:[self.dataHandle getAreaCode]];
}

/// 重新读取后端支持的登录方式并回到首个页签。
- (void)reloadSupportLoginType {
    [self.loginPageView configureWithTitles:self.dataHandle.titleArr
                                 loginTypes:self.dataHandle.loginTypeArr
                              selectedIndex:0];
    self.dataHandle.currentLoginTypeMenu = [self.dataHandle getLoginTypeWithIndex:0];
}

@end
