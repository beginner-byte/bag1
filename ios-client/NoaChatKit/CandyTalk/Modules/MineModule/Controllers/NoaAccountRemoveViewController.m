//
//  NoaAccountRemoveViewController.m
//  NoaKit
//
//  Created by Candy on 2023/4/17.
//

#import "NoaAccountRemoveViewController.h"
#import "NoaInputTextView.h"
#import "NoaAuthInputTools.h"
#import "NoaToolManager.h"
#import "LXChatEncrypt.h"

@interface NoaAccountRemoveViewController ()

@property (nonatomic, strong)NoaInputTextView *passwordInput;
@property (nonatomic, strong)UIButton *deleteButton;

@end

@implementation NoaAccountRemoveViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //注册键盘出现通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    // 注册键盘隐藏通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector: @selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    // 注销键盘出现通知
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    // 注销键盘隐藏通知
    [[NSNotificationCenter defaultCenter] removeObserver: self name:UIKeyboardWillHideNotification object: nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navTitleStr = LanguageToolMatch(@"删除账号");
    [self setupUI];
    self.passwordInput.preInputText = @"";
}

- (void)setupUI {
    UILabel *tipTitleLbl = [[UILabel alloc] init];
    tipTitleLbl.text = LanguageToolMatch(@"请输入密码:");
    tipTitleLbl.tkThemetextColors = @[COLOR_11, COLOR_11_DARK];
    tipTitleLbl.font = FONTN(16);
    tipTitleLbl.textAlignment = NSTextAlignmentLeft;
    [self.view addSubview:tipTitleLbl];
    [tipTitleLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.navView.mas_bottom).offset(DWScale(18));
        make.leading.equalTo(self.view).offset(DWScale(20));
        make.trailing.equalTo(self.view).offset(-DWScale(20));
        make.height.mas_equalTo(DWScale(18));
    }];
    
    [self.view addSubview:self.passwordInput];
    [self.passwordInput mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(tipTitleLbl.mas_bottom).offset(DWScale(10));
        make.leading.equalTo(self.view).offset(DWScale(16));
        make.trailing.equalTo(self.view).offset(DWScale(-16));
        make.height.mas_equalTo(DWScale(48));
    }];
    
    [self.view addSubview:self.deleteButton];
    [self.deleteButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.view).offset(DWScale(16));
        make.trailing.equalTo(self.view).offset(DWScale(-16));
        make.bottom.equalTo(self.view).offset(-(DWScale(38) + DHomeBarH));
        make.height.mas_equalTo(DWScale(50));
        
    }];
    
    //输入框输入block回调
    @weakify(self)
    /*
    [self.passwordInput setInputStatus:^{
        @strongify(self)
        [self checkLoginBtnAvailable];
    }];
    */
    //输入框失去输入焦点时的回调
    self.passwordInput.textFieldEndInput = ^{
        @strongify(self)
        [self listenTextFieldEndInputAction];
    };
}

#pragma mark - 状态监听
//通过检查输入框是否有内容来决定确定按钮是否可点击
- (void)checkLoginBtnAvailable {
    if (self.passwordInput.textLength > 0) {
        self.deleteButton.enabled = YES;
        self.deleteButton.tkThemebackgroundColors = @[COLOR_FF3333, COLOR_FF3333_DARK];
    } else {
        self.deleteButton.enabled = NO;
        self.deleteButton.tkThemebackgroundColors = @[[COLOR_FF3333 colorWithAlphaComponent:0.3], [COLOR_FF3333_DARK colorWithAlphaComponent:0.3]];
    }
}

//监听输入框输入内容变化，做条件判断处理
- (void)listenTextFieldEndInputAction {
    [NoaAuthInputTools checkPasswordWithText:self.passwordInput.inputText.text IsShowToast:YES];
}

#pragma mark - Keyboard Notification
-(void)keyboardWillShow:(NSNotification *) notification{
    //获取键盘的高度
    NSDictionary *userInfo = [notification userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    float keyboardHeight = keyboardRect.size.height;
    //更新约束
    [self.deleteButton mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view).offset(-(keyboardHeight + 40));
    }];
    [self.view setNeedsUpdateConstraints];
    [self.view updateConstraintsIfNeeded];
    [UIView animateWithDuration:0.15 animations:^{
        [self.view layoutIfNeeded];
    }];
}

-(void)keyboardWillHide: (NSNotification *) notification{
    [self.deleteButton mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view).offset(-(DWScale(38) + DHomeBarH));
    }];
    [self.view setNeedsUpdateConstraints];
    [self.view updateConstraintsIfNeeded];
    [UIView animateWithDuration:0.15 animations:^{
        [self.view layoutIfNeeded];
    }];
}

#pragma mark - Action
- (void)deleteAccountClick {
    //先获取加密密码的密钥
    [self getEncryptKeyAction];
}

