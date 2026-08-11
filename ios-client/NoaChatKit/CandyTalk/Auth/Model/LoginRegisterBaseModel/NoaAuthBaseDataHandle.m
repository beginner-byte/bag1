//
//  NoaAuthBaseDataHandle.m
//  NoaChatKit
//
//  Created by phl on 2025/11/18.
//

#import "NoaAuthBaseDataHandle.h"
// 阿里、腾讯验证
#import "NoaCaptchaCodeTools.h"
// 输入内容校验
#import "NoaAuthInputTools.h"

@interface NoaAuthBaseDataHandle ()

/// 手机号码 - 区号
@property (nonatomic, copy) NSString *areaCode;

/// 阿里、腾讯验证
@property (nonatomic, strong) NoaCaptchaCodeTools *captchaTools;

@end

@implementation NoaAuthBaseDataHandle

// MARK: set/get

- (RACSubject *)showToastSubject {
    if (!_showToastSubject) {
        _showToastSubject = [RACSubject subject];
    }
    return _showToastSubject;
}

- (RACSubject *)showImgVerCodeSubject {
    if (!_showImgVerCodeSubject) {
        _showImgVerCodeSubject = [RACSubject subject];
    }
    return _showImgVerCodeSubject;
}

- (RACSubject *)jumpChangeAreaCodeSubject {
    if (!_jumpChangeAreaCodeSubject) {
        _jumpChangeAreaCodeSubject = [RACSubject subject];
    }
    return _jumpChangeAreaCodeSubject;
}

- (NoaCaptchaCodeTools *)captchaTools {
    if (!_captchaTools) {
        _captchaTools = [[NoaCaptchaCodeTools alloc] init];
        _captchaTools.aliyunVerNum = 0;
    }
    return _captchaTools;
}

#pragma mark - Command Implementations

- (RACCommand *)getEncryptKeyCommand {
    if (!_getEncryptKeyCommand) {
        _getEncryptKeyCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
            return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
//                [HUD showSuccessMessage:@"_getEncryptKeyCommand" ];
                [IMSDKManager authGetEncryptKeySuccess:^(id  _Nullable data, NSString * _Nullable traceId) {
                    if (![data isKindOfClass:[NSString class]]) {
                        [subscriber sendNext:@{
                            @"res": @(NO),
                        }];
                        [subscriber sendCompleted];
                        return;
                    }
                    
                    [subscriber sendNext:@{
                        @"res": @(YES),
                        @"data": [NSString isNil:data] ? @"" : data,
                    }];
                    [subscriber sendCompleted];
                    
                } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
                    
                    [subscriber sendNext:@{
                        @"res": @(NO),
                        @"error": @{
                            @"code" : @(code),
                            @"msg" : [NSString isNil:msg] ? @"" : msg,
                        },
                    }];
                    [subscriber sendCompleted];
                    
                }];
                
                return [RACDisposable disposableWithBlock:^{
                    
                }];
            }];
        }];
    }
    return _getEncryptKeyCommand;
}

- (RACCommand *)getImgVerCommand {
    if (!_getImgVerCommand) {
        @weakify(self)
        _getImgVerCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
            return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
                @strongify(self)
                
                NSString *account = [self getAccountText];
                NSInteger verCodeType = [self getImageCodeType];
                
                NSMutableDictionary *params = [NSMutableDictionary dictionary];
                [params setValue:account forKey:@"loginName"];
                [params setValue:@(verCodeType) forKey:@"type"];
                
                [IMSDKManager authGetImgVerCodeWith:params
                                          onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
                    if (![data isKindOfClass:[NSString class]]) {
                        [subscriber sendNext:@{
                            @"res": @NO,
                        }];
                        [subscriber sendCompleted];
                        return;
                    }
                    
                    NSString *codeStr = data;
                    if ([NSString isNil:codeStr]) {
                        // 为空异常
                        [subscriber sendNext:@{
                            @"res": @NO,
                        }];
                    }else {
                        [subscriber sendNext:@{
                            @"res": @YES,
                            @"code": codeStr,
                        }];
                    }
                    [subscriber sendCompleted];
                } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
                    [subscriber sendNext:@{
                        @"res": @NO,
                        @"error": @{
                            @"code" : @(code),
                            @"msg" : [NSString isNil:msg] ? @"" : msg,
                        }
                    }];
                    [subscriber sendCompleted];
                }];
                
                return [RACDisposable disposableWithBlock:^{
                    
                }];
            }];
        }];
    }
    return _getImgVerCommand;
}

