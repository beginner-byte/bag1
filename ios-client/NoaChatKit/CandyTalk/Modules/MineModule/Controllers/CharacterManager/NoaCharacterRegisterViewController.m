//
//  NoaCharacterRegisterViewController.m
//  NoaKit
//
//  Created by Candy on 2023/9/15.
//

#import "NoaCharacterRegisterViewController.h"
#import "NoaCharManagerInput.h"
#import "NoaCharacterManagerViewController.h"

@interface NoaCharacterRegisterViewController ()

@property (nonatomic, strong) NoaCharManagerInput *userNameInput;
@property (nonatomic, strong) NoaCharManagerInput *passwordInput;
@property (nonatomic, strong) NoaCharManagerInput *confimPWDInput;
@property (nonatomic, strong) UIButton *registerBtn;

@end

@implementation NoaCharacterRegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.tkThemebackgroundColors = @[COLOR_F5F6F9, COLOR_F5F6F9_DARK];
    self.navTitleStr = LanguageToolMatch(@"注册账户");
    [self setupUI];
}

- (void)setupUI {
    [self.view addSubview:self.userNameInput];
    [self.view addSubview:self.passwordInput];
    [self.view addSubview:self.confimPWDInput];
    [self.view addSubview:self.registerBtn];
    
    [self.userNameInput mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.navView.mas_bottom).offset(DWScale(16));
        make.leading.trailing.mas_equalTo(self.view);
        make.height.mas_equalTo(DWScale(54));
    }];
    
    [self.passwordInput mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.userNameInput.mas_bottom);
        make.leading.trailing.mas_equalTo(self.view);
        make.height.mas_equalTo(DWScale(54));
    }];
    
    [self.confimPWDInput mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.passwordInput.mas_bottom);
        make.leading.trailing.mas_equalTo(self.view);
        make.height.mas_equalTo(DWScale(54));
    }];
    
    [self.registerBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.confimPWDInput.mas_bottom).offset(DWScale(100));
        make.leading.mas_equalTo(self.view).offset(DWScale(16));
        make.trailing.mas_equalTo(self.view).offset(-DWScale(16));
        make.height.mas_equalTo(DWScale(50));
    }];
    
    //输入框输入内容变化回调
    WeakSelf
    [self.userNameInput setInputStatus:^{
        [weakSelf checkRegisterBtnAvailable];
    }];
    [self.passwordInput setInputStatus:^{
        [weakSelf checkRegisterBtnAvailable];
    }];
    [self.confimPWDInput setInputStatus:^{
        [weakSelf checkRegisterBtnAvailable];
    }];
}

#pragma mark - 输入框状态监听，决定注册按钮是否可点击的状态
- (void)checkRegisterBtnAvailable {
    if (self.userNameInput.textLength > 0 && self.passwordInput.textLength > 0 && self.confimPWDInput.textLength > 0) {
        self.registerBtn.enabled = YES;
        self.registerBtn.tkThemebackgroundColors = @[COLOR_5966F2, COLOR_5966F2_DARK];
    } else {
        self.registerBtn.enabled = NO;
        self.registerBtn.tkThemebackgroundColors = @[[COLOR_5966F2 colorWithAlphaComponent:0.3], [COLOR_5966F2_DARK colorWithAlphaComponent:0.3]];
    }
}

#pragma mark - rquest
//如果是已经绑定过的，需要先解绑再重新 注册+登录+绑定
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
        [weakSelf requestRegisterAndLogin];
    } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
        [HUD hideHUD];
        [HUD showMessageWithCode:code errorMsg:msg];
    }];
}

