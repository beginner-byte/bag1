//
//  NoaFindPasswordViewController.m
//  NoaKit
//
//  Created by Candy on 2023/3/28.
//

#import "NoaFindPasswordViewController.h"
#import "NoaInputTextView.h"
#import "NoaCountryCodeViewController.h"
#import "NoaToolManager.h"
#import "AppDelegate.h"
#import "AppDelegate+DB.h"
#import "AppDelegate+MediaCall.h"
#import "AppDelegate+MiniApp.h"
#import "NoaAuthInputTools.h"
#import "LXChatEncrypt.h"
#import "NoaImgVerCodeView.h"
#import "NoaCaptchaCodeTools.h"
#import "NoaWeakPwdCheckTool.h"

@interface NoaFindPasswordViewController ()

@property (nonatomic, strong)NoaInputTextView *accountInput;
@property (nonatomic, strong)NoaInputTextView *vercodeInput;
@property (nonatomic, strong)NoaInputTextView *passwordInput;
@property (nonatomic, strong)NoaInputTextView *confimPasswordInput;
@property (nonatomic, strong)UILabel *tipLbl;
@property (nonatomic, strong)UILabel *dynamicTipLbl;
@property (nonatomic, strong)UIButton *loginBtn;
@property (nonatomic, strong)NoaCaptchaCodeTools *captchaTools;

@end

@implementation NoaFindPasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupNavBar];
    [self setupUI];
    [self setupLocalData];
}

#pragma mark - NavBar
- (void)setupNavBar {
    self.navBtnBack.hidden = NO;
    self.navBtnRight.hidden = YES;
    self.navTitleLabel.hidden = YES;
    self.navLineView.hidden = YES;
}