- (RACCommand *)getTencentCaptchaCommand {
    if (!_getTencentCaptchaCommand) {
        @weakify(self)
        _getTencentCaptchaCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
            return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
                @strongify(self)
                
                [self startTencentCaptchaVerificationWithSuccessResult:^(NSString *ticket, NSString *randstr) {
                    [subscriber sendNext:@{
                        @"res": @YES,
                        @"captchaData": @{
                            @"ticket": ticket,
                            @"randstr": randstr,
                        }
                    }];
                    [subscriber sendCompleted];
                } FailResult:^{
                    [subscriber sendNext:@{
                        @"res": @NO,
                    }];
                    [subscriber sendCompleted];
                }];
                
                return [RACDisposable disposableWithBlock:^{
                    
                }];
            }];
        }];
    }
    return _getTencentCaptchaCommand;
}

- (RACCommand *)getAliCaptchaCommand {
    if (!_getAliCaptchaCommand) {
        @weakify(self)
        _getAliCaptchaCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
            return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
                @strongify(self)
                
                // 默认第一次验证
                BOOL isFirstVerCaptcha = YES;
                if (input && [input isKindOfClass:[NSNumber class]]) {
                    isFirstVerCaptcha = [input boolValue];
                }
                
                [self startAliCaptchaVerificationWithIsFirstVerCaptcha:isFirstVerCaptcha SuccessResult:^(NSString *captchaVerifyParam) {
                    [subscriber sendNext:@{
                        @"res": @YES,
                        @"captchaData": @{
                            @"captchaVerifyParam": captchaVerifyParam,
                        }
                    }];
                    [subscriber sendCompleted];
                } FailResult:^{
                    [subscriber sendNext:@{
                        @"res": @NO,
                    }];
                    [subscriber sendCompleted];
                }];
                
                return [RACDisposable disposableWithBlock:^{
                    
                }];
            }];
        }];
    }
    return _getAliCaptchaCommand;
}

- (RACCommand *)getVerCommand {
    if (!_getVerCommand) {
        _getVerCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
            return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
                NSMutableDictionary *verCodeParamDic = [NSMutableDictionary dictionaryWithDictionary:input];
                
                [IMSDKManager authGetPhoneEmailVerCodeWith:verCodeParamDic onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
                    [subscriber sendNext:@{
                        @"res": @YES,
                    }];
                    [subscriber sendCompleted];
                } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
                    [subscriber sendNext:@{
                        @"res": @NO,
                        @"error": @{
                            @"code" : @(code),
                            @"msg" : [NSString isNil:msg] ? @"" : msg,
                        }
                    }];
                    
                    [subscriber sendCompleted];
                }];
                
                return [RACDisposable disposableWithBlock:^{
                    
                }];
            }];
        }];
    }
    return _getVerCommand;
}

