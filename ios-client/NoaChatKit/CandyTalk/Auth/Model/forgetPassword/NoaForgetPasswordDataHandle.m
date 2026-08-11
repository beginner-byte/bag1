//
//  NoaForgetPasswordDataHandle.m
//  NoaChatKit
//
//  Created by phl on 2025/11/17.
//

#import "NoaForgetPasswordDataHandle.h"
// 输入内容校验
#import "NoaAuthInputTools.h"
// 弱密码校验
#import "NoaWeakPwdCheckTool.h"
// AppDelegate
#import "AppDelegate.h"
// 加密
#import "LXChatEncrypt.h"

@interface NoaForgetPasswordDataHandle ()

/// 标题
@property (nonatomic, copy, readwrite) NSString *title;

/// 上个页面传入的用户在账号页面输入的账号，只进行绘制UI时的回显，不用来处理业务
@property (nonatomic, copy, readwrite) NSString *resetAccount;

@end

@implementation NoaForgetPasswordDataHandle

// MARK: set/get

- (RACCommand *)resetPasswordAndLoginCommand {
    if (!_resetPasswordAndLoginCommand) {
        @weakify(self)
        _resetPasswordAndLoginCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
            return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
                // 获取加密密钥
                NSString *encryptKey = input;
                // 获取密码
                NSString *password = [self getPasswordText];
                //AES对称加密后的密码
                NSString *passwordKey = [NSString stringWithFormat:@"%@%@", encryptKey, password];
                NSString *passwordEncryptKey = [LXChatEncrypt method4:passwordKey];
                if ([NSString isNil:passwordEncryptKey]) {
                    [ZTOOL doInMain:^{
                        [HUD hideHUD];
                    }];
                    [self.showToastSubject sendNext:[NSString stringWithFormat:@"%@～", LanguageToolMatch(@"操作失败")]];
                    
                    [subscriber sendNext:@NO];
                    [subscriber sendCompleted];
                    
                    return [RACDisposable disposableWithBlock:^{
                        
                    }];
                }
                
                // 账号信息
                // 账号信息-账号+手机验证码+邀请码
                NSString *account = [self getAccountText];
                NSString *verCode = [self getVerCodeText];
                
                // 区号 - 仅手机号码有值
                NSString *areaCode = (self.currentLoginTypeMenu == ZLoginTypeMenuPhoneNumber) ? [self getAreaCode] : @"";
                
                // 注册方式转换为接口指定参数
                int loginType = [self covertInterfaceParamWithLoginTypeMenu:self.currentLoginTypeMenu];
                
                //调用登录接口
                NSMutableDictionary *params = [NSMutableDictionary dictionary];
                [params setObjectSafe:account forKey:@"loginInfo"];
                [params setObjectSafe:@(loginType) forKey:@"loginType"];
                [params setObjectSafe:verCode forKey:@"code"];
                [params setObjectSafe:encryptKey forKey:@"encryptKey"];
                [params setObjectSafe:passwordEncryptKey forKey:@"userPw"];
                [params setObjectSafe:@3 forKey:@"type"];
                [params setObjectSafe:areaCode forKey:@"areaCode"];
                
                [IMSDKManager authResetPasswordWith:params onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
                    @strongify(self)
                    
                    [self handleRegisterSuccess:data
                                        account:account
                                      loginType:loginType
                                       password:password];
                    
                    [subscriber sendNext:@YES];
                    [subscriber sendCompleted];
                } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
                    @strongify(self)
                    
                    [self handleResetPasswordError:code
                                               msg:msg];
                    
                    [subscriber sendNext:@NO];
                    [subscriber sendCompleted];
                }];
                
                return [RACDisposable disposableWithBlock:^{
                    
                }];
            }];
        }];
    }
    return _resetPasswordAndLoginCommand;
}

- (RACSubject *)startVerCodeCountDownSubject {
    if (!_startVerCodeCountDownSubject) {
        _startVerCodeCountDownSubject = [RACSubject subject];
    }
    return _startVerCodeCountDownSubject;
}

