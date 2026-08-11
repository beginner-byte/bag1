//
//  NoaRegisterBaseInputView.m
//  NoaChatKit
//
//  Created by phl on 2025/11/12.
//

#import "NoaRegisterBaseInputView.h"
#import "NoaFixedSizeRightView.h"
#import "NoaRegisterDataHandle.h"

@interface NoaRegisterBaseInputView ()

// MARK: 验证码输入↓
///  验证码输入框
@property (nonatomic, strong) UITextField *codeTF;

/// 验证码输入清理文本按钮
@property (nonatomic, strong) UIButton *codeTFClearBtn;

/// 验证码发送按钮
@property (nonatomic, strong) UIButton *sendCodeBtn;

/// 验证码错误提示
@property (nonatomic, strong) UILabel *sendCodeErrorTipLabel;

// MARK: 验证码输入↑

// MARK: 密码输入↓
/// 密码输入框
@property (nonatomic, strong) UITextField *passwordTF;

/// 密码输入清理文本按钮
@property (nonatomic, strong) UIButton *passwordTFClearBtn;

/// 密码是否隐藏按钮
@property (nonatomic, strong) UIButton *canEyesPasswordBtn;

/// 密码错误提示
@property (nonatomic, strong) UILabel *passwordErrorTipLabel;
// MARK: 密码输入↑

// MARK: 确认密码输入↓
/// 确认密码输入框
@property (nonatomic, strong) UITextField *confirmPasswordTF;

/// 确认密码输入清理文本按钮
@property (nonatomic, strong) UIButton *confirmPasswordTFClearBtn;

/// 确认密码是否隐藏按钮
@property (nonatomic, strong) UIButton *canEyesConfirmPasswordBtn;

/// 确认密码错误提示
@property (nonatomic, strong) UILabel *confirmPasswordErrorTipLabel;
// MARK: 确认密码输入↑

// MARK: 邀请码输入(动态隐藏+展示)↓
/// 邀请码输入框
@property (nonatomic, strong) UITextField *inviteCodeTF;

/// 邀请码输入清理文本按钮
@property (nonatomic, strong) UIButton *inviteCodeTFClearBtn;

/// 邀请码错误提示
@property (nonatomic, strong) UILabel *inviteCodeErrorTipLabel;

// MARK: 邀请码输入(动态隐藏+展示)↑

// MARK: 其他↓
/// 输入验证结果信号（内部实现）
@property (nonatomic, strong, readwrite) RACSubject<NSNumber *> *validationResultSignal;

/// 当前注册方式
@property (nonatomic, assign) ZLoginAndRegisterTypeMenu currentRegisterTypeMenu;

@end

@implementation NoaRegisterBaseInputView

#pragma mark - Lazy Loading

- (UITextField *)codeTF {
    if (!_codeTF) {
        _codeTF = [[UITextField alloc] initWithFrame:CGRectZero];
        _codeTF.tkThemebackgroundColors = @[[COLOR_5966F2 colorWithAlphaComponent:0.05], [COLOR_5966F2_DARK colorWithAlphaComponent:0.05]];
        _codeTF.tkThemetextColors = @[COLOR_11, COLOR_11_DARK];
        // 设置圆角
        _codeTF.layer.cornerRadius = 16;
        _codeTF.layer.masksToBounds = YES;
        // 设置边框
        _codeTF.layer.borderWidth = 1.0;
        _codeTF.layer.tkThemeborderColors = @[[COLOR_5966F2 colorWithAlphaComponent:0.05], [COLORWHITE colorWithAlphaComponent:0.4]];
        // 设置左边文字距离左边框间隔
        _codeTF.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 12, 0)];
        _codeTF.leftViewMode = UITextFieldViewModeAlways;
        _codeTF.keyboardType = UIKeyboardTypeDefault;
        _codeTF.textContentType = UITextContentTypeOneTimeCode;
        _codeTF.delegate = self;
        // 创建属性字符串
        NSDictionary *attributes = @{
            NSForegroundColorAttributeName: COLOR_99,
            NSFontAttributeName:FONTM(14)
        };
        _codeTF.attributedPlaceholder = [[NSAttributedString alloc] initWithString:LanguageToolMatch(@"验证码") attributes:attributes];
    }
    return _codeTF;
}

- (UIButton *)sendCodeBtn {
    if (!_sendCodeBtn) {
        _sendCodeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_sendCodeBtn setTitle:LanguageToolMatch(@"获取验证码") forState:UIControlStateNormal];
        [_sendCodeBtn setTkThemeTitleColor:@[COLOR_5966F2, COLOR_5966F2_DARK] forState:UIControlStateNormal];
        _sendCodeBtn.tkThemebackgroundColors = @[COLOR_CLEAR, COLOR_CLEAR];
        _sendCodeBtn.titleLabel.font = FONTM(14);
    }
    return _sendCodeBtn;
}

- (UIButton *)codeTFClearBtn {
    if (!_codeTFClearBtn) {
        _codeTFClearBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_codeTFClearBtn setImage:ImgNamed(@"icon_text_clear") forState:UIControlStateNormal];
    }
    return _codeTFClearBtn;
}