- (RACCommand *)checkUserIsExistCommand {
    if (!_checkUserIsExistCommand) {
        @weakify(self)
        _checkUserIsExistCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
            return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
                @strongify(self)
                // 账号
                NSString *account = [self getAccountText];
                // 手机号-区号
                NSString *areaCode = (self.currentLoginTypeMenu == ZLoginTypeMenuPhoneNumber ? [self getAreaCode] : @"");
                // 注册方式转换为接口指定参数
                int loginType = [self covertInterfaceParamWithLoginTypeMenu:self.currentLoginTypeMenu];
                //调用登录接口
                NSMutableDictionary *params = [NSMutableDictionary new];
                [params setObjectSafe:account forKey:@"loginInfo"];
                [params setObjectSafe:@(loginType) forKey:@"loginType"];
                [params setObjectSafe:areaCode forKey:@"areaCode"];
                
                [IMSDKManager authUserExistWith:params onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
                    BOOL exist = NO;
                    if ([data isKindOfClass:[NSNumber class]]) {
                        exist = [data boolValue];
                    }
                    
                    [subscriber sendNext:@{
                        @"res": @(YES),
                        @"data": @(exist),
                    }];
                    [subscriber sendCompleted];
                
                } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
                    [subscriber sendNext:@{
                        @"res": @(NO),
                        @"error": @{
                            @"code" : @(code),
                            @"msg" : [NSString isNil:msg] ? @"" : msg,
                        },
                    }];
                    [subscriber sendCompleted];
                }];
                
                return [RACDisposable disposableWithBlock:^{
                    
                }];
            }];
        }];
    }
    return _checkUserIsExistCommand;
}

- (RACCommand *)checkUserIsExistAndHadPasswordCommand {
    if (!_checkUserIsExistAndHadPasswordCommand) {
        @weakify(self)
        _checkUserIsExistAndHadPasswordCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
            return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
                @strongify(self)
                // 账号
                NSString *account = [self getAccountText];
                // 手机号-区号
                NSString *areaCode = (self.currentLoginTypeMenu == ZLoginTypeMenuPhoneNumber ? [self getAreaCode] : @"");
                // 注册方式转换为接口指定参数
                int loginType = [self covertInterfaceParamWithLoginTypeMenu:self.currentLoginTypeMenu];
                //调用登录接口
                NSMutableDictionary *params = [NSMutableDictionary new];
                [params setObjectSafe:account forKey:@"loginInfo"];
                [params setObjectSafe:@(loginType) forKey:@"loginType"];
                [params setObjectSafe:areaCode forKey:@"areaCode"];
                
                [IMSDKManager authUserExistAndHasPwdWith:params onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
                    BOOL userExist = NO;
                    BOOL passwordExist = NO;
                    if ([data isKindOfClass:[NSDictionary class]]) {
                        NSDictionary *dataDic = data;
                        userExist = [[dataDic objectForKey:@"userExit"] boolValue];
                        passwordExist = [[dataDic objectForKey:@"pwdExit"] boolValue];
                    }
                    
                    [subscriber sendNext:@{
                        @"res": @(YES),
                        @"data": @{
                            @"userExist": @(userExist),
                            @"passwordExist": @(passwordExist)
                        },
                    }];
                    [subscriber sendCompleted];
                
                } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
                    [subscriber sendNext:@{
                        @"res": @(NO),
                        @"error": @{
                            @"code" : @(code),
                            @"msg" : [NSString isNil:msg] ? @"" : msg,
                        },
                    }];
                    [subscriber sendCompleted];
                }];
                
                return [RACDisposable disposableWithBlock:^{
                    
                }];
            }];
        }];
    }
    return _checkUserIsExistAndHadPasswordCommand;
}

// MARK: init
- (instancetype)init {
    self = [super init];
    if (self) {
        self.areaCode = @"+86";
    }
    return self;
}

#pragma mark - Public Methods

- (void)showImgVerCodePopWindowWithCode:(NSString *)code {
    // 失败，展示图文验证码(设置sdk当前验证方式为图文)
    [IMSDKManager configSDKCaptchaChannel:2];
    // 展示图文验证码弹窗
    [self.showImgVerCodeSubject sendNext:@{
        @"code": code,
        @"verCodeType": @([self getImageCodeType])
    }];
}

- (void)resetSDKCaptchaChannel {
    [IMSDKManager configSDKCaptchaChannel:ZHostTool.appSysSetModel.captchaChannel];
    self.captchaTools.aliyunVerNum = 0;
}

