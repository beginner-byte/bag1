//
//  NoaSafeCodeCloseViewController.m
//  NoaKit
//
//  Created by Candy on 2025/1/2.
//

#import "NoaSafeCodeCloseViewController.h"
#import "NoaInputTextView.h"
#import "NoaSafeSettingTools.h"
#import "NoaAuthInputTools.h"
#import "NoaChatKit-Swift.h"
#import "LXChatEncrypt.h"

#define SECURITY_CODE_FAIL_MAX_NUM          3

@interface NoaSafeCodeCloseViewController ()

@property (nonatomic, strong)NoaInputTextView *safeCodePwdInput;
@property (nonatomic, assign)NSInteger securityCodeFailNum;

@end

@implementation NoaSafeCodeCloseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.tkThemebackgroundColors = @[COLOR_F5F6F9, COLOR_11];
    self.securityCodeFailNum = 0;
    [self setupNavBarUI];
    [self setupUI];
}

- (void)setupNavBarUI {
    self.navTitleStr = LanguageToolMatch(@"关闭安全码");
    
    self.navBtnRight.hidden = NO;
    [self.navBtnRight setTitle:LanguageToolMatch(@"完成") forState:UIControlStateNormal];
    [self.navBtnRight setTkThemeTitleColor:@[COLORWHITE, COLOR_CCCCCC_DARK] forState:UIControlStateNormal];
    self.navBtnRight.enabled = NO;
    self.navBtnRight.tkThemebackgroundColors = @[COLOR_CCCCCC, COLOR_EEEEEE_DARK];
    [self.navBtnRight setTkThemeBackgroundImage:@[[UIImage ImageForColor:COLOR_4069B9],[UIImage ImageForColor:COLOR_4069B9_DARK]] forState:UIControlStateSelected];
    [self.navBtnRight setTkThemeBackgroundImage:@[[UIImage ImageForColor:COLOR_4069B9],[UIImage ImageForColor:COLOR_4069B9_DARK]] forState:UIControlStateHighlighted];
    [self.navBtnRight rounded:DWScale(12)];
    [self.navBtnRight mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.navTitleLabel);
        make.trailing.equalTo(self.navView).offset(-DWScale(20));
        make.height.mas_equalTo(DWScale(32));
        CGSize textSize = [self.navBtnRight.titleLabel.text sizeWithFont:FONTR(14) constrainedToSize:CGSizeMake(10000, DWScale(32))];
        make.width.mas_equalTo(textSize.width+DWScale(28));
    }];
}

- (void)setupUI {
    UILabel *originTitleLab = [[UILabel alloc] init];
    originTitleLab.text = LanguageToolMatch(@"请输入安全码");
    originTitleLab.tkThemetextColors = @[COLOR_11, COLOR_11_DARK];
    originTitleLab.font = FONTN(14);
    originTitleLab.textAlignment = NSTextAlignmentLeft;
    [self.view addSubview:originTitleLab];
    [originTitleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.navView.mas_bottom).offset(DWScale(20));
        make.leading.equalTo(self.view).offset(DWScale(16));
        make.trailing.equalTo(self.view).offset(DWScale(-16));
        make.height.mas_equalTo(DWScale(18));
    }];
    
    [self.view addSubview:self.safeCodePwdInput];
    [self.safeCodePwdInput mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(originTitleLab.mas_bottom).offset(DWScale(8));
        make.leading.equalTo(self.view).offset(DWScale(16));
        make.trailing.equalTo(self.view).offset(DWScale(-16));
        make.height.mas_equalTo(DWScale(44));
    }];
    
    @weakify(self)
    //关闭安全码(验证原安全码)
    if (self.operatorType == SafeCodeOperatorTypeClose) {
        originTitleLab.text = LanguageToolMatch(@"请输入安全码");
        self.safeCodePwdInput.placeholderText = LanguageToolMatch(@"请输入安全码");
        
        //输入框输入内容变化回调
        [self.safeCodePwdInput setInputStatus:^{
            @strongify(self)
            [self checkFinishBtnAvailable];
        }];
    }
    
    //关闭安全码(验证登录密码)
    if (self.operatorType == SafeCodeOperatorTypePassword) {
        originTitleLab.text = LanguageToolMatch(@"请输入登录密码");
        self.safeCodePwdInput.placeholderText = LanguageToolMatch(@"请输入登录密码");
        
        //输入框输入内容变化回调
        [self.safeCodePwdInput setInputStatus:^{
            @strongify(self)
            [self checkFinishBtnAvailable];
        }];
    }
}