- (UILabel *)sendCodeErrorTipLabel {
    if (!_sendCodeErrorTipLabel) {
        _sendCodeErrorTipLabel = [UILabel new];
        _sendCodeErrorTipLabel.tkThemetextColors = @[COLOR_FF3333, COLOR_FF3333_DARK];
        _sendCodeErrorTipLabel.font = FONTR(14);
        _sendCodeErrorTipLabel.numberOfLines = 0;
        _sendCodeErrorTipLabel.hidden = YES;
    }
    return _sendCodeErrorTipLabel;
}

- (UITextField *)passwordTF {
    if (!_passwordTF) {
        _passwordTF = [[UITextField alloc] initWithFrame:CGRectZero];
        _passwordTF.tkThemebackgroundColors = @[[COLOR_5966F2 colorWithAlphaComponent:0.05], [COLOR_5966F2_DARK colorWithAlphaComponent:0.05]];
        _passwordTF.tkThemetextColors = @[COLOR_11, COLOR_11_DARK];
        // 设置圆角
        _passwordTF.layer.cornerRadius = 16;
        _passwordTF.layer.masksToBounds = YES;
        // 设置边框
        _passwordTF.layer.borderWidth = 1.0;
        _passwordTF.layer.tkThemeborderColors = @[[COLOR_5966F2 colorWithAlphaComponent:0.05], [COLORWHITE colorWithAlphaComponent:0.4]];
        // 设置左边文字距离左边框间隔
        _passwordTF.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 12, 0)];
        _passwordTF.leftViewMode = UITextFieldViewModeAlways;
        _passwordTF.keyboardType = UIKeyboardTypeDefault;
        _passwordTF.secureTextEntry = YES;
        _passwordTF.delegate = self;
        // 创建属性字符串
        NSDictionary *attributes = @{
            NSForegroundColorAttributeName: COLOR_99,
            NSFontAttributeName:FONTM(14)
        };
        _passwordTF.attributedPlaceholder = [[NSAttributedString alloc] initWithString:LanguageToolMatch(@"设置密码") attributes:attributes];
    }
    return _passwordTF;
}

- (UIButton *)passwordTFClearBtn {
    if (!_passwordTFClearBtn) {
        _passwordTFClearBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_passwordTFClearBtn setImage:ImgNamed(@"icon_text_clear") forState:UIControlStateNormal];
    }
    return _passwordTFClearBtn;
}

- (UIButton *)canEyesPasswordBtn {
    if (!_canEyesPasswordBtn) {
        _canEyesPasswordBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_canEyesPasswordBtn setImage:ImgNamed(@"icon_eye_on") forState:UIControlStateNormal];
        [_canEyesPasswordBtn setImage:ImgNamed(@"icon_eye_off") forState:UIControlStateSelected];
        _canEyesPasswordBtn.selected = YES;// 默认加密
    }
    return _canEyesPasswordBtn;
}

- (UILabel *)passwordErrorTipLabel {
    if (!_passwordErrorTipLabel) {
        _passwordErrorTipLabel = [UILabel new];
        _passwordErrorTipLabel.tkThemetextColors = @[COLOR_FF3333, COLOR_FF3333_DARK];
        _passwordErrorTipLabel.font = FONTR(14);
        _passwordErrorTipLabel.numberOfLines = 0;
        _passwordErrorTipLabel.hidden = YES;
    }
    return _passwordErrorTipLabel;
}

- (UITextField *)confirmPasswordTF {
    if (!_confirmPasswordTF) {
        _confirmPasswordTF = [[UITextField alloc] initWithFrame:CGRectZero];
        _confirmPasswordTF.tkThemebackgroundColors = @[[COLOR_5966F2 colorWithAlphaComponent:0.05], [COLOR_5966F2_DARK colorWithAlphaComponent:0.05]];
        _confirmPasswordTF.tkThemetextColors = @[COLOR_11, COLOR_11_DARK];
        // 设置圆角
        _confirmPasswordTF.layer.cornerRadius = 16;
        _confirmPasswordTF.layer.masksToBounds = YES;
        // 设置边框
        _confirmPasswordTF.layer.borderWidth = 1.0;
        _confirmPasswordTF.layer.tkThemeborderColors = @[[COLOR_5966F2 colorWithAlphaComponent:0.05], [COLORWHITE colorWithAlphaComponent:0.4]];
        // 设置左边文字距离左边框间隔
        _confirmPasswordTF.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 12, 0)];
        _confirmPasswordTF.leftViewMode = UITextFieldViewModeAlways;
        _confirmPasswordTF.keyboardType = UIKeyboardTypeDefault;
        _confirmPasswordTF.secureTextEntry = YES;
        _confirmPasswordTF.delegate = self;
        // 创建属性字符串
        NSDictionary *attributes = @{
            NSForegroundColorAttributeName: COLOR_99,
            NSFontAttributeName:FONTM(14)
        };
        _confirmPasswordTF.attributedPlaceholder = [[NSAttributedString alloc] initWithString:LanguageToolMatch(@"确认密码") attributes:attributes];
    }
    return _confirmPasswordTF;
}