#pragma mark - UI
- (void)setupUI {
    NSString *titleStr = [NSString stringWithFormat:LanguageToolMatch(@"使用%@设置新密码"),[NSString getAuthContetnWithAuthType:self.findPasswordWay]];
    
    UILabel *titleLab = [[UILabel alloc] init];
    titleLab.text = titleStr;
    titleLab.tkThemetextColors = @[COLOR_11, COLOR_11_DARK];
    titleLab.font = FONTB(20);
    titleLab.numberOfLines = 0;
    titleLab.textAlignment = NSTextAlignmentLeft;
    [titleLab changeLineSpace:8];
    [self.view addSubview:titleLab];
    [titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.navView.mas_bottom).offset(DWScale(58));
        make.leading.equalTo(self.view).offset(DWScale(20));
        make.trailing.equalTo(self.view).offset(DWScale(-20));
    }];
    
    [self.view addSubview:self.accountInput];
    [self.accountInput mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(titleLab.mas_bottom).offset(DWScale(24));
        make.leading.equalTo(self.view).offset(DWScale(25));
        make.trailing.equalTo(self.view).offset(-DWScale(25));
        make.height.mas_equalTo(DWScale(46));
    }];
    
    [self.view addSubview:self.vercodeInput];
    [self.vercodeInput mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.accountInput.mas_bottom).offset(DWScale(16));
        make.leading.equalTo(self.view).offset(DWScale(25));
        make.trailing.equalTo(self.view).offset(-DWScale(25));
        make.height.mas_equalTo(DWScale(46));
    }];
    
    [self.view addSubview:self.passwordInput];
    [self.passwordInput mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.vercodeInput.mas_bottom).offset(DWScale(16));
        make.leading.equalTo(self.view).offset(DWScale(25));
        make.trailing.equalTo(self.view).offset(-DWScale(25));
        make.height.mas_equalTo(DWScale(46));
    }];
    
    [self.view addSubview:self.dynamicTipLbl];
    [self.dynamicTipLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.passwordInput.mas_bottom);
        make.leading.trailing.equalTo(self.passwordInput);
        make.height.mas_equalTo(0);
    }];
    
    [self.view addSubview:self.confimPasswordInput];
    [self.confimPasswordInput mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.dynamicTipLbl.mas_bottom).offset(DWScale(16));
        make.leading.equalTo(self.view).offset(DWScale(25));
        make.trailing.equalTo(self.view).offset(-DWScale(25));
        make.height.mas_equalTo(DWScale(46));
    }];
    
    [self.view addSubview:self.tipLbl];
    [self.tipLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.confimPasswordInput.mas_bottom).offset(DWScale(12));
        make.leading.trailing.equalTo(self.confimPasswordInput);
        make.height.mas_equalTo(DWScale(20));
    }];
    
    [self.view addSubview:self.loginBtn];
    [self.loginBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.tipLbl.mas_bottom).offset(DWScale(22));
        make.leading.equalTo(self.view).offset(DWScale(25));
        make.trailing.equalTo(self.view).offset(-DWScale(25));
        make.height.mas_equalTo(DWScale(46));
    }];
    
    //输入框输入内容变化回调
    @weakify(self)
    [self.accountInput setInputStatus:^{
        @strongify(self)
        [self checkFindAndLoginBtnAvailable];
    }];
    [self.vercodeInput setInputStatus:^{
        @strongify(self)
        [self checkFindAndLoginBtnAvailable];
    }];
    [self.passwordInput setInputStatus:^{
        @strongify(self)
        [self checkFindAndLoginBtnAvailable];
    }];
    [self.confimPasswordInput setInputStatus:^{
        @strongify(self)
        [self checkFindAndLoginBtnAvailable];
    }];
    
    self.accountInput.textFieldEndInput = ^{
        @strongify(self)
        [self listenAccountInput];
    };
    self.vercodeInput.textFieldEndInput = ^{
        @strongify(self)
        [self listenVercodeInput];
    };
    self.passwordInput.textFieldEndInput = ^{
        @strongify(self)
        [self listenPasswordInput];
    };
    self.confimPasswordInput.textFieldEndInput = ^{
        @strongify(self)
        [self listenConfimPasswordInput];
    };
    //获取验证码
    self.vercodeInput.getVerCodeBlock = ^{
        @strongify(self)
        if (self.findPasswordWay == UserAuthTypePhone) {
            [IMSDKManager configSDKCaptchaChannel:ZHostTool.appSysSetModel.captchaChannel];
            if (ZHostTool.appSysSetModel.captchaChannel == 1) {
                [self requestGetVercode:@"" ticket:@"" randstr:@"" captchaVerifyParam:@""];
            }
            if (ZHostTool.appSysSetModel.captchaChannel == 2) {
                NoaImgVerCodeView *vercodeView = [[NoaImgVerCodeView alloc] init];
                vercodeView.loginName = self.accountInput.inputText.text;
                vercodeView.verCodeType = 3;
                vercodeView.imgCodeStr = @"";
                [vercodeView show];
                [vercodeView setSureBtnBlock:^(NSString * _Nonnull imgCode) {
                    @strongify(self)
                    //未注册，可以获取短信/邮箱验证码
                    [self requestGetVercode:imgCode ticket:@"" randstr:@"" captchaVerifyParam:@""];
                }];
            }
            if (ZHostTool.appSysSetModel.captchaChannel == 3) {
                //腾讯云无痕验证
                [HUD showActivityMessage:@"" inView:self.view];
                [self.captchaTools verCaptchaCode];
                [self.captchaTools setTencentCaptchaResultSuccess:^(NSString * _Nonnull ticket, NSString * _Nonnull randstr) {
                    @strongify(self)
                    //获取短信验证码接口
                    [HUD hideHUD];
                    [self requestGetVercode:@"" ticket:ticket randstr:randstr captchaVerifyParam:@""];
                }];
                
                [self.captchaTools setCaptchaResultFail:^{
                    @strongify(self)
                    [IMSDKManager configSDKCaptchaChannel:2];
                    NoaImgVerCodeView *vercodeView = [[NoaImgVerCodeView alloc] init];
                    vercodeView.loginName = self.accountInput.inputText.text;
                    vercodeView.verCodeType = 3;
                    vercodeView.imgCodeStr = @"";
                    [vercodeView show];
                    [vercodeView setSureBtnBlock:^(NSString * _Nonnull imgCode) {
                        @strongify(self)
                        //获取短信/邮箱验证码
                        [self requestGetVercode:imgCode ticket:@"" randstr:@"" captchaVerifyParam:@""];
                    }];
                }];
            }
            if (ZHostTool.appSysSetModel.captchaChannel == 4) {
                //阿里云无痕验证
                [HUD showActivityMessage:@"" inView:self.view];
                [self.captchaTools verCaptchaCode];
                [self.captchaTools setAliyunCaptchaResultSuccess:^(NSString * _Nonnull captchaVerifyParam) {
                    @strongify(self)
                    //获取短信验证码接口
                    [HUD hideHUD];
                    [self requestGetVercode:@"" ticket:@"" randstr:@"" captchaVerifyParam:captchaVerifyParam];
                }];
                
                [self.captchaTools setCaptchaResultFail:^{
                    @strongify(self)
                    [IMSDKManager configSDKCaptchaChannel:2];
                    NoaImgVerCodeView *vercodeView = [[NoaImgVerCodeView alloc] init];
                    vercodeView.loginName = self.accountInput.inputText.text;
                    vercodeView.verCodeType = 3;
                    vercodeView.imgCodeStr = @"";
                    [vercodeView show];
                    [vercodeView setSureBtnBlock:^(NSString * _Nonnull imgCode) {
                        @strongify(self)
                        //获取短信/邮箱验证码
                        [self requestGetVercode:imgCode ticket:@"" randstr:@"" captchaVerifyParam:@""];
                    }];
                }];
            }
        }
        if (self.findPasswordWay == UserAuthTypeEmail) {
            [self requestGetVercode:@"" ticket:@"" randstr:@"" captchaVerifyParam:@""];
        }
    };
    //选择国家区号
    self.accountInput.getCountryCodeAction = ^{
        @strongify(self)
        [self selectCountryCodeAction];
    };
}