- (int)covertInterfaceParamWithLoginTypeMenu:(ZLoginAndRegisterTypeMenu)loginTypeMenu {
    switch (loginTypeMenu) {
        case ZLoginTypeMenuAccountPassword:
            return UserAuthTypeAccount;
        case ZLoginTypeMenuPhoneNumber:
            return UserAuthTypePhone;
        case ZLoginTypeMenuEmail:
            return UserAuthTypeEmail;
        default:
            return UserAuthTypeAccount;
    }
}

/// 获取是否支持邀请码
- (BOOL)getInviteCodeSupportState {
    return ZHostTool.appSysSetModel.registerInviteCode;
    return ![ZHostTool.appSysSetModel.isMustInviteCode isEqualToString:@"0"];
}

- (NSString *)getAccountText {
    NSString *key = @"";
    switch (self.currentLoginTypeMenu) {
        case ZLoginTypeMenuAccountPassword:
            key = kLoginModuleParamAccountKey;
            break;
        case ZLoginTypeMenuPhoneNumber:
            key = kLoginModuleParamPhoneNumberKey;
            break;
        case ZLoginTypeMenuEmail:
            key = kLoginModuleParamEmailKey;
            break;
        default:
            return @"";
            break;
    }
    return [self getTextWithKey:key];
}

- (NSString *)getPasswordText {
    NSString *key = kLoginModuleParamPasswordKey;
    return [self getTextWithKey:key];
}

- (NSString *)getConfirmPasswordText {
    NSString *key = kLoginModuleParamConfirmPasswordKey;
    return [self getTextWithKey:key];
}

- (NSString *)getVerCodeText {
    NSString *key = kLoginModuleParamVerCodeKey;
    return [self getTextWithKey:key];
}

- (NSString *)getImgVerCodeText {
    NSString *key = kLoginModuleParamImgCodeKey;
    return [self getTextWithKey:key];
}

- (NSString *)getInviteCodeText {
    // 不允许设置邀请码，直接返回@""
    if (![self getInviteCodeSupportState]) {
        return @"";
    }
    NSString *key = kLoginModuleParamInviteCodeKey;
    return [self getTextWithKey:key];
}

- (NSString *)getTextWithKey:(NSString *)key {
    if (!self.getInputTextBlock) {
        return @"";
    }
    
    if (key.length == 0) {
        return @"";
    }
    
    NSDictionary *textDict = self.getInputTextBlock(self.currentLoginTypeMenu);
    if (textDict.count == 0) {
        return @"";
    }
    
    NSString *text = textDict[key];
    return [NSString isNil:text] ? @"" : text;
}

- (NSInteger)getImageCodeType {
    NSAssert(NO, @"子类必须实现 getImageCodeType 方法");
    return 0;
}

- (NSInteger)getVerCodeType {
    NSAssert(NO, @"子类必须实现 getVerCodeType 方法");
    return 0;
}

- (NSString *)getAccountKeyForImageCode {
    switch (self.currentLoginTypeMenu) {
        case ZLoginTypeMenuAccountPassword:
            return kLoginModuleParamAccountKey;
        case ZLoginTypeMenuPhoneNumber:
            return kLoginModuleParamPhoneNumberKey;
        case ZLoginTypeMenuEmail:
            return kLoginModuleParamEmailKey;
        default:
            return @"";
    }
}

- (NSString *)getAreaCode {
    if ([NSString isNil:self.areaCode]) {
        return @"+86";
    }
    
    if ([self.areaCode isEqualToString:@"+"]) {
        return @"+86";
    }
    
    if (![self.areaCode hasPrefix:@"+"]) {
        return @"+86";
    }
    
    return self.areaCode;
}

- (void)changeAreaCode:(NSString *)areaCode {
    if ([NSString isNil:areaCode]) {
        return;
    }
    self.areaCode = areaCode;
}