- (UIButton *)confirmPasswordTFClearBtn {
    if (!_confirmPasswordTFClearBtn) {
        _confirmPasswordTFClearBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_confirmPasswordTFClearBtn setImage:ImgNamed(@"icon_text_clear") forState:UIControlStateNormal];
    }
    return _confirmPasswordTFClearBtn;
}

- (UIButton *)canEyesConfirmPasswordBtn {
    if (!_canEyesConfirmPasswordBtn) {
        _canEyesConfirmPasswordBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_canEyesConfirmPasswordBtn setImage:ImgNamed(@"icon_eye_on") forState:UIControlStateNormal];
        [_canEyesConfirmPasswordBtn setImage:ImgNamed(@"icon_eye_off") forState:UIControlStateSelected];
        _canEyesConfirmPasswordBtn.selected = YES;// 默认加密
    }
    return _canEyesConfirmPasswordBtn;
}

- (UILabel *)confirmPasswordErrorTipLabel {
    if (!_confirmPasswordErrorTipLabel) {
        _confirmPasswordErrorTipLabel = [UILabel new];
        _confirmPasswordErrorTipLabel.tkThemetextColors = @[COLOR_FF3333, COLOR_FF3333_DARK];
        _confirmPasswordErrorTipLabel.font = FONTR(14);
        _confirmPasswordErrorTipLabel.numberOfLines = 0;
        _confirmPasswordErrorTipLabel.hidden = YES;
    }
    return _confirmPasswordErrorTipLabel;
}

- (UITextField *)inviteCodeTF {
    if (!_inviteCodeTF) {
        _inviteCodeTF = [[UITextField alloc] initWithFrame:CGRectZero];
        _inviteCodeTF.tkThemebackgroundColors = @[[COLOR_5966F2 colorWithAlphaComponent:0.05], [COLOR_5966F2_DARK colorWithAlphaComponent:0.05]];
        _inviteCodeTF.tkThemetextColors = @[COLOR_11, COLOR_11_DARK];
        // 设置圆角
        _inviteCodeTF.layer.cornerRadius = 16;
        _inviteCodeTF.layer.masksToBounds = YES;
        // 设置边框
        _inviteCodeTF.layer.borderWidth = 1.0;
        _inviteCodeTF.layer.tkThemeborderColors = @[[COLOR_5966F2 colorWithAlphaComponent:0.05], [COLORWHITE colorWithAlphaComponent:0.4]];
        // 设置左边文字距离左边框间隔
        _inviteCodeTF.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 12, 0)];
        _inviteCodeTF.leftViewMode = UITextFieldViewModeAlways;
        _inviteCodeTF.keyboardType = UIKeyboardTypeDefault;
        _inviteCodeTF.secureTextEntry = YES;
        _inviteCodeTF.delegate = self;
        // 创建属性字符串
        NSDictionary *attributes = @{
            NSForegroundColorAttributeName: COLOR_99,
            NSFontAttributeName:FONTM(14)
        };
        _inviteCodeTF.attributedPlaceholder = [[NSAttributedString alloc] initWithString:LanguageToolMatch(@"请输入邀请码") attributes:attributes];
    }
    return _inviteCodeTF;
}

- (UIButton *)inviteCodeTFClearBtn {
    if (!_inviteCodeTFClearBtn) {
        _inviteCodeTFClearBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_inviteCodeTFClearBtn setImage:ImgNamed(@"icon_text_clear") forState:UIControlStateNormal];
    }
    return _inviteCodeTFClearBtn;
}

- (UILabel *)inviteCodeErrorTipLabel {
    if (!_inviteCodeErrorTipLabel) {
        _inviteCodeErrorTipLabel = [UILabel new];
        _inviteCodeErrorTipLabel.tkThemetextColors = @[COLOR_FF3333, COLOR_FF3333_DARK];
        _inviteCodeErrorTipLabel.font = FONTR(14);
        _inviteCodeErrorTipLabel.numberOfLines = 0;
        _inviteCodeErrorTipLabel.hidden = YES;
    }
    return _inviteCodeErrorTipLabel;
}


- (RACSubject<NSNumber *> *)validationResultSignal {
    if (!_validationResultSignal) {
        _validationResultSignal = [RACSubject subject];
    }
    return _validationResultSignal;
}

#pragma mark - Setter
- (void)setIsSupportInviteCode:(BOOL)isSupportInviteCode {
    if (_isSupportInviteCode == isSupportInviteCode) {
        return;
    }
    _isSupportInviteCode = isSupportInviteCode;
    [self setupInviteTextFieldConstraints];
}

- (void)setIsSupportVerCode:(BOOL)isSupportVerCode {
    if (_isSupportVerCode == isSupportVerCode) {
        return;
    }
    _isSupportVerCode = isSupportVerCode;
    [self setupCodeViewConstraints];
}

#pragma mark - init

- (instancetype)initWithFrame:(CGRect)frame
           CurrentRegisterWay:(ZLoginAndRegisterTypeMenu)currentRegisterWay {
    self = [super initWithFrame:frame];
    if (self) {
        self.currentRegisterTypeMenu = currentRegisterWay;
    }
    return self;
}

#pragma mark - Public Methods

- (NSString *)getPasswordText {
    return self.passwordTF.text ?: @"";
}