#pragma mark - Request
- (void)getEncryptKeyAction {
    if ([NoaAuthInputTools checkPasswordWithText:self.passwordInput.inputText.text IsShowToast:YES] == NO) {
        return;
    }
    [HUD showActivityMessage:@"" inView:self.view];

    @weakify(self)
    [IMSDKManager authGetEncryptKeySuccess:^(id  _Nullable data, NSString * _Nullable traceId) {
        @strongify(self)
        
        [HUD hideHUD];
        //调用注册接口，传入加密密钥
        if([data isKindOfClass:[NSString class]]){
            NSString *encryptKey = (NSString *)data;
            [self LoginActionWithEncryptKey:encryptKey vercode:@""];
        }

    } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
        @strongify(self)
        
        [HUD showMessageWithCode:code errorMsg:msg inView:self.view];
    }];
}

- (void)LoginActionWithEncryptKey:(NSString *)encryptKey vercode:(NSString *)vercode {
    //注销账号之前调用一下 删除设备推送信息接口，对接口返回不做任何处理
    NoaUserModel *userModel = [NoaUserModel getUserInfo];
    if (userModel == nil || userModel.userUID.length <= 0) {
        return;
    }
    NSString *userPwStr = @"";
    if (![NSString isNil:encryptKey]) {
        //AES对称加密后的密码
        NSString *passwordKey = [NSString stringWithFormat:@"%@%@", encryptKey, self.passwordInput.inputText.text];
        userPwStr = [LXChatEncrypt method4:passwordKey];
    }
    
    NSString *tempUserId = userModel.userUID;
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObjectSafe:UserManager.userInfo.userName forKey:@"loginInfo"];
    [params setObjectSafe:[NSNumber numberWithInt:1] forKey:@"loginType"];
    [params setObjectSafe:@"" forKey:@"areaCode"];
    [params setObjectSafe:encryptKey forKey:@"encryptKey"];
    [params setObjectSafe:userPwStr forKey:@"userPw"];
    
    [HUD showActivityMessage:@"" inView:self.view];
    //调用注销接口(loginType:1用户名，2邮箱，3手机号，目前只有账号注销)
    [IMSDKManager authDeleteAccountWith:params onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {
        [ZTOOL setupLoginUI];
    } onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {
        if(code == LingIMHttpResponseCodeExamineStatus){
            [HUD showMessage:LanguageToolMatch(@"提交成功，系统稍后处理") inView:self.view];
        }else if (code == LingIMHttpResponseCodeNoneExamineStatus){
            [HUD showMessage:LanguageToolMatch(@"您已经提交过申请，请耐心等待审核") inView:self.view];
        }else{
            [HUD showMessageWithCode:code errorMsg:msg inView:self.view];
        }
    }];
    
    NSString *token = [[MMKV defaultMMKV] getStringForKey:L_DevicePushToken];
    if (token.length < 5) {
        return;
    }
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObjectSafe:[NSNumber numberWithInteger:1] forKey:@"osType"];
    [dict setObjectSafe:@"apns" forKey:@"pushServer"];
    [dict setObjectSafe:token?token:@"1" forKey:@"pushToken"];
    [dict setObjectSafe:tempUserId forKey:@"userUid"];
    
    [IMSDKManager imSdkdeleteDeviceTokenWith:dict onSuccess:^(id _Nullable data, NSString * _Nullable traceId) {} onFailure:^(NSInteger code, NSString * _Nullable msg, NSString * _Nullable traceId) {}];
}
#pragma mark - Lazy
- (NoaInputTextView *)passwordInput {
    if (!_passwordInput) {
        _passwordInput = [[NoaInputTextView alloc] init];
        _passwordInput.inputText.keyboardType = UIKeyboardTypeASCIICapable;
        _passwordInput.placeholderText = LanguageToolMatch(@"请输入密码");
        _passwordInput.inputType = ZMessageInputViewTypePassword;
        _passwordInput.tipsImgName = @"";
        _passwordInput.isShowBoard = NO;
        _passwordInput.bgViewBackColor = @[COLOR_F5F6F9, COLOR_F5F6F9_DARK];
    }
    return _passwordInput;
}

- (UIButton *)deleteButton {
    if (!_deleteButton) {
        _deleteButton = [[UIButton alloc] init];
        [_deleteButton setTitle:LanguageToolMatch(@"删除账号") forState:UIControlStateNormal];
        [_deleteButton setTitleColor:COLORWHITE forState:UIControlStateNormal];
        _deleteButton.enabled = YES;
        _deleteButton.tkThemebackgroundColors = @[COLOR_FF3333, COLOR_FF3333_DARK];
        //操作可视化
        //[_deleteButton setTkThemeBackgroundImage:@[[UIImage ImageForColor:COLOR_4069B9],[UIImage ImageForColor:COLOR_4069B9_DARK]] forState:UIControlStateSelected];
        //[_deleteButton setTkThemeBackgroundImage:@[[UIImage ImageForColor:COLOR_4069B9],[UIImage ImageForColor:COLOR_4069B9_DARK]] forState:UIControlStateHighlighted];
        _deleteButton.titleLabel.font = FONTN(16);
        [_deleteButton rounded:DWScale(14)];
        _deleteButton.clipsToBounds = YES;
        [_deleteButton addTarget:self action:@selector(deleteAccountClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _deleteButton;
}

@end
