//
//  NoaCharacterBindViewController.m
//  NoaKit
//
//  Created by Candy on 2023/9/15.
//

#import "NoaCharacterBindViewController.h"
#import "NoaCharacterRegisterViewController.h"
#import "NoaCharManagerInput.h"

@interface NoaCharacterBindViewController ()

@property (nonatomic, strong) NoaCharManagerInput *accountInput;
@property (nonatomic, strong) NoaCharManagerInput *passwordInput;
@property (nonatomic, strong) UIButton *registerBtn;
@property (nonatomic, strong) UIButton *bindBtn;

@end

@implementation NoaCharacterBindViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.tkThemebackgroundColors = @[COLOR_F5F6F9, COLOR_F5F6F9_DARK];
    self.navTitleStr = LanguageToolMatch(@"绑定账户");
    [self setupUI];
}

- (void)setupUI {
    [self.view addSubview:self.accountInput];
    [self.view addSubview:self.passwordInput];
    [self.view addSubview:self.registerBtn];
    [self.view addSubview:self.bindBtn];
    
    [self.accountInput mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.navView.mas_bottom).offset(DWScale(16));
        make.leading.trailing.mas_equalTo(self.view);
        make.height.mas_equalTo(DWScale(54));
    }];
    
    [self.passwordInput mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.accountInput.mas_bottom);
        make.leading.trailing.mas_equalTo(self.view);
        make.height.mas_equalTo(DWScale(54));
    }];
    
    [self.registerBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.passwordInput.mas_bottom).offset(DWScale(10));
        make.leading.mas_equalTo(self.view).offset(DWScale(16));
        make.trailing.mas_equalTo(self.view).offset(-DWScale(16));
        make.height.mas_equalTo(DWScale(20));
    }];
    
    [self.bindBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.registerBtn.mas_bottom).offset(DWScale(100));
        make.leading.mas_equalTo(self.view).offset(DWScale(16));
        make.trailing.mas_equalTo(self.view).offset(-DWScale(16));
        make.height.mas_equalTo(DWScale(50));
    }];
    
    //输入框输入内容变化回调
    WeakSelf
    [self.accountInput setInputStatus:^{
        [weakSelf checkBindBtnAvailable];
    }];
    [self.passwordInput setInputStatus:^{
        [weakSelf checkBindBtnAvailable];
    }];
}

#pragma mark - 输入框状态监听
- (void)checkBindBtnAvailable {
    if (self.accountInput.textLength > 0 && self.passwordInput.textLength > 0) {
        self.bindBtn.enabled = YES;
        self.bindBtn.tkThemebackgroundColors = @[COLOR_5966F2, COLOR_5966F2_DARK ];
    } else {
        self.bindBtn.enabled = NO;
        self.bindBtn.tkThemebackgroundColors = @[[COLOR_5966F2 colorWithAlphaComponent:0.3], [COLOR_5966F2_DARK colorWithAlphaComponent:0.3]];
    }
}

#pragma mark - Action
//去注册
- (void)gotoRegisterAction {
    NoaCharacterRegisterViewController *vc = [[NoaCharacterRegisterViewController alloc] init];
    vc.isFromBind = YES;
    vc.isBinded = self.isBinded;
    [self.navigationController pushViewController:vc animated:YES];
}

//绑定
- (void)bindAction {
    //关闭键盘
    [self.accountInput.inputText resignFirstResponder];
    [self.passwordInput.inputText resignFirstResponder];
    
    if (![NSString isNil:self.account]) {
        //先解绑再重新绑定
        [self requestUnbindAccount];
    } else {
        //未绑定过yuuee账号，直接绑定
        [self requestBindAccount];
    }
}

#pragma mark - request(网络请求)
//解绑
- (void)requestUnbindAccount {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObjectSafe:UserManager.userInfo.userUID forKey:@"userUid"];
    
    WeakSelf
    [HUD showActivityMessage:@""];
    [IMSDKManager imSdkTranslateUnBindAccount:dict onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
        [HUD hideHUD];
        //将yuuee账号存储到本地
        NoaUserModel *userModel = [NoaUserModel getUserInfo];
        userModel.yuueeAccount = @"";
        [userModel saveUserInfo];
        [UserManager setUserInfo:userModel];
        //解绑旧账号，重新绑定新账号
        [weakSelf requestBindAccount];
    } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
        [HUD hideHUD];
        if (code == Translate_yuuee_unbind_error_code) {
            [weakSelf requestBindAccount];
        } else {
            [HUD showMessageWithCode:code errorMsg:msg];
        }
    }];
}