// MARK: 阿里-腾讯无痕验证
/// 启动腾讯验证码验证（无痕验证）
/// @param successResult 成功回调
/// @param failResult 失败回调
- (void)startTencentCaptchaVerificationWithSuccessResult:(void (^)(NSString *ticket, NSString *randstr))successResult
                                              FailResult:(void (^)(void))failResult {
    // 设置腾讯云验证成功回调
    [self.captchaTools setTencentCaptchaResultSuccess:successResult];
    
    // 设置验证失败回调
    [self.captchaTools setCaptchaResultFail:failResult];
    
    // 启动验证码验证
    [self.captchaTools verCaptchaCode];
}

/// 启动阿里验证码验证（无痕验证）
/// @param successResult 成功回调
/// @param failResult 失败回调
- (void)startAliCaptchaVerificationWithIsFirstVerCaptcha:(BOOL)isFirst
                                           SuccessResult:(void (^)(NSString *captchaVerifyParam))successResult
                                              FailResult:(void (^)(void))failResult {
    // 设置阿里云验证成功回调
    [self.captchaTools setAliyunCaptchaResultSuccess:successResult];
    
    // 设置验证失败回调
    [self.captchaTools setCaptchaResultFail:failResult];
    
    if (isFirst) {
        // 重置验证次数
        self.captchaTools.aliyunVerNum = 0;
        // 启动验证码验证
        [self.captchaTools verCaptchaCode];
    }else {
        // 重试
        if (self.captchaTools.aliyunVerNum < 3) {
            [self.captchaTools secondVerCaptchaCode];
        }else {
            // 直接失败
            if (failResult) {
                failResult();
            }
        }
    }
}

// MARK: 格式校验
+ (void)checkAccountInputWithRegisterType:(ZLoginAndRegisterTypeMenu)registerType
                             AccountInput:(NSString *)accountInputString
                           WhenEditFinish:(void (^)(BOOL, NSString * _Nullable))resultFunc {
    NSString *accountStr = [NSString isNil:accountInputString] ? @"" : accountInputString;
    if (registerType == ZLoginTypeMenuAccountPassword) {
        if (![NoaAuthInputTools registerCheckInputAccountEndWithTextFormat:accountStr]) {
            if (resultFunc) {
                resultFunc(NO, LanguageToolMatch(@"帐号前两位必须为英文，只支持英文或数字"));
            }
            return;
        }
        
        if (![NoaAuthInputTools registerCheckInputAccountEndWithTextLength:accountStr]) {
            if (resultFunc) {
                resultFunc(NO, LanguageToolMatch(@"帐号长度6～16位"));
            }
            return;
        }
        
        if (resultFunc) {
            resultFunc(YES, @"");
        }
    } else if (registerType == ZLoginTypeMenuEmail) {
        if (![NoaAuthInputTools registerCheckEmailWithText:accountStr IsShowToast:NO]) {
            if (resultFunc) {
                resultFunc(NO, LanguageToolMatch(@"请输入正确的邮箱格式，如：google@mail.com"));
            }
            return;
        }
        
        if (resultFunc) {
            resultFunc(YES, @"");
        }
    } else if (registerType == ZLoginTypeMenuPhoneNumber) {
        if (![NoaAuthInputTools registerCheckPhoneWithText:accountStr IsShowToast:NO]) {
            if (resultFunc) {
                resultFunc(NO, LanguageToolMatch(@"请输入有效的手机号码"));
            }
            return;
        }
        
        if (resultFunc) {
            resultFunc(YES, @"");
        }
    } else {
        // 未知类型，按通过处理
        if (resultFunc) {
            resultFunc(YES, @"");
        }
    }
}

+ (void)checkPasswordInputWithRegisterType:(ZLoginAndRegisterTypeMenu)registerType
                             PasswordInput:(NSString *)passwordInputString
                            WhenEditFinish:(void (^)(BOOL, NSString * _Nullable))resultFunc {
    NSString *passwordStr = [NSString isNil:passwordInputString] ? @"" : passwordInputString;
    if (![NoaAuthInputTools checkCreatPasswordEndWithTextLength:passwordStr]) {
        if (resultFunc) {
            resultFunc(NO, LanguageToolMatch(@"密码长度6-16"));
        }
        return;
    } else {
        // 通过
        if (resultFunc) {
            resultFunc(YES, @"");
        }
    }
}