- (void)setupLocalData {
    self.accountInput.preInputText = self.loginInfo;
}

#pragma mark - 状态监听 && input block
//通过检查输入框是否有内容来决定确定按钮是否可点击
- (void)checkFindAndLoginBtnAvailable {
    if (self.accountInput.textLength > 0 && self.vercodeInput.textLength > 0 && self.passwordInput.textLength > 0 && self.confimPasswordInput.textLength > 0) {
        self.loginBtn.enabled = YES;
        self.loginBtn.tkThemebackgroundColors = @[COLOR_5966F2, COLOR_5966F2_DARK];
    } else {
        self.loginBtn.enabled = NO;
        self.loginBtn.tkThemebackgroundColors = @[[COLOR_5966F2 colorWithAlphaComponent:0.3], [COLOR_5966F2_DARK colorWithAlphaComponent:0.3]];
    }
}

//手机号/邮箱 监听
- (void)listenAccountInput {
    if (self.findPasswordWay == UserAuthTypePhone) {
        [NoaAuthInputTools loginCheckPhoneWithText:self.accountInput.inputText.text IsShowToast:YES];
    }
    if (self.findPasswordWay == UserAuthTypeEmail) {
        [NoaAuthInputTools loginCheckEmailWithText:self.accountInput.inputText.text IsShowToast:YES];
    }
}

//验证码监听
- (void)listenVercodeInput {
    [NoaAuthInputTools checkVerCodeWithText:self.vercodeInput.inputText.text IsShowToast:YES];
}

//密码监听
- (void)listenPasswordInput {
    if ([NoaAuthInputTools checkCreatPasswordEndWithTextLength:self.passwordInput.inputText.text] == NO) {
        self.dynamicTipLbl.hidden = NO;
        self.dynamicTipLbl.text = LanguageToolMatch(@"密码长度6-16");
        [self.dynamicTipLbl mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.passwordInput.mas_bottom).offset(DWScale(4));
            make.height.mas_equalTo(DWScale(16));
        }];
    } else if ([NoaAuthInputTools checkCreatPasswordEndWithTextFormat:self.passwordInput.inputText.text] == NO) {
        self.dynamicTipLbl.hidden = NO;
        self.dynamicTipLbl.text = LanguageToolMatch(@"密码须包含字母、数字");
        [self.dynamicTipLbl mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.passwordInput.mas_bottom).offset(DWScale(4));
            make.height.mas_equalTo(DWScale(16));
        }];
    } else {
        self.dynamicTipLbl.hidden = YES;
        self.dynamicTipLbl.text = @"";
        [self.dynamicTipLbl mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.passwordInput.mas_bottom);
            make.height.mas_equalTo(0);
        }];
    }
}