- (void)checkFinishBtnAvailable {
    if (self.safeCodePwdInput.textLength > 0) {
        self.navBtnRight.enabled = YES;
        [self.navBtnRight setTkThemeTitleColor:@[COLORWHITE, COLORWHITE] forState:UIControlStateNormal];
        self.navBtnRight.tkThemebackgroundColors = @[COLOR_5966F2, COLOR_5966F2_DARK];
        [self.navBtnRight setTkThemeBackgroundImage:@[[UIImage ImageForColor:COLOR_4069B9],[UIImage ImageForColor:COLOR_4069B9_DARK]] forState:UIControlStateSelected];
        [self.navBtnRight setTkThemeBackgroundImage:@[[UIImage ImageForColor:COLOR_4069B9],[UIImage ImageForColor:COLOR_4069B9_DARK]] forState:UIControlStateHighlighted];
    } else {
        self.navBtnRight.enabled = NO;
        [self.navBtnRight setTkThemeTitleColor:@[COLORWHITE, COLOR_CCCCCC_DARK] forState:UIControlStateNormal];
        self.navBtnRight.tkThemebackgroundColors = @[COLOR_CCCCCC, COLOR_EEEEEE_DARK];
    }
}

#pragma mark - Action
- (void)navBtnRightClicked {
    //关闭安全码(验证原安全码)
    if (self.operatorType == SafeCodeOperatorTypeClose) {
        if (![NoaSafeSettingTools checkInputDeviceSafeCodeEndWithText:self.safeCodePwdInput.inputText.text]) {
            [HUD showMessage:LanguageToolMatch(@"请输入6位包含字母、数字的安全码") inView:self.view];
            return;
        }
        
        [self requestGetEncryptKeyAction];
    }
    
    //关闭安全码(验证登录密码) 不做校验
    if (self.operatorType == SafeCodeOperatorTypePassword) {
        [self requestGetEncryptKeyAction];
    }
}

#pragma mark - Request
- (void)requestGetEncryptKeyAction {
    [HUD showActivityMessage:@"" inView:self.view];
    @weakify(self)
    [IMSDKManager authGetEncryptKeySuccess:^(id  _Nullable data, NSString * _Nullable traceId) {
        @strongify(self)
        
        if([data isKindOfClass:[NSString class]]){
            NSString *encryptKey = (NSString *)data;
            if (self.operatorType == SafeCodeOperatorTypeClose) {
                [self requestCheckDeviceSafeCodeWithEncryptkey:encryptKey];
            }
            if (self.operatorType == SafeCodeOperatorTypePassword) {
                [self requestCheckDeviceloginPasswordWithEncryptkey:encryptKey];
            }
        }
    } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
        @strongify(self)
        
        [HUD showMessageWithCode:code errorMsg:msg inView:self.view];
    }];
}


//校验安全码
- (void)requestCheckDeviceSafeCodeWithEncryptkey:(NSString *)encryptKey {
    NSString *safeCodeEncryptStr = @"";
    if (![NSString isNil:encryptKey]) {
        //AES对称加密后的密码
        NSString *safeCodeKey = [NSString stringWithFormat:@"%@%@", encryptKey, [self.safeCodePwdInput.inputText.text trimString]];
        safeCodeEncryptStr = [LXChatEncrypt method4:safeCodeKey];
        if ([NSString isNil:safeCodeEncryptStr]) {
            [HUD showMessage:LanguageToolMatch(@"操作失败") inView:self.view];
            return;
        }
    }
    
    //调用关闭安全码接口(验证原安全码)
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObjectSafe:encryptKey forKey:@"encryptKey"];
    [params setObjectSafe:safeCodeEncryptStr forKey:@"originalSecurityCode"];
    [params setObjectSafe:UserManager.userInfo.userUID forKey:@"userUid"];
    [params setObjectSafe:@"" forKey:@"password"];
    
    @weakify(self)
    [IMSDKManager authCloseSecurityCodeWith:params onSuccess:^(id  _Nullable data, NSString * _Nullable traceId) {
        @strongify(self)
        
        BOOL result = [data boolValue];
        if (result) {
            [HUD showMessage:LanguageToolMatch(@"关闭成功") inView:self.view];
            NSArray *viewControllers = self.navigationController.viewControllers;
            for (UIViewController *vc in viewControllers) {
                if ([vc isKindOfClass:[CoHereSafeSettingViewController class]]) {
                    CoHereSafeSettingViewController *safeCodeSettingVC = (CoHereSafeSettingViewController *)vc;
                    [safeCodeSettingVC checkDeviceSafeCodeStatus];
                }
            }
            [self.navigationController popViewControllerAnimated:YES];
        } else {
            [HUD showMessage:LanguageToolMatch(@"操作失败") inView:self.view];
        }
    } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
        @strongify(self)
        
        if (code == Auth_Original_Security_Code_Error_Code) {
            self.securityCodeFailNum++;
            if (self.securityCodeFailNum < SECURITY_CODE_FAIL_MAX_NUM) {
                [HUD showMessageWithCode:code errorMsg:msg inView:self.view];
            } else {
                [HUD showMessage:LanguageToolMatch(@"原安全码输入错误3次需验证登录密码") inView:self.view];
                NoaSafeCodeCloseViewController *vc = [[NoaSafeCodeCloseViewController alloc] init];
                vc.operatorType = SafeCodeOperatorTypePassword;
                [self.navigationController pushViewController:vc animated:YES];
            }
        } else {
            if (code == Auth_Login_SecurityCode_Has_Set_Error_Code || code == Auth_Login_SecurityCode_No_Set_Error_Code || code == Auth_Login_SecurityCode_Format_Error_Code || code == Auth_Login_SecurityCode_otherFormat_Error_Code) {
                return;
            } else {
                [HUD showMessageWithCode:code errorMsg:msg inView:self.view];
            }
        }
    }];
}