- (instancetype)initWithResetPasswordWay:(ZLoginAndRegisterTypeMenu)currentForgetPasswordWay
                                AreaCode:(NSString *)areaCode
                            ResetAccount:(NSString *)resetAccount {
    self = [super init];
    if (self) {
        // 赋值当前重置账号方式
        self.currentLoginTypeMenu = currentForgetPasswordWay;
        // 赋值重置账号
        self.resetAccount = resetAccount;
        // 赋值areaCode
        [self changeAreaCode:areaCode];
        
        NSString *title = [NSString stringWithFormat:LanguageToolMatch(@"使用%@设置新密码"),[NSString getAuthContetnWithAuthType:[self covertInterfaceParamWithLoginTypeMenu:self.currentLoginTypeMenu]]];
        self.title = title;
    }
    return self;
}

- (BOOL)checkParamIsAvaliable {
    // 账号、手机号、邮箱号
    NSString *account = [self getAccountText];
    // 验证码
    NSString *verCode = [self getVerCodeText];
    // 密码
    NSString *password = [self getPasswordText];
    // 确认密码
    NSString *confirmPassword = [self getConfirmPasswordText];
    
    switch (self.currentLoginTypeMenu) {
        case ZLoginTypeMenuAccountPassword:
            if (![NoaAuthInputTools registerCheckInputAccountEndWithTextFormat:account]) {
                [self.showToastSubject sendNext:LanguageToolMatch(@"帐号前两位必须为英文，只支持英文或数字")];
                return NO;
            }
            
            if (![NoaAuthInputTools registerCheckInputAccountEndWithTextLength:account]) {
                [self.showToastSubject sendNext:LanguageToolMatch(@"帐号长度6～16位")];
                return NO;
            }
            break;
        case ZLoginTypeMenuPhoneNumber:
            if (![NoaAuthInputTools registerCheckPhoneWithText:account IsShowToast:YES] ||
                ![NoaAuthInputTools checkVerCodeWithText:verCode IsShowToast:YES]) {
                return NO;
            }
            break;
        case ZLoginTypeMenuEmail:
            if (![NoaAuthInputTools registerCheckEmailWithText:account IsShowToast:YES] ||
                ![NoaAuthInputTools checkVerCodeWithText:verCode IsShowToast:YES] ||
                ![NoaAuthInputTools checkPasswordWithText:password IsShowToast:YES] ||
                ![NoaAuthInputTools checkPasswordWithText:confirmPassword IsShowToast:YES]) {
                return NO;
            }
            break;
        default:
            break;
    }
    
    // 检查密码合规性
    if (![NoaAuthInputTools checkCreatPasswordEndWithTextLength:password] ||
        ![NoaAuthInputTools checkCreatPasswordEndWithTextLength:confirmPassword]) {
        if (ZHostTool.appSysSetModel.checkEnglishSymbol) {
            [self.showToastSubject sendNext:LanguageToolMatch(@"密码长度6-16位，须包含字母、数字和字符")];
        } else {
            [self.showToastSubject sendNext:LanguageToolMatch(@"密码长度6-16位，须包含字母、数字")];
        }
        
        return NO;
    }
    
    // 检查两次密码是否输入一致
    if (![password isEqualToString:confirmPassword]) {
        [self.showToastSubject sendNext:LanguageToolMatch(@"密码不一致")];
        return NO;
    }
    
    // 检查通过
    return YES;
}

/// 重写父类方法
- (NSInteger)getImageCodeType {
    return 3;
}

/// 重写父类方法
- (NSInteger)getVerCodeType {
    return 3;
}

- (NSDictionary *)getVerCodeParamWithImgCode:(NSString *)imgVerCode
                                      Ticket:(NSString *)ticket
                                     Randstr:(NSString *)randstr
                          CaptchaVerifyParam:(NSString *)captchaVerifyParam {
    NSString *account = [self getAccountText];
    int loginType = [self covertInterfaceParamWithLoginTypeMenu:self.currentLoginTypeMenu];
    NSInteger type = [self getVerCodeType];
    NSString *areaCode = [self getAreaCode];
    
    NSDictionary *paramDic = @{
        @"loginInfo": account,
        @"loginType": @(loginType),
        @"type": @(type),
        @"areaCode": areaCode,
        @"code": imgVerCode,
        @"ticket": ticket,
        @"randstr": randstr,
        @"captchaVerifyParam": captchaVerifyParam,
    };
    return paramDic;
}