- (NSString *)getConfirmPasswordText {
    return self.confirmPasswordTF.text ?: @"";
}

- (NSString *)getCodeText {
    return self.codeTF.text ?: @"";
}

- (NSString *)getInviteText {
    return self.inviteCodeTF.text ?: @"";
}

- (void)triggerValidation {
    NSString *firstInput = [self getFirstInputText];
    NSString *password = [self getPasswordText];
    // 默认验证：第一个输入框和密码都不为空
    BOOL isValid = firstInput.length > 0 && password.length > 0;
    // 手动发送验证结果
    [self.validationResultSignal sendNext:@(isValid)];
}

#pragma mark - Setup Methods

/// 设置验证码视图约束（子类可重写以自定义）
- (void)setupCodeViewConstraints {
    UIView *firstInputView = [self getFirstInputView];
    
    self.codeTF.hidden = !self.isSupportVerCode;
    self.sendCodeErrorTipLabel.hidden = !self.isSupportVerCode;
    
    [self.codeTF mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(firstInputView.mas_bottom).offset(self.isSupportVerCode ? 12 : 0);
        make.leading.equalTo(@20);
        make.trailing.equalTo(self).offset(-20);
        make.height.equalTo(self.isSupportVerCode ? @57 : @0);
    }];
    
    [self.sendCodeErrorTipLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.codeTF.mas_bottom).offset(0);
        make.leading.equalTo(@20);
        make.trailing.equalTo(self).offset(-20);
        make.height.equalTo(@0);
    }];
}

/// 设置密码输入框约束（子类可重写以自定义）
- (void)setupPasswordTextFieldConstraints {
    [self.passwordTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.sendCodeErrorTipLabel.mas_bottom).offset(12);
        make.leading.equalTo(@20);
        make.trailing.equalTo(self).offset(-20);
        make.height.equalTo(@57);
    }];
    
    [self.passwordErrorTipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.passwordTF.mas_bottom).offset(0);
        make.leading.equalTo(@20);
        make.trailing.equalTo(self).offset(-20);
        make.height.equalTo(@0);
    }];
}

/// 设置确认密码输入框约束（子类可重写以自定义）
- (void)setupConfirmPasswordTextFieldConstraints {
    [self.confirmPasswordTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.passwordErrorTipLabel.mas_bottom).offset(12);
        make.leading.equalTo(@20);
        make.trailing.equalTo(self).offset(-20);
        make.height.equalTo(@57);
    }];
    
    [self.confirmPasswordErrorTipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.confirmPasswordTF.mas_bottom).offset(0);
        make.leading.equalTo(@20);
        make.trailing.equalTo(self).offset(-20);
        make.height.equalTo(@0);
    }];
}

/// 设置邀请码输入框约束（子类可重写以自定义）
- (void)setupInviteTextFieldConstraints {
    self.inviteCodeTF.hidden = !self.isSupportInviteCode;
    self.inviteCodeErrorTipLabel.hidden = !self.isSupportInviteCode;
    
    [self.inviteCodeTF mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.confirmPasswordErrorTipLabel.mas_bottom).offset(self.isSupportInviteCode ? 12 : 0);
        make.leading.equalTo(@20);
        make.trailing.equalTo(self).offset(-20);
        make.height.equalTo(self.isSupportInviteCode ? @57 : @0);
    }];
    
    [self.inviteCodeErrorTipLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.inviteCodeTF.mas_bottom).offset(0);
        make.leading.equalTo(@20);
        make.trailing.equalTo(self).offset(-20);
        make.height.equalTo(@0);
        make.bottom.equalTo(self);
    }];
}

/// 设置UI（子类需要调用 super 并实现自己的第一个输入框）
- (void)setupUI {
    [self addSubview:self.codeTF];
    [self addSubview:self.sendCodeErrorTipLabel];
    [self setupRightViewForCodeTextField];
    
    [self addSubview:self.passwordTF];
    [self addSubview:self.passwordErrorTipLabel];
    [self setupRightViewForPasswordTextField];
    
    [self addSubview:self.confirmPasswordTF];
    [self addSubview:self.confirmPasswordErrorTipLabel];
    [self setupRightViewForConfirmPasswordTextField];
    
    [self addSubview:self.inviteCodeTF];
    [self addSubview:self.inviteCodeErrorTipLabel];
    [self setupRightViewForInviteCodeTFextField];
    
    [self setupCodeViewConstraints];
    [self setupPasswordTextFieldConstraints];
    [self setupConfirmPasswordTextFieldConstraints];
    [self setupInviteTextFieldConstraints];
}