//确认密码监听
- (void)listenConfimPasswordInput {
    if (![self.passwordInput.inputText.text isEqualToString:self.confimPasswordInput.inputText.text]) {
        [HUD showMessage:LanguageToolMatch(@"密码不一致") inView:self.view];
    }
}

//选择国家区号
- (void)selectCountryCodeAction {
    NoaCountryCodeViewController *countryCodeVC = [[NoaCountryCodeViewController alloc] init];
    [self.navigationController pushViewController:countryCodeVC animated:YES];
    
    @weakify(self)
    [countryCodeVC setSelecgCountryCodeBlock:^(NSDictionary * _Nonnull dic) {
        @strongify(self)
        self.accountInput.countryCodeStr = [NSString stringWithFormat:@"+%@",(NSString *)[dic objectForKey:@"prefix"]];
    }];
}

#pragma mark - Setter
- (void)setFindPasswordWay:(int)findPasswordWay {
    _findPasswordWay = findPasswordWay;
    switch (_findPasswordWay) {
        case UserAuthTypePhone:
        {
            self.accountInput.placeholderText = LanguageToolMatch(@"请输入手机号");
            self.accountInput.inputType = ZMessageInputViewTypePhone;
            self.accountInput.tipsImgName = @"img_phone_input_tip";
        }
            break;
        case UserAuthTypeEmail:
        {
            self.accountInput.placeholderText = LanguageToolMatch(@"请输入邮箱");
            self.accountInput.inputType = ZMessageInputViewTypeNomal;
            self.accountInput.tipsImgName = @"img_email_input_tip";
        }
            break;
            
        default:
            break;
    }
}

#pragma marl - Action
- (void)loginAction {
    //关闭键盘
    [self.accountInput.inputText resignFirstResponder];
    [self.vercodeInput.inputText resignFirstResponder];
    [self.passwordInput.inputText resignFirstResponder];
    [self.confimPasswordInput.inputText resignFirstResponder];
    
    if (self.findPasswordWay == UserAuthTypePhone) {
        if ([NoaAuthInputTools loginCheckPhoneWithText:self.accountInput.inputText.text IsShowToast:YES] == NO ||
            [NoaAuthInputTools checkVerCodeWithText:self.vercodeInput.inputText.text IsShowToast:YES] == NO) {
            return;
        }
    }
    if (self.findPasswordWay == UserAuthTypeEmail) {
        if ([NoaAuthInputTools loginCheckEmailWithText:self.accountInput.inputText.text IsShowToast:YES] == NO ||
            [NoaAuthInputTools checkVerCodeWithText:self.vercodeInput.inputText.text IsShowToast:YES] == NO) {
            return;
        }
    }
    if ( [NoaAuthInputTools checkCreatPasswordEndWithTextLength:self.passwordInput.inputText.text] == NO ||
        [NoaAuthInputTools checkCreatPasswordEndWithTextFormat:self.passwordInput.inputText.text] == NO ||
        [NoaAuthInputTools checkCreatPasswordEndWithTextLength:self.confimPasswordInput.inputText.text] == NO ||
        [NoaAuthInputTools checkCreatPasswordEndWithTextFormat:self.confimPasswordInput.inputText.text] == NO) {
        
        [HUD showMessage:LanguageToolMatch(@"密码长度6-16位，须包含字母、数字") inView:self.view];
        return;
    }
    if (![self.passwordInput.inputText.text isEqualToString:self.confimPasswordInput.inputText.text]) {
        [HUD showMessage:LanguageToolMatch(@"密码不一致") inView:self.view];
        return;
    }
    //获取密钥
    [self getEncryptKeyAction];
}