//注册+登录+绑定
- (void)requestRegisterAndLogin {
    //关闭键盘
    [self.userNameInput.inputText resignFirstResponder];
    [self.passwordInput.inputText resignFirstResponder];
    [self.confimPWDInput.inputText resignFirstResponder];
    
    if (![[self.passwordInput.inputText.text trimString] isEqualToString:[self.confimPWDInput.inputText.text trimString]]) {
        [HUD showMessage:LanguageToolMatch(@"密码不一致")];
        return;
    }
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObjectSafe:[self.userNameInput.inputText.text trimString] forKey:@"account"];
    [dict setObjectSafe:[self.passwordInput.inputText.text trimString] forKey:@"password"];
    [dict setObjectSafe:UserManager.userInfo.userUID forKey:@"userUid"];

    WeakSelf
    [HUD showActivityMessage:@""];
    [IMSDKManager imSdkTranslateRegisterBindAccount:dict onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
        [HUD hideHUD];
        //将yuuee账号存储到本地
        NoaUserModel *userModel = [NoaUserModel getUserInfo];
        userModel.yuueeAccount = [weakSelf.userNameInput.inputText.text trimString];
        [userModel saveUserInfo];
        [UserManager setUserInfo:userModel];
        if (weakSelf.isFromBind) {
            for (UIViewController * vc in weakSelf.navigationController.viewControllers) {
                if([vc isKindOfClass:[NoaCharacterManagerViewController class]]){
                    NoaCharacterManagerViewController *managerVC = (NoaCharacterManagerViewController *)vc;
                    [weakSelf.navigationController popToViewController:managerVC animated:YES];
                    
                    //通知：更新CharacterManager绑定的信息
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"NSNotificationReloadCharacterManagerInfo" object:nil userInfo:nil];
                }
            }
        } else {
            if (weakSelf.chartManageBindResult) {
                weakSelf.chartManageBindResult(YES);
            }
            [weakSelf.navigationController popViewControllerAnimated:YES];
        }
    } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
        [HUD hideHUD];
        [HUD showMessageWithCode:code errorMsg:msg];
    }];
}

#pragma mark - Action
- (void)registerAction {
    if (self.isBinded) {
        //先解绑
        [self requestUnbindAccount];
    } else {
        [self requestRegisterAndLogin];
    }
}

#pragma mark - Lazy
- (NoaCharManagerInput *)userNameInput {
    if (!_userNameInput) {
        _userNameInput = [[NoaCharManagerInput alloc] init];
        _userNameInput.leftTitleStr = LanguageToolMatch(@"用户名");
        _userNameInput.placeholderText = LanguageToolMatch(@"请输入用户名");
        if (@available(iOS 12.0, *)) {
            _userNameInput.inputText.textContentType = UITextContentTypeOneTimeCode;
        }
        _userNameInput.inputType = ZCharManagerInputTypeNomal;
    }
    return _userNameInput;
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
        } else {
            // Fallback on earlier versions
        }
        _passwordInput.inputType = ZCharManagerInputTypeNomal;
    }
    return _passwordInput;
}

- (NoaCharManagerInput *)confimPWDInput {
    if (!_confimPWDInput) {
        _confimPWDInput = [[NoaCharManagerInput alloc] init];
        _confimPWDInput.leftTitleStr = LanguageToolMatch(@"确认密码");
        _confimPWDInput.placeholderText = LanguageToolMatch(@"请输入密码");
        _confimPWDInput.inputText.keyboardType = UIKeyboardTypeASCIICapable;
        if (@available(iOS 12.0, *)) {
            _confimPWDInput.inputText.textContentType = UITextContentTypeOneTimeCode;
        } else {
            // Fallback on earlier versions
        }
        _confimPWDInput.inputType = ZCharManagerInputTypeNomal;
    }
    return _confimPWDInput;
}

- (UIButton *)registerBtn {
    if (!_registerBtn) {
        _registerBtn = [[UIButton alloc] init];
        [_registerBtn setTitle:LanguageToolMatch(@"登录") forState:UIControlStateNormal];
        [_registerBtn setTitleColor:COLORWHITE forState:UIControlStateNormal];
        _registerBtn.enabled = NO;
        _registerBtn.tkThemebackgroundColors = @[[COLOR_5966F2 colorWithAlphaComponent:0.3], [COLOR_5966F2_DARK colorWithAlphaComponent:0.3]];
        [_registerBtn setTkThemeBackgroundImage:@[[UIImage ImageForColor:COLOR_4069B9],[UIImage ImageForColor:COLOR_4069B9_DARK]] forState:UIControlStateSelected];
        [_registerBtn setTkThemeBackgroundImage:@[[UIImage ImageForColor:COLOR_4069B9],[UIImage ImageForColor:COLOR_4069B9_DARK]] forState:UIControlStateHighlighted];
        [_registerBtn rounded:DWScale(14)];
        _registerBtn.clipsToBounds = YES;
        [_registerBtn addTarget:self action:@selector(registerAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _registerBtn;
}

@end