/// 处理数据（子类需要调用 super）
- (void)processData {
    @weakify(self)
    [[self.sendCodeBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self)
        if (self.getVerCodeActionBlock) {
            self.getVerCodeActionBlock();
        }
    }];
    
    [[self.canEyesPasswordBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self)
        UIButton *canEyesPasswordBtn = x;
        if (self.passwordTF.isSecureTextEntry) {
            self.passwordTF.secureTextEntry = NO;
            // 标记按钮为非选中状态，展示非选中状态图片
            canEyesPasswordBtn.selected = NO;
        } else {
            self.passwordTF.secureTextEntry = YES;
            // 标记按钮为选中状态，展示选中状态图片
            canEyesPasswordBtn.selected = YES;
        }
    }];
    
    [[self.canEyesConfirmPasswordBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self)
        UIButton *canEyesConfirmPasswordBtn = x;
        if (self.confirmPasswordTF.isSecureTextEntry) {
            self.confirmPasswordTF.secureTextEntry = NO;
            // 标记按钮为非选中状态，展示非选中状态图片
            canEyesConfirmPasswordBtn.selected = NO;
        } else {
            self.confirmPasswordTF.secureTextEntry = YES;
            // 标记按钮为选中状态，展示选中状态图片
            canEyesConfirmPasswordBtn.selected = YES;
        }
    }];
    
    // 监听输入变化，进行验证
    [self setupInputValidation];
}

/// 设置输入验证逻辑
- (void)setupInputValidation {
    @weakify(self)
    // 合并第一个输入框、密码和验证码的文本信号
    RACSignal<NSNumber *> *validationSignal = [[RACSignal combineLatest:@[
        [self getFirstInputTextSignal],
        self.codeTF.rac_textSignal,
        self.passwordTF.rac_textSignal,
        self.confirmPasswordTF.rac_textSignal,
        self.inviteCodeTF.rac_textSignal,
    ]] map:^NSNumber *(RACTuple *tuple) {
        @strongify(self)
        NSString *firstInput = tuple.first ?: @"";
        NSString *codeInput = tuple.second ?: @"";
        NSString *password = tuple.third ?: @"";
        NSString *confirmPassword = tuple.fourth ?: @"";
        NSString *inviteCode = tuple.fifth ?: @"";
        // 默认验证：第一个输入框和密码都不为空
        BOOL isValid = NO;
        switch (self.currentRegisterTypeMenu) {
            case ZLoginTypeMenuEmail:
                // 验证：账号输入(第一个输入框)、验证码、密码、确认密码都不为空
                isValid = firstInput.length > 0 && codeInput.length > 0 && password.length > 0 && confirmPassword.length > 0;
                break;
            case ZLoginTypeMenuPhoneNumber:
                // 验证：账号输入(第一个输入框)、验证码、密码、确认密码都不为空
                isValid = firstInput.length > 0 && codeInput.length > 0 && password.length > 0 && confirmPassword.length > 0;
                break;
            case ZLoginTypeMenuAccountPassword:
                // 验证：账号输入(第一个输入框)、密码、确认密码都不为空
                isValid = firstInput.length > 0 && password.length > 0 && confirmPassword.length > 0;
                break;
            default:
                break;
        }
        
        if (self.isSupportInviteCode) {
            // 如果支持邀请码，邀请码也需要有值
            isValid = isValid && inviteCode.length > 0;
        }
        return @(isValid);
    }];
    
    // 订阅验证结果，发送到 validationResultSignal
    [validationSignal subscribeNext:^(NSNumber *isValid) {
        @strongify(self)
        [self.validationResultSignal sendNext:isValid];
    }];
}

/// 设置验证码输入rightView（包含图文验证码图片）
- (void)setupRightViewForCodeTextField {
    CGFloat sendCodeTextWidth = [self calculateButtonWidthForText:LanguageToolMatch(@"获取验证码") font:FONTM(14)];
    CGFloat sendCodeBtnWidth = MAX(94, sendCodeTextWidth);
    CGFloat clearCodeTFBtnWidth = 20;
    // 创建固定宽高的容器 view
    NoaFixedSizeRightView *containerView = [[NoaFixedSizeRightView alloc] initWithFixedSize:CGSizeMake(sendCodeBtnWidth + clearCodeTFBtnWidth + 12, 58)];
    
    // 发送验证码按钮
    [containerView addSubview:self.sendCodeBtn];
    // 清除文本按钮
    [containerView addSubview:self.codeTFClearBtn];
    
    [self.sendCodeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(containerView);
        make.centerY.equalTo(containerView);
        make.width.equalTo(@(sendCodeBtnWidth));
        make.height.equalTo(@58);
    }];
    
    [self.codeTFClearBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self.sendCodeBtn.mas_leading);
        make.centerY.equalTo(containerView);
        make.width.height.equalTo(@(clearCodeTFBtnWidth));
    }];
    
    // 设置 rightView
    self.codeTF.rightView = containerView;
    self.codeTF.rightViewMode = UITextFieldViewModeAlways; // 容器始终显示，内部按钮根据状态控制
    
    @weakify(self)
    // 更新清除按钮显示状态的辅助方法
    void (^updateClearButtonVisibility)(void) = ^{
        @strongify(self)
        BOOL shouldShow = self.codeTF.isEditing && self.codeTF.text.length > 0;
        self.codeTFClearBtn.hidden = !shouldShow;
    };
    
    // 监听开始编辑
    [[self.codeTF rac_signalForControlEvents:UIControlEventEditingDidBegin] subscribeNext:^(__kindof UIControl * _Nullable x) {
        updateClearButtonVisibility();
    }];
    
    // 监听结束编辑
    [[self.codeTF rac_signalForControlEvents:UIControlEventEditingDidEnd] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self)
        updateClearButtonVisibility();
        
        // 编辑结束，校验密码是否合法
        [NoaRegisterDataHandle checkVerCodeInputWithRegisterType:self.currentRegisterTypeMenu
                                                  VerCodeInput:self.codeTF.text
                                                WhenEditFinish:^(BOOL res, NSString * _Nullable errorText) {
            @strongify(self)
            
            if (res) {
                // 检查通过
                self.sendCodeErrorTipLabel.text = @"";
                self.sendCodeErrorTipLabel.hidden = YES;
                [self.sendCodeErrorTipLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.top.equalTo(self.codeTF.mas_bottom).offset(0);
                    make.leading.equalTo(@20);
                    make.trailing.equalTo(self).offset(-20);
                    make.height.equalTo(@0);
                }];
            }else {
                self.sendCodeErrorTipLabel.text = [NSString isNil:errorText] ? @"" : errorText;
                self.sendCodeErrorTipLabel.hidden = NO;
                [self.sendCodeErrorTipLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.top.equalTo(self.codeTF.mas_bottom).offset(12);
                    make.leading.equalTo(@20);
                    make.trailing.equalTo(self).offset(-20);
                    make.height.greaterThanOrEqualTo(@14);
                }];
            }
        }];
    }];
    
    // 监听文本变化
    [self.codeTF.rac_textSignal subscribeNext:^(NSString * _Nullable text) {
        updateClearButtonVisibility();
    }];
    
    // 清理验证码点击事件
    [[self.codeTFClearBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self)
        self.codeTF.text = @"";
        // 通知注册登录按钮状态变化
        [self.validationResultSignal sendNext:@NO];
    }];
}