#pragma mark - NetWork
//获取验证码
- (void)requestGetVercode:(NSString *)code ticket:(NSString *)ticket randstr:(NSString *)randstr captchaVerifyParam:(NSString *)captchaVerifyParam {
    if ( self.accountInput.isEmpty) {
        [HUD showMessage:LanguageToolMatch(@"账号")];
        return;
    }
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObjectSafe:self.accountInput.inputText.text forKey:@"loginInfo"];
    [params setObjectSafe:[NSNumber numberWithInt:self.findPasswordWay] forKey:@"loginType"];
    [params setObjectSafe:[NSNumber numberWithInt:3] forKey:@"type"];
    [params setObjectSafe:self.accountInput.countryCodeStr forKey:@"areaCode"];
    [params setObjectSafe:code forKey:@"code"];
    [params setObjectSafe:ticket forKey:@"ticket"];
    [params setObjectSafe:randstr forKey:@"randstr"];
    [params setObjectSafe:captchaVerifyParam forKey:@"captchaVerifyParam"];
    
    @weakify(self)
    [IMSDKManager authGetPhoneEmailVerCodeWith:params onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
        @strongify(self)
        [ZTOOL doInMain:^{
            [HUD showMessage:LanguageToolMatch(@"验证码已发送") inView:self.view];
            [self.vercodeInput configVercodeBtnCountdown];
            [IMSDKManager configSDKCaptchaChannel:ZHostTool.appSysSetModel.captchaChannel];
            self.captchaTools.aliyunVerNum = 0;
        }];
        
    } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
        @strongify(self)
        [ZTOOL doInMain:^{
            [HUD hideHUD];
            [self requestAliyunCaptchaErrorResult:code msg:msg];
        }];
        
    }];
}

- (void)requestAliyunCaptchaErrorResult:(NSInteger)errorCode msg:(NSString *)errorMsg {
    @weakify(self)
    if (errorCode == Auth_User_Capcha_Error_Code) {
        //51002：阿里云验证异常，需进行二次验证(图形验证码)
        if (self.captchaTools.aliyunVerNum < 2) {
            [self.captchaTools secondVerCaptchaCode];
            [self.captchaTools setAliyunCaptchaResultSuccess:^(NSString * _Nonnull captchaVerifyParam) {
                @strongify(self)
                //获取短信验证码接口
                [HUD hideHUD];
                [self requestGetVercode:@"" ticket:@"" randstr:@"" captchaVerifyParam:captchaVerifyParam];
            }];
            
            [self.captchaTools setCaptchaResultFail:^{
                @strongify(self)
                [self showImgVerCodeView];
            }];
        } else {
            [self showImgVerCodeView];
        }
    } else if (errorCode == Auth_User_Capcha_TimeOut_Code) {
        //51006：阿里云验证超时，展示图文验证码
        [self showImgVerCodeView];
    } else if (errorCode == Auth_User_Capcha_ChangeImgVer_Code) {
        //图形验证码不正确，请重新输入
        [HUD showMessage:LanguageToolMatch(@"验证码不正确，请重新输入") inView:self.view];
        [self showImgVerCodeView];
    } else {
        [HUD showMessageWithCode:errorCode errorMsg:errorMsg inView:self.view];
    }
}

- (void)showImgVerCodeView {
    [HUD hideHUD];
    [self.view endEditing:YES];
    
    [IMSDKManager configSDKCaptchaChannel:2];
    NoaImgVerCodeView *vercodeView = [[NoaImgVerCodeView alloc] init];
    vercodeView.loginName = self.accountInput.inputText.text;
    vercodeView.verCodeType = 3;
    vercodeView.imgCodeStr = @"";
    [vercodeView show];
    
    @weakify(self)
    [vercodeView setSureBtnBlock:^(NSString * _Nonnull imgCode) {
        @strongify(self)
        //未注册，可以获取短信/邮箱验证码
        [self requestGetVercode:imgCode ticket:@"" randstr:@"" captchaVerifyParam:@""];
        [IMSDKManager configSDKCaptchaChannel:ZHostTool.appSysSetModel.captchaChannel];
        self.captchaTools.aliyunVerNum = 0;
    }];
    
    [vercodeView setCancelBtnBlock:^{
        @strongify(self)
        [IMSDKManager configSDKCaptchaChannel:ZHostTool.appSysSetModel.captchaChannel];
        self.captchaTools.aliyunVerNum = 0;
    }];
}

//获取密钥
- (void)getEncryptKeyAction {
    [HUD showActivityMessage:@"" inView:self.view];
    
    @weakify(self)
    [IMSDKManager authGetEncryptKeySuccess:^(id  _Nullable data, NSString * _Nullable traceId) {
        @strongify(self)
        [ZTOOL doInMain:^{
            [HUD hideHUD];
            //调用注册接口，传入加密密钥
            if([data isKindOfClass:[NSString class]]){
                NSString *encryptKey = (NSString *)data;
                [self resetPasswordActionWithEncryptKey:encryptKey];
            }
        }];
        
    } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
        @strongify(self)
        [ZTOOL doInMain:^{
            [HUD hideHUD];
            [HUD showMessageWithCode:code errorMsg:msg inView:self.view];
        }];
        
    }];
}