#pragma mark - 注册处理封装方法

/// 处理用户重置密码成功
- (void)handleRegisterSuccess:(id)data
                      account:(NSString *)account
                    loginType:(int)loginType
                     password:(NSString *)password {
    
    [ZTOOL doInMain:^{
        [HUD hideHUD];
    }];
    
    if(![data isKindOfClass:[NSDictionary class]]){
        [self.showToastSubject sendNext:LanguageToolMatch(@"重置密码失败！")];
        return;
    }
    
    [self.showToastSubject sendNext:LanguageToolMatch(@"登录成功")];
    NoaUserModel *registerUserModel = [NoaUserModel mj_objectWithKeyValues:data];
    [registerUserModel saveUserInfo];
    [NoaUserModel savePreAccount:account Type:loginType];
    [UserManager setUserInfo:registerUserModel];
    
    //socket用户登录连接
    NoaIMSDKUserOptions *userOption = [NoaIMSDKUserOptions new];
    userOption.userToken = UserManager.userInfo.token;
    userOption.userID = UserManager.userInfo.userUID;
    userOption.userNickname = UserManager.userInfo.nickname;
    userOption.userAvatar = UserManager.userInfo.avatar;
    [IMSDKManager configSDKUserWith:userOption];
    
    [NoaWeakPwdCheckTool sharedInstance].userPwd = password;
    
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    // 用户重置密码并登录成功后调用
    [delegate loginSuccess];
}


/// 处理错误信息
/// - Parameters:
///   - errorCode: 接口返回的错误码
///   - errorMsg: 接口返回的消息
- (void)handleResetPasswordError:(NSInteger)errorCode
                             msg:(NSString *)errorMsg {
    [ZTOOL doInMain:^{
        [HUD hideHUD];
    }];
    
  if (errorCode == LingIMHttpResponseCodeUsedIpDisabled) {
        //注册不在白名单内，需展示IP地址
        [self.showToastSubject sendNext:[NSString stringWithFormat:LanguageToolMatch(@"登录IP：%@ 不在白名单内"), errorMsg]];
    } else {
        // 账号密码or其他
        [self.showToastSubject sendNext:LanguageToolCodeMatch(errorCode, errorMsg)];
    }
}

/// 处理获取短信、邮箱验证码错误
/// - Parameters:
///   - errorCode: 接口返回的错误码
///   - errorMsg:  接口返回的消息
- (void)handleGerVerCodeError:(NSInteger)errorCode
                          msg:(NSString *)errorMsg {
    if (errorCode == Auth_User_Capcha_Error_Code) {
        //51002：阿里云验证异常，需进行二次验证(图形验证码)
        [self.getAliCaptchaCommand execute:@NO];
    } else if (errorCode == Auth_User_Capcha_TimeOut_Code) {
        //51006：阿里云验证超时，展示图文验证码
        // 获取图文验证码
        [self showImgVerCodePopWindowWithCode:@""];
    } else if (errorCode == Auth_User_Capcha_ChangeImgVer_Code) {
        //图形验证码不正确，请重新输入
        [self.showToastSubject sendNext:LanguageToolMatch(@"验证码不正确，请重新输入")];
        // 获取图文验证码
        [self showImgVerCodePopWindowWithCode:@""];
    } else {
        [self.showToastSubject sendNext:LanguageToolCodeMatch(errorCode, errorMsg)];
        [ZTOOL sentryUploadWithString:LanguageToolCodeMatch(errorCode, errorMsg) sentryUploadType:ZSentryUploadTypeHttp errorCode:[NSString stringWithFormat:@"%ld",(long)errorCode]];

    }
}

@end