/// 设置密码输入rightView（包含隐藏按钮和清除按钮）
- (void)setupRightViewForPasswordTextField {
    // 创建固定宽高的容器 view
    NoaFixedSizeRightView *containerView = [[NoaFixedSizeRightView alloc] initWithFixedSize:CGSizeMake(76, 57)];
    
    // 清除按钮（只在编辑时显示）
    [containerView addSubview:self.passwordTFClearBtn];
    // 隐藏/展示密码按钮（任何时候都显示）
    [containerView addSubview:self.canEyesPasswordBtn];
    [self.passwordTFClearBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self.canEyesPasswordBtn.mas_leading).offset(-12);
        make.centerY.equalTo(containerView);
        make.width.height.equalTo(@20);
    }];
    
    [self.canEyesPasswordBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(containerView).offset(-12);
        make.centerY.equalTo(containerView);
        make.width.height.equalTo(@20);
    }];
    
    // 设置 rightView
    self.passwordTF.rightView = containerView;
    self.passwordTF.rightViewMode = UITextFieldViewModeAlways; // 容器始终显示，内部按钮根据状态控制
    
    @weakify(self)
    // 更新清除按钮显示状态的辅助方法
    void (^updateClearButtonVisibility)(void) = ^{
        @strongify(self)
        BOOL shouldShow = self.passwordTF.isEditing && self.passwordTF.text.length > 0;
        self.passwordTFClearBtn.hidden = !shouldShow;
    };
    
    // 监听开始编辑
    [[self.passwordTF rac_signalForControlEvents:UIControlEventEditingDidBegin] subscribeNext:^(__kindof UIControl * _Nullable x) {
        updateClearButtonVisibility();
    }];
    
    // 监听结束编辑
    [[self.passwordTF rac_signalForControlEvents:UIControlEventEditingDidEnd] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self)
        updateClearButtonVisibility();
        
        // 编辑结束，校验密码是否合法
        [NoaRegisterDataHandle checkPasswordInputWithRegisterType:self.currentRegisterTypeMenu
                                                  PasswordInput:self.passwordTF.text
                                                 WhenEditFinish:^(BOOL res, NSString * _Nullable errorText) {
            @strongify(self)
            
            if (res) {
                // 检查通过
                self.passwordErrorTipLabel.text = @"";
                self.passwordErrorTipLabel.hidden = YES;
                [self.passwordErrorTipLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.top.equalTo(self.passwordTF.mas_bottom).offset(0);
                    make.leading.equalTo(@20);
                    make.trailing.equalTo(self).offset(-20);
                    make.height.equalTo(@0);
                }];
            }else {
                self.passwordErrorTipLabel.text = [NSString isNil:errorText] ? @"" : errorText;
                self.passwordErrorTipLabel.hidden = NO;
                [self.passwordErrorTipLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.top.equalTo(self.passwordTF.mas_bottom).offset(12);
                    make.leading.equalTo(@20);
                    make.trailing.equalTo(self).offset(-20);
                    make.height.greaterThanOrEqualTo(@14);
                }];
            }
        }];
    }];
    
    // 监听文本变化
    [self.passwordTF.rac_textSignal subscribeNext:^(NSString * _Nullable text) {
        updateClearButtonVisibility();
    }];
    
    // 清理密码点击事件
    [[self.passwordTFClearBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self)
        self.passwordTF.text = @"";
        // 通知注册登录按钮状态变化
        [self.validationResultSignal sendNext:@NO];
    }];
}