//找回密码(重置密码)
- (void)resetPasswordActionWithEncryptKey:(NSString *)encryptKey {
    //AES对称加密后的密码
    NSString *passwordKey = [NSString stringWithFormat:@"%@%@",encryptKey, self.passwordInput.inputText.text];
    NSString *userPwStr = [LXChatEncrypt method4:passwordKey];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObjectSafe:self.accountInput.inputText.text forKey:@"loginInfo"];
    [params setObjectSafe:[NSNumber numberWithInt:self.findPasswordWay] forKey:@"loginType"];
    [params setObjectSafe:self.vercodeInput.inputText.text forKey:@"code"];
    [params setObjectSafe:encryptKey forKey:@"encryptKey"];
    [params setObjectSafe:userPwStr forKey:@"userPw"];
    [params setObjectSafe:[NSNumber numberWithInt:3] forKey:@"type"];
    [params setObjectSafe:self.accountInput.countryCodeStr forKey:@"areaCode"];
    
    @weakify(self)
    [HUD showActivityMessage:@"" inView:self.view];
    [IMSDKManager authResetPasswordWith:params onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
        @strongify(self)
        [ZTOOL doInMain:^{
            [HUD hideHUD];
            [HUD showMessage:LanguageToolMatch(@"登录成功") inView:self.view];
            NoaUserModel *loginUserModel = [NoaUserModel mj_objectWithKeyValues:data];
            [loginUserModel saveUserInfo];
            [NoaUserModel savePreAccount:self.loginInfo Type:self.findPasswordWay];
            [UserManager setUserInfo:loginUserModel];
            
            //socket用户登录连接
            NoaIMSDKUserOptions *userOption = [NoaIMSDKUserOptions new];
            userOption.userToken = UserManager.userInfo.token;
            userOption.userID = UserManager.userInfo.userUID;
            userOption.userNickname = UserManager.userInfo.nickname;
            userOption.userAvatar = UserManager.userInfo.avatar;
            [IMSDKManager configSDKUserWith:userOption];
            
            [NoaWeakPwdCheckTool sharedInstance].userPwd = self.passwordInput.inputText.text;
            // 登录成功
            AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
            [delegate loginSuccess];
        }];
        
    } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
        @strongify(self)
        [ZTOOL doInMain:^{
            if (code == LingIMHttpResponseCodeUsedIpDisabled) {
                //登录不在白名单内，需展示IP地址
                [HUD showMessage:[NSString stringWithFormat:LanguageToolMatch(@"登录IP：%@ 不在白名单内"), msg] inView:self.view];
            } else {
                [HUD showMessageWithCode:code errorMsg:msg inView:self.view];
            }
        }];
        
    }];
}

#pragma mark - Lazy
- (NoaInputTextView *)accountInput {
    if (!_accountInput) {
        _accountInput = [[NoaInputTextView alloc] init];
        _accountInput.placeholderText = LanguageToolMatch(@"输入手机号");
        if (@available(iOS 12.0, *)) {
            _accountInput.inputText.textContentType = UITextContentTypeOneTimeCode;
        } else {
            // Fallback on earlier versions
        }
        _accountInput.inputType = ZMessageInputViewTypePhone;
        _accountInput.tipsImgName = @"img_phone_input_tip";
    }
    return _accountInput;
}

- (NoaInputTextView *)vercodeInput {
    if (!_vercodeInput) {
        _vercodeInput = [[NoaInputTextView alloc] init];
        _vercodeInput.placeholderText = LanguageToolMatch(@"输入验证码");
        if (@available(iOS 12.0, *)) {
            _vercodeInput.inputText.textContentType = UITextContentTypeOneTimeCode;
        } else {
            // Fallback on earlier versions
        }
        _vercodeInput.inputType = ZMessageInputViewTypeVercode;
        _vercodeInput.tipsImgName = @"img_vercode_input_tip";
    }
    return _vercodeInput;
}