//校验登录密码
- (void)requestCheckDeviceloginPasswordWithEncryptkey:(NSString *)encryptKey {
    NSString *passwordEncryptStr = @"";
    if (![NSString isNil:encryptKey]) {
        //AES对称加密后的密码
        NSString *passwordKey = [NSString stringWithFormat:@"%@%@", encryptKey, [self.safeCodePwdInput.inputText.text trimString]];
        passwordEncryptStr = [LXChatEncrypt method4:passwordKey];
        if ([NSString isNil:passwordEncryptStr]) {
            [HUD showMessage:LanguageToolMatch(@"操作失败") inView:self.view];
            return;
        }
    }
    
    //调用关闭安全码接口(验证登录密码)
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObjectSafe:encryptKey forKey:@"encryptKey"];
    [params setObjectSafe:@"" forKey:@"originalSecurityCode"];
    [params setObjectSafe:UserManager.userInfo.userUID forKey:@"userUid"];
    [params setObjectSafe:passwordEncryptStr forKey:@"password"];
    
    @weakify(self)
    [IMSDKManager authCloseSecurityCodeWith:params onSuccess:^(id  _Nullable data, NSString * _Nullable traceId) {
        @strongify(self)
        
        BOOL result = [data boolValue];
        if (result) {
            [HUD showMessage:LanguageToolMatch(@"关闭成功") inView:self.view];
            NSArray *viewControllers = self.navigationController.viewControllers;
            for (UIViewController *vc in viewControllers) {
                if ([vc isKindOfClass:[CoHereSafeSettingViewController class]]) {
                    CoHereSafeSettingViewController *safeCodeSettingVC = (CoHereSafeSettingViewController *)vc;
                    [self.navigationController popToViewController:vc animated:YES];
                    [safeCodeSettingVC checkDeviceSafeCodeStatus];
                }
            }
        } else {
            [HUD showMessage:LanguageToolMatch(@"操作失败") inView:self.view];
        }
    } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
        @strongify(self)
        
        [HUD showMessageWithCode:code errorMsg:msg inView:self.view];
    }];
}

#pragma mark - Lazy
- (NoaInputTextView *)safeCodePwdInput {
    if (!_safeCodePwdInput) {
        _safeCodePwdInput = [[NoaInputTextView alloc] init];
        _safeCodePwdInput.clipsToBounds = YES;
        _safeCodePwdInput.isPassword = YES;
        _safeCodePwdInput.isShowBoard = NO;
        _safeCodePwdInput.placeholderText = LanguageToolMatch(@"请输入安全码");
        _safeCodePwdInput.bgViewBackColor = @[COLORWHITE, COLOR_F5F6F9_DARK];
        _safeCodePwdInput.inputText.keyboardType = UIKeyboardTypeASCIICapable;
      
        if (@available(iOS 12.0, *)) {
            _safeCodePwdInput.inputText.textContentType = UITextContentTypeOneTimeCode;
        } else {
            // Fallback on earlier versions
        }
        _safeCodePwdInput.inputType = ZMessageInputViewTypePassword;
        _safeCodePwdInput.tipsImgName = @"";
    }
    return _safeCodePwdInput;
}

@end