+ (void)checkConfirmPasswordInputWithRegisterType:(ZLoginAndRegisterTypeMenu)registerType
                                    PasswordInput:(NSString *)passwordInputString
                             ConfirmPasswordInput:(NSString *)confirmPasswordInputString
                                   WhenEditFinish:(void (^)(BOOL, NSString * _Nullable))resultFunc {
    NSString *passwordStr = [NSString isNil:passwordInputString] ? @"" : passwordInputString;
    NSString *confirmPasswordStr = [NSString isNil:confirmPasswordInputString] ? @"" : confirmPasswordInputString;
    if (![passwordStr isEqualToString:confirmPasswordStr]) {
        if (resultFunc) {
            resultFunc(NO, LanguageToolMatch(@"密码不一致"));
        }
        return;
    }
    
    // 通过
    if (resultFunc) {
        resultFunc(YES, @"");
    }
}

+ (void)checkVerCodeInputWithRegisterType:(ZLoginAndRegisterTypeMenu)registerType
                             VerCodeInput:(NSString *)verCodeInputString
                           WhenEditFinish:(void (^)(BOOL, NSString * _Nullable))resultFunc {
    NSString *verCodeStr = [NSString isNil:verCodeInputString] ? @"" : verCodeInputString;
    if (![NoaAuthInputTools checkVerCodeWithText:verCodeStr IsShowToast:NO]) {
        if (resultFunc) {
            resultFunc(NO, LanguageToolMatch(@"请输入验证码"));
        }
        return;
    }
    
    // 通过
    if (resultFunc) {
        resultFunc(YES, @"");
    }
}

+ (void)checkInviteCodeInputWithRegisterType:(ZLoginAndRegisterTypeMenu)registerType
                             InviteCodeInput:(NSString *)inviteCodeInputString
                              WhenEditFinish:(void (^)(BOOL, NSString * _Nullable))resultFunc {
    NSString *inviteCodeStr = [NSString isNil:inviteCodeInputString] ? @"" : inviteCodeInputString;
    if (![NoaAuthInputTools checkInviteCodeWithText:inviteCodeStr IsShowToast:NO]) {
        if (resultFunc) {
            resultFunc(NO, LanguageToolMatch(@"邀请码不能为空"));
        }
        return;
    }
    
    // 通过
    if (resultFunc) {
        resultFunc(YES, @"");
    }
}

- (BOOL)checkUserParamIsAvaliable {
    // 账号、手机号、邮箱号
    NSString *account = [self getAccountText];
    // 检测内容
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
            if (![NoaAuthInputTools registerCheckPhoneWithText:account IsShowToast:YES]) {
                return NO;
            }
            break;
        case ZLoginTypeMenuEmail:
            if (![NoaAuthInputTools registerCheckEmailWithText:account IsShowToast:YES]) {
                return NO;
            }
            break;
        default:
            break;
    }
    
    return YES;
}

- (BOOL)checkGetVerCodeParamIsAvaliable {
    // 账号、手机号、邮箱号
    NSString *account = [self getAccountText];
    // 检测内容
    switch (self.currentLoginTypeMenu) {
        case ZLoginTypeMenuAccountPassword:
            // 账号密码不支持获取验证码，故不判断-UI隐藏处理
            break;
        case ZLoginTypeMenuPhoneNumber:
            if (![NoaAuthInputTools registerCheckPhoneWithText:account IsShowToast:YES]) {
                return NO;
            }
            break;
        case ZLoginTypeMenuEmail:
            if (![NoaAuthInputTools registerCheckEmailWithText:account IsShowToast:YES]) {
                return NO;
            }
            break;
        default:
            break;
    }
    
    return YES;
}

@end