/// 设置确认密码输入rightView（包含隐藏按钮和清除按钮）
- (void)setupRightViewForConfirmPasswordTextField {
    // 创建固定宽高的容器 view
    NoaFixedSizeRightView *containerView = [[NoaFixedSizeRightView alloc] initWithFixedSize:CGSizeMake(76, 57)];
    
    // 清除按钮（只在编辑时显示）
    [containerView addSubview:self.confirmPasswordTFClearBtn];
    // 隐藏/展示密码按钮（任何时候都显示）
    [containerView addSubview:self.canEyesConfirmPasswordBtn];
    [self.confirmPasswordTFClearBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self.canEyesConfirmPasswordBtn.mas_leading).offset(-12);
        make.centerY.equalTo(containerView);
        make.width.height.equalTo(@20);
    }];
    
    [self.canEyesConfirmPasswordBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(containerView).offset(-12);
        make.centerY.equalTo(containerView);
        make.width.height.equalTo(@20);
    }];
    
    // 设置 rightView
    self.confirmPasswordTF.rightView = containerView;
    self.confirmPasswordTF.rightViewMode = UITextFieldViewModeAlways; // 容器始终显示，内部按钮根据状态控制
    
    @weakify(self)
    // 更新清除按钮显示状态的辅助方法
    void (^updateClearButtonVisibility)(void) = ^{
        @strongify(self)
        BOOL shouldShow = self.confirmPasswordTF.isEditing && self.confirmPasswordTF.text.length > 0;
        self.confirmPasswordTFClearBtn.hidden = !shouldShow;
    };
    
    // 监听开始编辑
    [[self.confirmPasswordTF rac_signalForControlEvents:UIControlEventEditingDidBegin] subscribeNext:^(__kindof UIControl * _Nullable x) {
        updateClearButtonVisibility();
    }];
    
    // 监听结束编辑
    [[self.confirmPasswordTF rac_signalForControlEvents:UIControlEventEditingDidEnd] subscribeNext:^(__kindof UIControl * _Nullable x) {
        updateClearButtonVisibility();
    }];
    
    // 监听文本变化
    [self.confirmPasswordTF.rac_textSignal subscribeNext:^(NSString * _Nullable text) {
        @strongify(self)
        updateClearButtonVisibility();
        
        // 编辑结束，校验确认密码是否合法
        [NoaRegisterDataHandle checkConfirmPasswordInputWithRegisterType:self.currentRegisterTypeMenu
                                                         PasswordInput:self.passwordTF.text
                                                  ConfirmPasswordInput:self.confirmPasswordTF.text
                                                        WhenEditFinish:^(BOOL res, NSString * _Nullable errorText) {
            @strongify(self)
            
            if (res) {
                // 检查通过
                self.confirmPasswordErrorTipLabel.text = @"";
                self.confirmPasswordErrorTipLabel.hidden = YES;
                [self.confirmPasswordErrorTipLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.top.equalTo(self.confirmPasswordTF.mas_bottom).offset(0);
                    make.leading.equalTo(@20);
                    make.trailing.equalTo(self).offset(-20);
                    make.height.equalTo(@0);
                }];
            }else {
                self.confirmPasswordErrorTipLabel.text = [NSString isNil:errorText] ? @"" : errorText;
                self.confirmPasswordErrorTipLabel.hidden = NO;
                [self.confirmPasswordErrorTipLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.top.equalTo(self.confirmPasswordTF.mas_bottom).offset(12);
                    make.leading.equalTo(@20);
                    make.trailing.equalTo(self).offset(-20);
                    make.height.equalTo(@14);
                }];
            }
        }];
    }];
    
    // 清理确认密码点击事件
    [[self.confirmPasswordTFClearBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self)
        self.confirmPasswordTF.text = @"";
        // 通知注册登录按钮状态变化
        [self.validationResultSignal sendNext:@NO];
    }];
}