- (NoaInputTextView *)passwordInput {
    if (!_passwordInput) {
        _passwordInput = [[NoaInputTextView alloc] init];
        _passwordInput.isPassword = YES;
        _passwordInput.clipsToBounds = YES;
        _passwordInput.placeholderText = LanguageToolMatch(@"请设置新密码");
        _passwordInput.inputText.keyboardType = UIKeyboardTypeASCIICapable;
        if (@available(iOS 12.0, *)) {
            _passwordInput.inputText.textContentType = UITextContentTypeOneTimeCode;
        } else {
            // Fallback on earlier versions
        }
        _passwordInput.inputType = ZMessageInputViewTypePassword;
        _passwordInput.tipsImgName = @"img_password_input_tip";
    }
    return _passwordInput;
}

- (NoaInputTextView *)confimPasswordInput {
    if (!_confimPasswordInput) {
        _confimPasswordInput = [[NoaInputTextView alloc] init];
        _confimPasswordInput.isPassword = YES;
        _confimPasswordInput.placeholderText = LanguageToolMatch(@"请再次输入新密码");
        _confimPasswordInput.inputText.keyboardType = UIKeyboardTypeASCIICapable;
        if (@available(iOS 12.0, *)) {
            _confimPasswordInput.inputText.textContentType = UITextContentTypeOneTimeCode;
        } else {
            // Fallback on earlier versions
        }
        _confimPasswordInput.inputType = ZMessageInputViewTypePassword;
        _confimPasswordInput.tipsImgName = @"img_password_input_tip";
    }
    return _confimPasswordInput;
}

- (UILabel *)tipLbl {
    if (!_tipLbl) {
        _tipLbl = [[UILabel alloc] init];
        if (ZHostTool.appSysSetModel.checkEnglishSymbol) {
            _tipLbl.text = LanguageToolMatch(@"密码至少6个字符，同时包含字母、数字、符号");
        } else {
            _tipLbl.text = LanguageToolMatch(@"密码至少6个字符，不能全是字母或数字");
        }
        _tipLbl.tkThemetextColors = @[COLOR_11, COLOR_11_DARK];
        _tipLbl.font = FONTN(14);
        _tipLbl.textAlignment = NSTextAlignmentLeft;
    }
    return _tipLbl;
}

- (UILabel *)dynamicTipLbl {
    if (!_dynamicTipLbl) {
        _dynamicTipLbl = [[UILabel alloc] init];
        _dynamicTipLbl.text = @"";
        _dynamicTipLbl.tkThemetextColors = @[COLOR_FF3333, COLOR_FF3333_DARK];
        _dynamicTipLbl.font = FONTN(12);
        _dynamicTipLbl.textAlignment = NSTextAlignmentLeft;
        _dynamicTipLbl.hidden = YES;
    }
    return _dynamicTipLbl;
}

- (UIButton *)loginBtn {
    if (!_loginBtn) {
        _loginBtn = [[UIButton alloc] init];
        _loginBtn.clipsToBounds = YES;
        _loginBtn.enabled = NO;
        _loginBtn.tkThemebackgroundColors = @[[COLOR_5966F2 colorWithAlphaComponent:0.3], [COLOR_5966F2_DARK colorWithAlphaComponent:0.3]];
        [_loginBtn setTitle:LanguageToolMatch(@"登录") forState:UIControlStateNormal];
        [_loginBtn setTitleColor:COLORWHITE forState:UIControlStateNormal];
        [_loginBtn setTkThemeBackgroundImage:@[[UIImage ImageForColor:COLOR_4069B9],[UIImage ImageForColor:COLOR_4069B9_DARK]] forState:UIControlStateSelected];
        [_loginBtn setTkThemeBackgroundImage:@[[UIImage ImageForColor:COLOR_4069B9],[UIImage ImageForColor:COLOR_4069B9_DARK]] forState:UIControlStateHighlighted];
        [_loginBtn rounded:DWScale(14)];
        [_loginBtn shadow:COLOR_5966F2 opacity:0.15 radius:5 offset:CGSizeMake(0, 0)];
        [_loginBtn addTarget:self action:@selector(loginAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _loginBtn;
}

- (NoaCaptchaCodeTools *)captchaTools {
    if (!_captchaTools) {
        _captchaTools = [[NoaCaptchaCodeTools alloc] init];
        _captchaTools.aliyunVerNum = 0;
    }
    return _captchaTools;
}

@end