//绑定
- (void)requestBindAccount {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObjectSafe:[self.accountInput.inputText.text trimString] forKey:@"account"];
    [dict setObjectSafe:[self.passwordInput.inputText.text trimString] forKey:@"password"];
    
    WeakSelf
    [HUD showActivityMessage:@""];
    [IMSDKManager imSdkTranslateBindAccount:dict onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
        [HUD hideHUD];
        //将yuuee账号存储到本地
        NoaUserModel *userModel = [NoaUserModel getUserInfo];
        userModel.yuueeAccount = [self.accountInput.inputText.text trimString];
        [userModel saveUserInfo];
        [UserManager setUserInfo:userModel];
        //绑定账号成功
        if (weakSelf.chartManageBindResult) {
            weakSelf.chartManageBindResult(YES);
        }
        [weakSelf.navigationController popViewControllerAnimated:YES];
    } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
        [HUD hideHUD];
        [HUD showMessageWithCode:code errorMsg:msg];
    }];
}

#pragma mark - Lazy
- (NoaCharManagerInput *)accountInput {
    if (!_accountInput) {
        _accountInput = [[NoaCharManagerInput alloc] init];
        _accountInput.leftTitleStr = LanguageToolMatch(@"账号");
        _accountInput.placeholderText = LanguageToolMatch(@"请输入账号");
        if (@available(iOS 12.0, *)) {
            _accountInput.inputText.textContentType = UITextContentTypeOneTimeCode;
        } else {
            // Fallback on earlier versions
        }
        _accountInput.inputType = ZCharManagerInputTypeNomal;
    }
    return _accountInput;
}

- (NoaCharManagerInput *)passwordInput {
    if (!_passwordInput) {
        _passwordInput = [[NoaCharManagerInput alloc] init];
        _passwordInput.clipsToBounds = YES;
        _passwordInput.leftTitleStr = LanguageToolMatch(@"密码");
        _passwordInput.placeholderText = LanguageToolMatch(@"请输入密码");
        _passwordInput.inputText.keyboardType = UIKeyboardTypeASCIICapable;
        if (@available(iOS 12.0, *)) {
            _passwordInput.inputText.textContentType = UITextContentTypeOneTimeCode;
        }
        _passwordInput.inputType = ZCharManagerInputTypeNomal;
    }
    return _passwordInput;
}

- (UIButton *)registerBtn {
    if (!_registerBtn) {
        NSString *regisTitleStr = LanguageToolMatch(@"还未拥有账户？ 去注册");
        NSMutableAttributedString *titleAttStr = [[NSMutableAttributedString alloc] initWithString:regisTitleStr];
        [titleAttStr configAttStrLightColor:COLOR_99 darkColor:COLOR_99_DARK range:NSMakeRange(0, regisTitleStr.length)];
        [titleAttStr configAttStrLightColor:COLOR_5966F2 darkColor:COLOR_5966F2 range:[regisTitleStr rangeOfString:LanguageToolMatch(@"去注册")]];
        
        _registerBtn = [[UIButton alloc] init];
        [_registerBtn setAttributedTitle:titleAttStr forState:UIControlStateNormal];
        _registerBtn.titleLabel.font = FONTN(12);
        [_registerBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        [_registerBtn addTarget:self action:@selector(gotoRegisterAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _registerBtn;
}

- (UIButton *)bindBtn {
    if (!_bindBtn) {
        _bindBtn = [[UIButton alloc] init];
        [_bindBtn setTitle:LanguageToolMatch(@"提交") forState:UIControlStateNormal];
        [_bindBtn setTitleColor:COLORWHITE forState:UIControlStateNormal];
        _bindBtn.enabled = NO;
        _bindBtn.tkThemebackgroundColors = @[[COLOR_5966F2 colorWithAlphaComponent:0.3], [COLOR_5966F2_DARK colorWithAlphaComponent:0.3]];
        [_bindBtn setTkThemeBackgroundImage:@[[UIImage ImageForColor:COLOR_4069B9],[UIImage ImageForColor:COLOR_4069B9_DARK]] forState:UIControlStateSelected];
        [_bindBtn setTkThemeBackgroundImage:@[[UIImage ImageForColor:COLOR_4069B9],[UIImage ImageForColor:COLOR_4069B9_DARK]] forState:UIControlStateHighlighted];
        [_bindBtn rounded:DWScale(16)];
        _bindBtn.clipsToBounds = YES;
        [_bindBtn addTarget:self action:@selector(bindAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _bindBtn;
}

@end