- (void)setupRightViewForInviteCodeTFextField {
    // 创建固定宽高的容器 view
    NoaFixedSizeRightView *containerView = [[NoaFixedSizeRightView alloc] initWithFixedSize:CGSizeMake(42, 57)];
    
    // 清除按钮（只在编辑时显示）
    [containerView addSubview:self.inviteCodeTFClearBtn];

    [self.inviteCodeTFClearBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(containerView).offset(-12);
        make.centerY.equalTo(containerView);
        make.width.height.equalTo(@20);
    }];
    
    // 设置 rightView
    self.inviteCodeTF.rightView = containerView;
    self.inviteCodeTF.rightViewMode = UITextFieldViewModeAlways; // 容器始终显示，内部按钮根据状态控制
    
    @weakify(self)
    // 更新清除按钮显示状态的辅助方法
    void (^updateClearButtonVisibility)(void) = ^{
        @strongify(self)
        BOOL shouldShow = self.inviteCodeTF.isEditing && self.inviteCodeTF.text.length > 0;
        self.inviteCodeTFClearBtn.hidden = !shouldShow;
    };
    
    // 监听开始编辑
    [[self.inviteCodeTF rac_signalForControlEvents:UIControlEventEditingDidBegin] subscribeNext:^(__kindof UIControl * _Nullable x) {
        updateClearButtonVisibility();
    }];
    
    // 监听结束编辑
    [[self.inviteCodeTF rac_signalForControlEvents:UIControlEventEditingDidEnd] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self)
        updateClearButtonVisibility();
        
        // 编辑结束，校验邀请码是否合法
        [NoaRegisterDataHandle checkInviteCodeInputWithRegisterType:self.currentRegisterTypeMenu
                                                  InviteCodeInput:self.inviteCodeTF.text
                                                   WhenEditFinish:^(BOOL res, NSString * _Nullable errorText) {
            @strongify(self)
            
            if (res) {
                // 检查通过
                self.inviteCodeErrorTipLabel.text = @"";
                self.inviteCodeErrorTipLabel.hidden = YES;
                [self.inviteCodeErrorTipLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.top.equalTo(self.inviteCodeTF.mas_bottom).offset(0);
                    make.leading.equalTo(@20);
                    make.trailing.equalTo(self).offset(-20);
                    make.height.equalTo(@0);
                    make.bottom.equalTo(self);
                }];
            }else {
                self.inviteCodeErrorTipLabel.text = [NSString isNil:errorText] ? @"" : errorText;
                self.inviteCodeErrorTipLabel.hidden = NO;
                [self.inviteCodeErrorTipLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.top.equalTo(self.inviteCodeTF.mas_bottom).offset(12);
                    make.leading.equalTo(@20);
                    make.trailing.equalTo(self).offset(-20);
                    make.height.greaterThanOrEqualTo(@14);
                    make.bottom.equalTo(self);
                }];
            }
        }];
    }];
    
    // 监听文本变化
    [self.inviteCodeTF.rac_textSignal subscribeNext:^(NSString * _Nullable text) {
        updateClearButtonVisibility();
    }];
    
    // 清理确认密码点击事件
    [[self.inviteCodeTFClearBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self)
        self.inviteCodeTF.text = @"";
        // 通知注册登录按钮状态变化
        [self.validationResultSignal sendNext:@NO];
    }];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if ([string isEqualToString:@" "] || [string isEqualToString:@"  "]) {
        // 当输入为空格时，阻止输入
        return NO;
    } else {
        // 允许删除字符
        if ([string isEqualToString:@""]) {
            return YES;
        }
        return YES;
    }
}

#pragma mark - Abstract Methods (子类必须实现)

- (NSString *)getFirstInputText {
    NSAssert(NO, @"子类必须实现 getFirstInputText 方法");
    return @"";
}

- (UIView *)getFirstInputView {
    NSAssert(NO, @"子类必须实现 getFirstInputView 方法");
    return nil;
}

- (RACSignal<NSString *> *)getFirstInputTextSignal {
    NSAssert(NO, @"子类必须实现 getFirstInputTextSignal 方法");
    return [RACSignal return:@""];
}


/// MARK: 根据文本计算长度
- (CGFloat)calculateButtonWidthForText:(NSString *)text font:(UIFont *)font {
    NSDictionary *attributes = @{NSFontAttributeName: font};
    CGSize size = [text sizeWithAttributes:attributes];
    CGFloat textWidth = size.width + 24; // 左右各12的内边距,多余出来一点
    return textWidth;
}

// MARK: 验证码倒计时展示
- (void)startVerCodeCountDown {
    @weakify(self)
    
    [ZTOOL doInMain:^{
        @strongify(self)
        // 如果按钮已经禁用，说明倒计时正在进行，避免重复调用
        if (!self.sendCodeBtn.enabled) {
            return;
        }
        
        self.sendCodeBtn.enabled = NO;
        self.sendCodeBtn.tkThemebackgroundColors = @[COLOR_E3E8EF, COLOR_E3E8EF];
        
        int timeOut = 60;
        NSString *title = [NSString stringWithFormat:LanguageToolMatch(@"重新获取(%d)"), timeOut];
        [self.sendCodeBtn setTitle:title forState:UIControlStateNormal];
        CGFloat sendCodeTextWidth = [self calculateButtonWidthForText:title font:self.sendCodeBtn.titleLabel.font];
        CGFloat sendCodeBtnWidth = MAX(94, sendCodeTextWidth);
        
        [self.sendCodeBtn mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@(sendCodeBtnWidth));
        }];
        
        [self.sendCodeBtn startCountDownTime:timeOut title:title CountDownBlock:^(int count) {
            @strongify(self)
            NSString *title = [NSString stringWithFormat:LanguageToolMatch(@"重新获取(%d)"), count];
            [self.sendCodeBtn setTitle:title forState:UIControlStateNormal];
        } Finish:^{
            @strongify(self)
            self.sendCodeBtn.enabled = YES;
            self.sendCodeBtn.tkThemebackgroundColors = @[COLOR_5966F2, COLOR_5966F2_DARK];
            
            NSString *title = LanguageToolMatch(@"获取验证码");
            [self.sendCodeBtn setTitle:title forState:UIControlStateNormal];
            CGFloat sendCodeTextWidth = [self calculateButtonWidthForText:title font:self.sendCodeBtn.titleLabel.font];
            CGFloat sendCodeBtnWidth = MAX(94, sendCodeTextWidth);
            
            [self.sendCodeBtn mas_updateConstraints:^(MASConstraintMaker *make) {
                make.width.equalTo(@(sendCodeBtnWidth));
            }];
        }];
    }];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
