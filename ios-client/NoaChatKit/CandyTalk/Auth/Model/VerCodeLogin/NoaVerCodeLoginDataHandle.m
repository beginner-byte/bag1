//
//  NoaVerCodeLoginDataHandle.m
//  NoaChatKit
//
//  Created by phl on 2025/11/18.
//

#import "NoaVerCodeLoginDataHandle.h"
// 输入内容校验
#import "NoaAuthInputTools.h"
// 弱密码校验
#import "NoaWeakPwdCheckTool.h"
// AppDelegate
#import "AppDelegate.h"
// 加密
#import "LXChatEncrypt.h"

@interface NoaVerCodeLoginDataHandle ()

/// 上个页面传入的用户在账号页面输入的账号，只进行绘制UI时的回显，不用来处理业务
@property (nonatomic, copy, readwrite) NSString *verCodeLoginAccount;

@end

@implementation NoaVerCodeLoginDataHandle

// MARK: set/get

- (RACCommand *)verCodeLoginCommand {
    if (!_verCodeLoginCommand) {
        @weakify(self)
        _verCodeLoginCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
            return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
                NSDictionary *paramDic = input;
                
                // 账号信息-账号+验证码
                NSString *account = [self getAccountText];
                NSString *vercodeStr = [self getVerCodeText];
                
                // 账号信息-登录方式
                // 登录方式转换为接口指定参数
                int loginType = [self covertInterfaceParamWithLoginTypeMenu:self.currentLoginTypeMenu];

                // 账号信息-其他参数
                NSString *ticketStr = @"";
                NSString *randStr = @"";
                NSString *captchaVerifyParamStr = @"";
                // 区号 - 仅手机号码有值
                NSString *areaCode = (self.currentLoginTypeMenu == ZLoginTypeMenuPhoneNumber) ? [self getAreaCode] : @"";
                
                //调用登录接口
                NSMutableDictionary *params = [NSMutableDictionary dictionary];
                [params setObjectSafe:account forKey:@"loginInfo"];
                [params setObjectSafe:@(loginType) forKey:@"loginType"];
                [params setObjectSafe:vercodeStr forKey:@"code"];
                [params setObjectSafe:@"" forKey:@"encryptKey"];
                [params setObjectSafe:areaCode forKey:@"areaCode"];
                [params setObjectSafe:@"" forKey:@"userPw"];
                [params setObjectSafe:@2 forKey:@"type"];
                [params setObjectSafe:@"" forKey:@"loginFailVerifyCode"];
                [params setObjectSafe:ticketStr forKey:@"ticket"];
                [params setObjectSafe:randStr forKey:@"randstr"];
                [params setObjectSafe:captchaVerifyParamStr forKey:@"captchaVerifyParam"];
                
                [IMSDKManager authUserLoginWith:params onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
                    @strongify(self)
                    [self handleLoginSuccess:data
                                     account:account
                                   loginType:loginType];
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
    return _verCodeLoginCommand;
}

- (RACSubject *)startVerCodeCountDownSubject {
    if (!_startVerCodeCountDownSubject) {
        _startVerCodeCountDownSubject = [RACSubject subject];
    }
    return _startVerCodeCountDownSubject;
}

- (instancetype)initWithVerCodeLoginWay:(ZLoginAndRegisterTypeMenu)currentLoginTypeMenu
                               AreaCode:(NSString *)areaCode
                           LoginAccount:(NSString * _Nullable)loginAccount {
    self = [super init];
    if (self) {
        // 赋值当前验证码登录账号方式
        self.currentLoginTypeMenu = currentLoginTypeMenu;
        // 赋值验证码登录账号
        self.verCodeLoginAccount = loginAccount;
        // 赋值areaCode
        [self changeAreaCode:areaCode];
    }
    return self;
}

- (BOOL)checkParamIsAvaliable {
    // 账号、手机号、邮箱号
    NSString *account = [self getAccountText];
    // 验证码
    NSString *verCode = [self getVerCodeText];
    
    switch (self.currentLoginTypeMenu) {
        case ZLoginTypeMenuAccountPassword:
            // 账号登录方式，验证码登录暂不支持，故直接放行
            break;
        case ZLoginTypeMenuPhoneNumber:
            if (![NoaAuthInputTools registerCheckPhoneWithText:account IsShowToast:YES] ||
                ![NoaAuthInputTools checkVerCodeWithText:verCode IsShowToast:YES]) {
                return NO;
            }
            break;
        case ZLoginTypeMenuEmail:
            if (![NoaAuthInputTools registerCheckEmailWithText:account IsShowToast:YES] ||
                ![NoaAuthInputTools checkVerCodeWithText:verCode IsShowToast:YES]) {
                return NO;
            }
            break;
        default:
            break;
    }
    
    // 检查通过
    return YES;
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

/// 重写父类方法
- (NSInteger)getImageCodeType {
    return 2;
}

/// 重写父类方法
- (NSInteger)getVerCodeType {
    return 2;
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

#pragma mark - 登录处理封装方法
/// 处理登录成功
- (void)handleLoginSuccess:(id)data
                   account:(NSString *)account
                 loginType:(int)loginType {
    
    [ZTOOL doInMain:^{
        [HUD hideHUD];
    }];
    
    //登录后
    NoaUserModel *loginUserModel = [NoaUserModel mj_objectWithKeyValues:data];
    [NoaUserModel savePreAccount:account Type:loginType];
    [UserManager setUserInfo:loginUserModel];
    
    //socket用户登录连接
    NoaIMSDKUserOptions *userOption = [NoaIMSDKUserOptions new];
    userOption.userToken = loginUserModel.token;
    userOption.userID = loginUserModel.userUID;
    userOption.userNickname = loginUserModel.nickname;
    userOption.userAvatar = loginUserModel.avatar;
    [IMSDKManager configSDKUserWith:userOption];
    
    [NoaWeakPwdCheckTool sharedInstance].userPwd = @"";
    // 登录成功
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [delegate loginSuccess];
}

/// 处理错误信息
/// - Parameters:
///   - errorCode: 接口返回的错误码
///   - errorMsg: 接口返回的消息
- (void)handleLoginError:(NSInteger)errorCode
                     msg:(NSString *)errorMsg {
    @weakify(self)
    
    [ZTOOL doInMain:^{
        [HUD hideHUD];
    }];
    
    // 兜底提示
    [self.showToastSubject sendNext:LanguageToolCodeMatch(errorCode, errorMsg)];
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
